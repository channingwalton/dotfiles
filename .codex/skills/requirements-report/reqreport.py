#!/usr/bin/env python3
"""reqreport - render a requirements document with its test results embedded.

The output *is* the document: headings, prose and lists in their original order, with a
status badge on every line that carries a `#id` marker, and the test source and failure
folded in beneath it. Nothing about the document is reconstructed or discarded.

Tests bind by carrying the id in their *name* - `#the-id` where names are free text, or
`req_the_id` where they are identifiers (Rust, Go). That works in any language because
every test framework's report carries the test name, and every one can emit JUnit XML.

Stdlib only. No install step.

    reqreport.py --requirements requirements/ --junit build/test-results/test/ \
                 --sources src/test/ --out target/requirements/ --root .

Exit codes: 0 clean, 1 requirement problems found, 2 bad input.
"""

from __future__ import annotations

import argparse
import html
import json
import re
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

MARKER_IN_DOC = re.compile(r"`#([A-Za-z0-9][A-Za-z0-9._-]*)`")

# In a test name the id may be written two ways. `#the-id` reads best and works wherever
# test names are free text. `req_the_id` is for languages whose test names are *identifiers*
# - Rust, Go - where `#` and `-` are illegal.
HASH_IN_NAME = re.compile(r"#([A-Za-z0-9][A-Za-z0-9._-]*)")
# Not \b before `req`: an identifier may embed it after an underscore, and \b does not
# match between `_` and `r`.
REQ_IN_NAME = re.compile(r"(?<![A-Za-z0-9])req[_-]([A-Za-z0-9][A-Za-z0-9._-]*)")

HEADING = re.compile(r"^(#{1,6})\s+(.*)$")
BULLET = re.compile(r"^(\s*)(?:[-*+]|\d+[.)])\s+(.*)$")
FENCE = re.compile(r"^\s*(```|~~~)(.*)$")
QUOTE = re.compile(r"^\s*>\s?(.*)$")
RULE = re.compile(r"^\s*(?:-{3,}|\*{3,}|_{3,})\s*$")
# A pipe table. The delimiter row is what makes a run of these a table rather than prose
# that happens to start with a pipe, so TABLE_ROW alone never decides anything.
TABLE_ROW = re.compile(r"^\s*\|(.*)\|\s*$")
TABLE_CELL = re.compile(r"(?<!\\)\|")
TABLE_DELIM_CELL = re.compile(r":?-+:?")

PASS, FAIL, UNTESTED, SKIPPED = "pass", "fail", "untested", "skipped"
LABEL = {PASS: "PASS", FAIL: "FAIL", UNTESTED: "NO TEST", SKIPPED: "SKIPPED"}
SEVERITY = {FAIL: 3, UNTESTED: 2, SKIPPED: 1, PASS: 0}

SOURCE_SUFFIXES = (".scala", ".java", ".kt", ".ts", ".tsx", ".js", ".jsx",
                   ".py", ".go", ".rb", ".cs", ".rs", ".php", ".swift")


def normalise_id(rid: str) -> str:
    """`_` and `-` are the same separator, so one id can be written either way."""
    return rid.replace("_", "-").lower()


def resolve_id(tail: str, known: set[str] | None) -> str:
    """Where an id ends in a test name is genuinely ambiguous. `.` and `-` are legal inside
    an id, so `#live-ok. The service …` would otherwise yield `live-ok.`; and nothing
    separates `req_health_obs_received` from `req_health_obs_received_on_rejected_method`.

    Rather than invent a terminator nobody will remember, resolve against the ids the
    documents actually define, longest first. That makes the rule the same for both forms
    and easy to state: **after the id, write whatever you like** - the rest of the name is
    for the reader, and the tool ignores it.

    An unmatched marker keeps its raw text, so a typo surfaces as an orphan rather than
    vanishing into the unlinked pile.
    """
    tail = tail.rstrip("._-")
    if not known:
        return tail
    for candidate in sorted((k for k in known if tail == k or tail.startswith(k + "-")),
                            key=len, reverse=True):
        return candidate
    return tail


def ids_in_name(name: str, known: set[str] | None = None) -> list[str]:
    raw = HASH_IN_NAME.findall(name) + REQ_IN_NAME.findall(name)
    return list(dict.fromkeys(resolve_id(normalise_id(m), known) for m in raw))


# --------------------------------------------------------------------------- model

@dataclass
class Block:
    """One piece of the document, in the order it was written."""
    kind: str                 # heading | para | item | code | quote | rule | table
    text: str = ""
    level: int = 0            # heading level, or list nesting depth
    rid: str | None = None    # requirement id, if this line carries a marker
    line: int = 0
    lang: str = ""
    rows: list[list[str]] = field(default_factory=list)   # table: header row, then body
    align: list[str] = field(default_factory=list)        # table: "", "center" or "right"


@dataclass
class Doc:
    source: str
    blocks: list[Block]

    @property
    def marked(self) -> list[Block]:
        return [b for b in self.blocks if b.rid]


@dataclass
class TestCase:
    name: str
    classname: str
    failure: tuple[str, str] | None   # (message, detail)
    skipped: bool
    ids: list[str]


@dataclass
class DocResult:
    doc: Doc
    page: str
    status_of: dict[str, str]                 # id -> status
    tests_of: dict[str, list[TestCase]]       # id -> its tests
    rollup: dict[int, str]                    # block index -> rolled-up status (headings)
    classes: list[str]

    def count(self, status: str) -> int:
        return sum(1 for s in self.status_of.values() if s == status)

    @property
    def status(self) -> str:
        worst = PASS
        for s in self.status_of.values():
            if SEVERITY[s] > SEVERITY[worst]:
                worst = s
        return worst


# ------------------------------------------------------------------- requirements

def join_wrapped(lines: list[str]) -> list[str]:
    """A bullet may wrap onto indented continuation lines, and the `#id` often lands on the
    last of them. Rejoin before parsing, padding so line numbers stay true."""
    out: list[str] = []
    open_idx = -1
    in_fence = False
    for line in lines:
        if FENCE.match(line):
            in_fence = not in_fence
            out.append(line)
            open_idx = -1
            continue
        if in_fence:
            out.append(line)
            continue
        is_bullet = bool(BULLET.match(line))
        is_heading = bool(HEADING.match(line))
        # An indented table directly under a bullet would otherwise be swallowed as that
        # bullet's continuation text and vanish from the report.
        is_table = bool(TABLE_ROW.match(line))
        cont = (open_idx >= 0 and line[:1].isspace() and line.strip()
                and not is_bullet and not is_heading and not is_table)
        if cont:
            out[open_idx] = out[open_idx] + " " + line.strip()
            out.append("")
        else:
            out.append(line)
            open_idx = len(out) - 1 if is_bullet else -1
    return out


def table_cells(raw: str) -> list[str]:
    inner = TABLE_ROW.match(raw).group(1)
    return [c.strip().replace("\\|", "|") for c in TABLE_CELL.split(inner)]


def is_delimiter_row(cells: list[str]) -> bool:
    """`|---|:--:|` - the row that separates a table's header from its body, and the only
    thing distinguishing a table from prose that starts with a pipe."""
    return bool(cells) and all(TABLE_DELIM_CELL.fullmatch(c) for c in cells)


def alignment_of(cells: list[str]) -> list[str]:
    def one(c: str) -> str:
        left, right = c.startswith(":"), c.endswith(":")
        return "center" if left and right else "right" if right else ""
    return [one(c) for c in cells]


def strip_marker(s: str) -> str:
    return re.sub(r"\s+", " ", MARKER_IN_DOC.sub("", s)).strip()


def marker_of(s: str) -> str | None:
    m = MARKER_IN_DOC.search(s)
    return normalise_id(m.group(1)) if m else None


def warn_markers_in_table(source: str, line: int, rows: list[list[str]]) -> None:
    """A table is prose, so a marker in a cell defines nothing. Say so rather than dropping
    it silently - the author meant to write a requirement and did not. Any test naming that
    id then fails as an orphan, which is the backstop if this warning is missed."""
    ids = [m.group(1) for row in rows for cell in row for m in MARKER_IN_DOC.finditer(cell)]
    for rid in ids:
        print(f"[reqreport] {source}:{line}: `#{rid}` is in a table cell, so it defines no "
              f"requirement - tables are prose. Move it to a heading or a bullet.",
              file=sys.stderr)


def parse_document(source: str, text: str) -> Doc:
    """Every line becomes a block, in order. Unmarked prose and headings are kept as they
    are - the report is the document, not a reconstruction of the marked lines."""
    lines = join_wrapped(text.splitlines())
    blocks: list[Block] = []
    para: list[str] = []
    para_line = 0

    def flush() -> None:
        nonlocal para
        if para:
            blocks.append(Block("para", " ".join(para), line=para_line))
            para = []

    i = 0
    while i < len(lines):
        raw = lines[i]
        n = i + 1

        fence = FENCE.match(raw)
        if fence:
            flush()
            body: list[str] = []
            close = fence.group(1)
            i += 1
            while i < len(lines) and not lines[i].strip().startswith(close):
                body.append(lines[i])
                i += 1
            blocks.append(Block("code", "\n".join(body), line=n, lang=fence.group(2).strip()))
            i += 1
            continue

        if not raw.strip():
            flush()
            i += 1
            continue

        h = HEADING.match(raw)
        if h:
            flush()
            blocks.append(Block("heading", strip_marker(h.group(2)), level=len(h.group(1)),
                                rid=marker_of(h.group(2)), line=n))
            i += 1
            continue

        b = BULLET.match(raw)
        if b:
            flush()
            blocks.append(Block("item", strip_marker(b.group(2)), level=len(b.group(1)) // 2,
                                rid=marker_of(b.group(2)), line=n))
            i += 1
            continue

        q = QUOTE.match(raw)
        if q:
            flush()
            blocks.append(Block("quote", strip_marker(q.group(1)), rid=marker_of(q.group(1)), line=n))
            i += 1
            continue

        if TABLE_ROW.match(raw):
            run = []
            j = i
            while j < len(lines) and TABLE_ROW.match(lines[j]):
                run.append(table_cells(lines[j]))
                j += 1
            # No delimiter row in second place and this is not a table: fall through and let
            # the lines be prose, which is what they were before tables were understood.
            if len(run) >= 2 and is_delimiter_row(run[1]):
                flush()
                align = alignment_of(run[1])
                rows = [run[0]] + run[2:]
                width = max(len(r) for r in rows)
                pad = lambda r, fill="": r + [fill] * (width - len(r))
                blocks.append(Block("table", line=n,
                                    rows=[pad(r) for r in rows], align=pad(align)))
                warn_markers_in_table(source, n, rows)
                i = j
                continue

        if RULE.match(raw):
            flush()
            blocks.append(Block("rule", line=n))
            i += 1
            continue

        if not para:
            para_line = n
        para.append(raw.strip())
        i += 1

    flush()
    return Doc(source, blocks)


def load_docs(root: Path) -> list[Doc]:
    if not root.is_dir():
        die(f"requirements directory not found: {root}")
    docs = [parse_document(str(p.relative_to(root)), p.read_text(encoding="utf-8"))
            for p in sorted(root.rglob("*.md")) if p.is_file()]
    if not any(d.marked for d in docs):
        die(f"no requirements found in {root} - is anything marked with a `#id`?")

    # An id is the join key. Two requirements sharing one both match the same test and
    # silently double-count as coverage, so this is fatal.
    seen: dict[str, list[str]] = {}
    for d in docs:
        for b in d.marked:
            seen.setdefault(b.rid, []).append(f"{d.source}:{b.line}")
    dupes = {k: v for k, v in seen.items() if len(v) > 1}
    if dupes:
        detail = "\n".join(f"  #{k} defined at {', '.join(v)}" for k, v in sorted(dupes.items()))
        die(f"duplicate requirement IDs:\n{detail}")
    return docs


# --------------------------------------------------------------------- test report

def load_tests(root: Path, known: set[str]) -> list[TestCase]:
    if not root.is_dir():
        die(f"test report directory not found: {root} - did the tests run?")
    cases: list[TestCase] = []
    for p in sorted(root.rglob("*.xml")):
        try:
            tree = ET.parse(p)
        except ET.ParseError as e:
            die(f"could not parse {p}: {e}")
        for e in tree.iter("testcase"):
            fail = e.find("failure")
            if fail is None:
                fail = e.find("error")
            cases.append(TestCase(
                name=e.get("name", ""),
                classname=e.get("classname", ""),
                failure=(fail.get("message") or "(no message)", (fail.text or "").strip())
                if fail is not None else None,
                skipped=e.find("skipped") is not None,
                ids=ids_in_name(e.get("name", ""), known),
            ))
    if not cases:
        die(f"no test cases found in {root} - did the tests run?")
    return cases


# ------------------------------------------------------------------- test sources

TRIPLE_QUOTED = re.compile(r'"""[\s\S]*?"""|\'\'\'[\s\S]*?\'\'\'')
STRING_LITERAL = re.compile(r"""(["'])(?:\\.|(?!\1).)*\1""")
IDENTIFIER = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
DEFINITION = re.compile(
    r"^\s*(?:pub\s+|public\s+|private\s+|protected\s+|export\s+|default\s+|async\s+|"
    r"static\s+|final\s+|override\s+)*(?:fn|def|func|function|sub|method)\s+"
)


def decode(line: str) -> str:
    """Strip string literals, so a requirement's own words are not read as identifiers."""
    return STRING_LITERAL.sub(" ", TRIPLE_QUOTED.sub(" ", line))


def definition_line(lines: list[str], name: str) -> int | None:
    pat = re.compile(DEFINITION.pattern + re.escape(name) + r"\b")
    for i, line in enumerate(lines):
        if pat.match(line):
            return i
    return None


def enclosing_call(lines: list[str], marked: int) -> tuple[int, int] | None:
    """The span of a *multi-line* call containing the marker, if there is one. A call that
    fits on the marked line is not one - that is the ordinary `test("#id …") { … }` shape,
    where the marker is already at the test body."""
    start = None
    depth = 0
    for i in range(marked, max(-1, marked - 6), -1):
        line = decode(lines[i])
        depth += line.count(")") - line.count("(")
        if depth < 0:
            start = i
            break
    if start is None:
        return None
    depth = 0
    for j in range(start, min(len(lines), start + 12)):
        depth += decode(lines[j]).count("(") - decode(lines[j]).count(")")
        if depth <= 0 and j > start:
            return start, j + 1
    return start, min(len(lines), start + 12)


def referenced_definition(lines: list[str], marked: int) -> int | None:
    """Some frameworks register a test *name* separately from its *body* - libtest-mimic's
    `Trial::test("#id …", live_ok)`, table-driven Go tests, `test.each` data tables. The
    marker then sits in a registry, so the block around it is the registry, and every
    requirement would show the same chunk."""
    span = enclosing_call(lines, marked)
    if span is None:
        return None
    for i in range(*span):
        if DEFINITION.match(lines[i]):
            continue
        for name in IDENTIFIER.findall(decode(lines[i])):
            at = definition_line(lines, name)
            if at is not None and at != marked:
                return at
    return None


def enclosing_definition(lines: list[str], marked: int) -> int:
    """The marker is often inside the block rather than on the line that opens it - a
    Python docstring, say. Walk back to the nearest less-indented line that opens a block."""
    head = lines[marked]
    if "{" in head or head.rstrip().endswith(":"):
        return marked
    indent = len(head) - len(head.lstrip())
    for i in range(marked - 1, max(-1, marked - 11), -1):
        line = lines[i]
        if not line.strip():
            continue
        if (len(line) - len(line.lstrip())) < indent and (line.rstrip().endswith(":") or "{" in line):
            return i
    return marked


def extract_block(lines: list[str], marked: int) -> str:
    """Balanced braces where the language has them, dedent where it does not, window
    otherwise. Crude, and adequate for a report."""
    start = enclosing_definition(lines, marked)
    rest = lines[start:]
    head = rest[0] if rest else ""
    if "{" in head:
        depth, out = 0, []
        for line in rest:
            out.append(line)
            depth += line.count("{") - line.count("}")
            if depth <= 0 and out:
                break
        return "\n".join(out[:60])
    if head.rstrip().endswith(":"):
        indent = len(head) - len(head.lstrip())
        out = [head]
        for line in rest[1:]:
            if line.strip() and (len(line) - len(line.lstrip())) <= indent:
                break
            out.append(line)
        return "\n".join(out[:60])
    return "\n".join(rest[:15])


def display_path(p: Path, project_root: Path) -> str:
    """The path as the report should show it: relative to the project root. Build tools pass
    --sources absolute, and an absolute path in the report is both noise and a record of the
    machine that happened to build it, so two people rendering the same commit get different
    pages.

    `project_root` comes from --root, which the build tool sets from the project root it
    already knows, and falls back to the working directory. Deriving it instead - from git,
    or by walking up for a marker file - finds the *repository* root, which is the project
    root only when the two coincide; in a monorepo it prefixes every path with the project's
    own directory name.

    Named in full because `index_sources` iterates the *source* roots in a variable called
    `root`, and a parameter of that name is silently shadowed by it: every path then comes
    out relative to whichever source root it was found under.

    A file outside the project keeps its absolute path - a `../../..` chain out of the tree
    locates it no better and reads worse."""
    try:
        return str(p.resolve().relative_to(project_root))
    except (ValueError, OSError):
        return str(p)


def index_sources(roots: list[Path], known: set[str],
                  project_root: Path) -> dict[str, tuple[str, int, str]]:
    """id -> (file, line, code). Shown behind a disclosure so a developer or an agent can
    see whether the test matches the requirement it claims - the one check no mechanism
    can make. Paths are rendered relative to `project_root`; see `display_path`."""
    found: dict[str, tuple[str, int, str]] = {}
    origin: dict[str, tuple[str, int]] = {}
    for root in roots:
        if not root.is_dir():
            continue
        for p in sorted(root.rglob("*")):
            if not p.is_file() or p.suffix not in SOURCE_SUFFIXES:
                continue
            try:
                lines = p.read_text(encoding="utf-8", errors="replace").splitlines()
            except OSError:
                continue
            for i, line in enumerate(lines):
                for rid in ids_in_name(line, known):
                    if rid in found:
                        continue
                    body = referenced_definition(lines, i)
                    start = body if body is not None else enclosing_definition(lines, i)
                    # Both carry the display path: `origin` is regrouped back into `found`
                    # below, so an absolute path here would reappear in the report.
                    shown = display_path(p, project_root)
                    found[rid] = (shown, start + 1, extract_block(lines, start))
                    origin[rid] = (shown, start)

    # If several ids resolve to the same block, the extraction failed rather than found
    # something - they are pointing at a registry or a shared wrapper. Repeating one large
    # chunk under every requirement is worse than showing nothing.
    shared: dict[tuple[str, int], list[str]] = {}
    for rid, key in origin.items():
        shared.setdefault(key, []).append(rid)
    for key, ids in shared.items():
        if len(ids) > 1:
            for rid in ids:
                found[rid] = (key[0], found[rid][1],
                              "(several requirements resolve to the same block, so this is "
                              "probably a registry rather than a test body - open the file "
                              "to see what this requirement actually checks)")
    return found


# ------------------------------------------------------------------------- render

def esc(s: str) -> str:
    return html.escape(s, quote=False)


CODE_SPAN = re.compile(r"`([^`]+)`")
BOLD = re.compile(r"\*\*([^*]+)\*\*")
ITALIC = re.compile(r"(?<!\*)\*([^*\s][^*]*)\*(?!\*)")
LINK = re.compile(r"\[([^\]]+)\]\(([^)\s]+)\)")


def inline(s: str) -> str:
    """Just enough Markdown for requirement prose. Code spans are lifted out first so
    emphasis inside them is left alone."""
    spans: list[str] = []

    def keep(m: re.Match) -> str:
        spans.append(m.group(1))
        return f"\x00{len(spans) - 1}\x00"

    s = CODE_SPAN.sub(keep, s)
    s = esc(s)
    s = LINK.sub(lambda m: f'<a href="{esc(m.group(2))}">{m.group(1)}</a>', s)
    s = BOLD.sub(r"<strong>\1</strong>", s)
    s = ITALIC.sub(r"<em>\1</em>", s)
    return re.sub(r"\x00(\d+)\x00", lambda m: f"<code>{esc(spans[int(m.group(1))])}</code>", s)


CSS = """
 :root { --pass:#1a7f37; --fail:#b3261e; --untested:#8a6d00; --skipped:#6b7280; --line:#d8dbe0; }
 body { font: 16px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
        margin: 0 auto; max-width: 58rem; padding: 2rem 1.5rem 6rem; color: #1a1c1e; }
 h1 { font-size: 1.6rem; margin: 0 0 .25rem; }
 a { color: #0b5cad; }
 .meta { color:#5b5f66; font-size:.875rem; margin-bottom:1.5rem; }
 .counts { display:flex; gap:.5rem; flex-wrap:wrap; margin:0 0 1.5rem; padding:0; list-style:none; }
 .counts li { border:1px solid var(--line); border-radius:.4rem; padding:.35rem .7rem; font-size:.875rem; }
 .counts b { font-variant-numeric: tabular-nums; }
 table { border-collapse: collapse; width:100%; font-size:.9rem; }
 th, td { text-align:left; padding:.5rem .6rem; border-bottom:1px solid var(--line); vertical-align:top; }
 th { font-size:.75rem; text-transform:uppercase; letter-spacing:.05em; color:#5b5f66; }
 td.num { text-align:right; font-variant-numeric: tabular-nums; width:5rem; }
 .tablewrap { margin:.75rem 0 1.25rem; overflow-x:auto; }
 .tablewrap table { width:auto; min-width:min(100%, 24rem); }
 .tablewrap th { white-space:nowrap; }

 /* the document, rendered as written */
 .doc h2 { font-size:1.25rem; margin:2rem 0 .5rem; padding-bottom:.2rem;
           border-bottom:1px solid var(--line); }
 .doc h3 { font-size:1.05rem; margin:1.5rem 0 .4rem; }
 .doc h4, .doc h5, .doc h6 { font-size:.95rem; margin:1.2rem 0 .3rem; }
 .doc p { margin:.6rem 0; }
 .doc blockquote { margin:.6rem 0; padding:.1rem 0 .1rem .9rem; border-left:3px solid var(--line);
                   color:#4a4e54; }
 .doc hr { border:0; border-top:1px solid var(--line); margin:2rem 0; }
 .item { margin:.15rem 0; padding:.1rem 0; }
 .line { display:flex; gap:.55rem; align-items:baseline; }
 .bullet { color:#9aa0a6; }
 .marked { border-left:3px solid var(--line); padding-left:.8rem; margin:.4rem 0; }
 .marked.pass { border-left-color: var(--pass); } .marked.fail { border-left-color: var(--fail); }
 .marked.untested { border-left-color: var(--untested); }
 .marked.skipped { border-left-color: var(--skipped); }
 .tag { font-size:.68rem; font-weight:700; letter-spacing:.04em; padding:.1rem .4rem;
        border-radius:.25rem; white-space:nowrap; color:#fff; }
 .tag.pass{background:var(--pass)} .tag.fail{background:var(--fail)}
 .tag.untested{background:var(--untested)} .tag.skipped{background:var(--skipped)}
 h2 .tag, h3 .tag, h4 .tag { font-size:.6rem; vertical-align:middle; }
 .id { font: .78rem ui-monospace, SFMono-Regular, Menlo, monospace; color:#8a9099; }
 .note { color:#5b5f66; font-size:.9rem; margin:.2rem 0 0; }
 details { margin:.4rem 0 .2rem; } summary { cursor:pointer; font-size:.85rem; color:#5b5f66; }
 pre { background:#f6f7f9; border:1px solid var(--line); border-radius:.4rem; padding:.75rem;
       overflow:auto; font-size:.8rem; line-height:1.45; }
 .msg { background:#fdf0ef; border:1px solid #f3c6c2; border-radius:.4rem; padding:.5rem .7rem;
        font-size:.85rem; margin:.35rem 0; }
 section.aside { margin-top:2.5rem; } section.aside h2 { font-size:1rem; border:0; }
 #filter { width:100%; padding:.5rem .7rem; font-size:.9rem; border:1px solid var(--line);
           border-radius:.4rem; margin-bottom:1rem; }
"""

FILTER_JS = """
function f(q){q=q.toLowerCase();
 document.querySelectorAll('#doc .marked').forEach(function(e){
   e.style.display = !q || e.innerText.toLowerCase().includes(q) ? '' : 'none';});}
"""


def shell(title: str, body: str) -> str:
    return (f'<!doctype html>\n<html lang="en-GB"><head><meta charset="utf-8">'
            f"<title>{esc(title)}</title>\n<style>{CSS}</style></head><body>\n{body}\n</body></html>\n")


def badge(status: str) -> str:
    return f'<span class="tag {status}">{LABEL[status]}</span>'


def tests_html(rid: str, tests: list[TestCase], src) -> str:
    snip = src.get(rid)
    snippet = (f"<pre>{esc(snip[0])}:{snip[1]}\n\n{esc(snip[2])}</pre>" if snip
               else '<p class="note">Test source not found.</p>')
    out = []
    for c in tests:
        if c.failure is None:
            out.append(f"<details><summary>test: <code>{esc(c.name)}</code> &mdash; passed"
                       f"</summary>{snippet}</details>")
        else:
            msg, detail = c.failure
            head = "\n".join(detail.splitlines()[:12])
            out.append(f'<div class="msg"><strong>{esc(msg)}</strong></div>'
                       "<details open><summary>what was tested, and why it failed</summary>"
                       f"{snippet}<pre>{esc(head)}</pre></details>")
    if not tests:
        out.append('<p class="note">No test names this requirement, so nothing '
                   "demonstrates it works.</p>")
    return "".join(out)


def render_doc_body(r: DocResult, src) -> str:
    """The document, in order, with status and test detail folded in at the marked lines."""
    out: list[str] = []
    for i, b in enumerate(r.doc.blocks):
        status = r.status_of.get(b.rid) if b.rid else None
        tag_id = f'<span class="id">#{esc(b.rid)}</span>' if b.rid else ""

        if b.kind == "heading":
            roll = r.rollup.get(i)
            shown = status or roll
            tag = badge(shown) if shown else ""
            level = min(max(b.level, 2), 6)
            out.append(f"<h{level}>{tag} {inline(b.text)} {tag_id}</h{level}>")
            # A marked heading with no tests of its own is satisfied by what sits under it;
            # only say "no test" when nothing below covers it either.
            own = r.tests_of.get(b.rid, []) if b.rid else []
            if b.rid and (own or roll is None):
                out.append(f'<div class="marked {status}">{tests_html(b.rid, own, src)}</div>')
        elif b.kind == "item":
            indent = f' style="margin-left:{b.level * 1.2:.1f}rem"' if b.level else ""
            if b.rid:
                body = (f'<div class="line"><span class="bullet">&bull;</span>{badge(status)} '
                        f"<span>{inline(b.text)}</span> {tag_id}</div>"
                        f"{tests_html(b.rid, r.tests_of.get(b.rid, []), src)}")
                out.append(f'<div class="item marked {status}"{indent}>{body}</div>')
            else:
                out.append(f'<div class="item"{indent}><div class="line">'
                           f'<span class="bullet">&bull;</span>'
                           f"<span>{inline(b.text)}</span></div></div>")
        elif b.kind == "para":
            out.append(f"<p>{inline(b.text)}</p>")
        elif b.kind == "quote":
            out.append(f"<blockquote>{inline(b.text)}</blockquote>")
        elif b.kind == "code":
            out.append(f"<pre>{esc(b.text)}</pre>")
        elif b.kind == "table":
            def cells(tag: str, row: list[str]) -> str:
                return "".join(
                    f'<{tag}{f" style=\"text-align:{a}\"" if a else ""}>{inline(c)}</{tag}>'
                    for c, a in zip(row, b.align))
            head = f"<tr>{cells('th', b.rows[0])}</tr>"
            body = "".join(f"<tr>{cells('td', row)}</tr>" for row in b.rows[1:])
            out.append(f'<div class="tablewrap"><table><thead>{head}</thead>'
                       f"<tbody>{body}</tbody></table></div>")
        elif b.kind == "rule":
            out.append("<hr>")
    return "\n".join(out)


def index_html(results: list[DocResult], orphans, unmarked, stamp: str) -> str:
    def total(s):
        return sum(r.count(s) for r in results)

    rows = "".join(
        f"<tr>\n <td>{badge(r.status)}</td>\n"
        f' <td><a href="{esc(r.page)}">{esc(r.doc.source)}</a>'
        + (f'<div class="note">{esc(", ".join(r.classes))}</div>' if r.classes
           else '<div class="note">no tests</div>')
        + f'</td>\n <td class="num">{r.count(PASS)}</td>'
          f'<td class="num">{r.count(FAIL)}</td>'
          f'<td class="num">{r.count(UNTESTED)}</td>\n</tr>'
        for r in results)

    return shell("Requirements", f"""<h1>Requirements</h1>
<p class="meta">Generated {stamp}. One page per document. Status comes from the test run;
nothing here is written by hand.</p>
<ul class="counts">
 <li><b>{len(results)}</b> documents</li>
 <li><b>{total(PASS)}</b> passing</li>
 <li><b>{total(FAIL)}</b> failing</li>
 <li><b>{total(UNTESTED)}</b> with no test</li>
</ul>
<table><thead><tr><th></th><th>Document / tests</th><th class="num">Pass</th>
<th class="num">Fail</th><th class="num">No test</th></tr></thead><tbody>{rows}</tbody></table>
{asides_html(orphans, unmarked)}""")


def doc_html(r: DocResult, src, up: str, stamp: str) -> str:
    covered = (f"Covered by <code>{esc('</code>, <code>'.join(r.classes))}</code>." if r.classes
               else "No tests name any requirement in this document.")
    return shell(r.doc.source, f"""<p class="meta"><a href="{esc(up)}">&larr; all requirements</a></p>
<p class="meta">Generated {stamp}. Source: <code>{esc(r.doc.source)}</code>. {covered}</p>
<ul class="counts">
 <li><b>{r.count(PASS)}</b> passing</li>
 <li><b>{r.count(FAIL)}</b> failing</li>
 <li><b>{r.count(UNTESTED)}</b> with no test</li>
</ul>
<input id="filter" placeholder="Filter requirements&hellip;" oninput="f(this.value)">
<div class="doc" id="doc">{render_doc_body(r, src)}</div>
<script>{FILTER_JS}</script>""")


def asides_html(orphans: list[TestCase], unmarked: list[TestCase]) -> str:
    out = ""
    if orphans:
        items = "".join(f"<li><code>{esc(c.name)}</code> "
                        f'<span class="note">{esc(c.classname)}</span></li>' for c in orphans)
        out += ('<section class="aside"><h2>Tests naming a requirement that does not exist</h2>'
                f"<ul>{items}</ul></section>")
    if unmarked:
        items = "".join(f"<li><code>{esc(c.name)}</code></li>" for c in unmarked)
        out += (f'<section class="aside"><h2>Tests not linked to any requirement ({len(unmarked)})</h2>'
                '<p class="note">Not an error &mdash; unit tests need not map to a requirement. '
                "Listed so the gap is visible.</p>"
                f"<details><summary>show</summary><ul>{items}</ul></details></section>")
    return out


# --------------------------------------------------------------------------- main

def die(msg: str) -> None:
    print(f"reqreport: {msg}", file=sys.stderr)
    sys.exit(2)


def status_for(tests: list[TestCase]) -> str:
    if not tests:
        return UNTESTED
    if any(t.failure for t in tests):
        return FAIL
    if any(t.skipped for t in tests):
        return SKIPPED
    return PASS


def rollup_for(doc: Doc, status_of: dict[str, str]) -> dict[int, str]:
    """A heading takes the worst status of the marked lines beneath it, whether or not it
    carries an id of its own. Structure comes from the document, not from markers."""
    roll: dict[int, str] = {}
    for i, b in enumerate(doc.blocks):
        if b.kind != "heading":
            continue
        worst, seen = PASS, False
        for later in doc.blocks[i + 1:]:
            if later.kind == "heading" and later.level <= b.level:
                break
            if later.rid:
                seen = True
                if SEVERITY[status_of[later.rid]] > SEVERITY[worst]:
                    worst = status_of[later.rid]
        if seen:
            roll[i] = worst
    return roll


def main() -> int:
    ap = argparse.ArgumentParser(description="Render requirements with their test results.")
    # Every path defaults to None so an explicit flag, the config file, and the built-in
    # default can be told apart. Giving argparse a default here silently beat the config
    # file, because `get_default` returns the raw value while `parse_args` returns it
    # converted by `type`, so the two never compared equal.
    ap.add_argument("--requirements", type=Path)
    ap.add_argument("--junit", type=Path, help="directory of JUnit XML")
    ap.add_argument("--sources", nargs="*", default=[], type=Path, help="test source roots")
    ap.add_argument("--out", type=Path)
    ap.add_argument("--root", type=Path,
                    help="project root that source paths in the report are relative to "
                         "(default: the working directory)")
    ap.add_argument("--config", default=Path(".reqreport.json"), type=Path)
    ap.add_argument("--no-gate", action="store_true", help="write the report but always exit 0")
    args = ap.parse_args()

    cfg = {}
    if args.config.is_file():
        try:
            cfg = json.loads(args.config.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            die(f"{args.config}: {e}")

    for key, fallback in (("requirements", "requirements"), ("junit", None),
                          ("out", "target/requirements"), ("root", None)):
        if getattr(args, key) is None:
            value = cfg.get(key, fallback)
            setattr(args, key, Path(value) if value is not None else None)
    if not args.sources:
        args.sources = [Path(s) for s in cfg.get("sources", [])]

    # Resolved once, because display_path compares it against resolved source paths and a
    # symlinked or relative root would never match one.
    args.root = (args.root or Path.cwd()).resolve()

    if args.junit is None:
        die("--junit is required (the directory your test runner writes JUnit XML to), "
            'or set "junit" in .reqreport.json')

    docs = load_docs(args.requirements)
    known = {b.rid for d in docs for b in d.marked}
    cases = load_tests(args.junit, known)
    src = index_sources(args.sources or [Path("src/test"), Path("test"), Path("tests")],
                        known, args.root)
    stamp = datetime.now().strftime("%-d %b %Y %H:%M")

    by_id: dict[str, list[TestCase]] = {}
    for c in cases:
        for i in c.ids:
            by_id.setdefault(i, []).append(c)

    # An id may name at most one test. When several tests shared an id the report showed
    # the first one's source under every row, so a row's code did not match the row's own
    # name - and that adjacency is the only check on a test that names one requirement and
    # tests another. Fatal for the same reason a duplicate document id is: the join key is
    # ambiguous, and a wrong join reads exactly like a right one.
    named_by: dict[str, list[str]] = {}
    for c in cases:
        where = f"{c.classname}.{c.name}" if c.classname else c.name
        for i in c.ids:
            if where not in named_by.setdefault(i, []):
                named_by[i].append(where)
    shared = {k: v for k, v in named_by.items() if len(v) > 1}
    if shared:
        detail = "\n".join(
            f"  #{k} is named by {len(v)} tests:\n" + "\n".join(f"      {n}" for n in v)
            for k, v in sorted(shared.items()))
        die("a requirement may be named by only one test:\n" + detail +
            "\n  Split the requirement so each test has its own id, or merge the tests.")

    results: list[DocResult] = []
    for d in docs:
        tests_of = {b.rid: by_id.get(b.rid, []) for b in d.marked}
        status_of = {rid: status_for(ts) for rid, ts in tests_of.items()}
        roll = rollup_for(d, status_of)
        # A marked heading is satisfied by what sits under it; being a grouping node does
        # not oblige it to have a test of its own.
        for i, b in enumerate(d.blocks):
            if b.rid and b.kind == "heading" and not tests_of[b.rid] and i in roll:
                status_of[b.rid] = roll[i]
        results.append(DocResult(
            doc=d,
            page=re.sub(r"\.md$", ".html", d.source),
            status_of=status_of,
            tests_of=tests_of,
            rollup=roll,
            classes=sorted({t.classname for ts in tests_of.values() for t in ts}),
        ))

    orphans = [c for c in cases if c.ids and not all(i in known for i in c.ids)]
    unmarked = [c for c in cases if not c.ids]

    args.out.mkdir(parents=True, exist_ok=True)
    for r in results:
        page = args.out / r.page
        page.parent.mkdir(parents=True, exist_ok=True)
        up = "../" * r.page.count("/") + "index.html"
        page.write_text(doc_html(r, src, up, stamp), encoding="utf-8")
    (args.out / "index.html").write_text(index_html(results, orphans, unmarked, stamp), encoding="utf-8")

    print(f"[reqreport] {(args.out / 'index.html').resolve()}")
    for r in results:
        print(f"[reqreport]   {r.doc.source:<28} pass={r.count(PASS):<3} fail={r.count(FAIL):<3} "
              f"no-test={r.count(UNTESTED):<3} -> {r.page}")

    problems = (
        [f"{r.doc.source} #{rid}: failing" for r in results
         for rid, s in r.status_of.items() if s == FAIL]
        + [f"{r.doc.source} #{rid}: no test covers this" for r in results
           for rid, s in r.status_of.items() if s == UNTESTED]
        + [f"{c.name}: names a requirement that does not exist" for c in orphans]
    )
    for p in problems:
        print(f"[reqreport]   {p}")

    if problems and not args.no_gate:
        print(f"[reqreport] {len(problems)} requirement problem(s)", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
