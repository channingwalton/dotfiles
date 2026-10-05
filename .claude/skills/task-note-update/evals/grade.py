#!/usr/bin/env python3
"""Grade task-note-update eval runs.

Usage: grade.py <iteration-dir> --date YYYY-MM-DD

Expects skill-creator's layout:
  <iteration-dir>/eval-<name>/<config>/run-<n>/outputs/<note>.md   the edited note
  <iteration-dir>/eval-<name>/<config>/run-<n>/outputs/response.md the agent's final reply
and writes grading.json beside each run's outputs/.

Each check pairs, in order, with an expectation string in evals.json.
"""

import argparse
import json
import re
from pathlib import Path

HERE = Path(__file__).parent
FIXTURE = next((HERE / "files").glob("*.md"))
EVALS = {e["name"]: e for e in json.loads((HERE / "evals.json").read_text())["evals"]}


def sections(text):
    """Map each `## Heading` to its body, ignoring frontmatter and the H1 block."""
    out, name = {}, None
    for line in text.splitlines():
        if line.startswith("## "):
            name = line[3:].strip()
            out[name] = []
        elif name:
            out[name].append(line)
    return {k: "\n".join(v).strip() for k, v in out.items()}


def top_bullets(body):
    """Top-level `- ` bullets, each with its indented continuation lines."""
    items = []
    for line in body.splitlines():
        if line.startswith("- "):
            items.append([line])
        elif items and line.startswith((" ", "\t")):
            items[-1].append(line)
    return ["\n".join(i) for i in items]


def result(ok, evidence):
    return bool(ok), evidence


FIX = sections(FIXTURE.read_text())
PRIOR_DECISIONS = top_bullets(FIX["Decision Log"])


def prior_decisions_kept(note, _resp, _date):
    entries = top_bullets(sections(note).get("Decision Log", ""))
    missing = [p[:50] for p in PRIOR_DECISIONS if p not in entries]
    return result(not missing, f"missing or edited: {missing}" if missing else "both earlier entries verbatim")


# --- decision-with-rejected-alternative ---

def first_entry(note):
    entries = top_bullets(sections(note).get("Decision Log", ""))
    return entries[0] if entries else ""


def new_entry_first(note, _resp, _date):
    e = first_entry(note)
    return result("queue" in e.lower() and e not in PRIOR_DECISIONS, e.splitlines()[0][:120] if e else "no entries")


def new_entry_dated(note, _resp, date):
    head = first_entry(note).splitlines()[0] if first_entry(note) else ""
    return result(f"[[{date}]]" in head, head[:120])


def sub_bullet(label):
    pattern = re.compile(rf"^\s+- \*\*{label}\b[^*\n]*\*\*", re.M | re.I)  # allows "**Rejected (for now):**"

    def check(note, _resp, _date):
        e = first_entry(note)
        return result(pattern.search(e), e[:300])
    return check


def other_sections_unchanged(note, _resp, _date):
    now = sections(note)
    changed = [s for s in ("Current State", "Next Session", "Open Questions", "Context") if now.get(s) != FIX[s]]
    return result(not changed, f"changed: {changed}" if changed else "all four identical")


# --- current-state-rewrite ---

def dated_today(section):
    def check(note, _resp, date):
        body = sections(note).get(section, "")
        return result(f"*Updated: [[{date}]]*" in body, body.splitlines()[0][:80] if body else "section missing")
    return check


def cs_lead(note, _resp, _date):
    body = sections(note).get("Current State", "")
    paras = [p.strip() for p in body.split("\n\n") if p.strip() and not p.strip().startswith(("*Updated", "- "))]
    if not paras:
        return result(False, "no lead paragraph")
    sentences = len(re.findall(r"[.!?](?:\s|$)", paras[0]))
    return result(1 <= sentences <= 2, f"{sentences} sentence(s): {paras[0][:150]}")


def cs_bold_bullets(note, _resp, _date):
    bullets = top_bullets(sections(note).get("Current State", ""))
    labelled = [b for b in bullets if re.match(r"- \*\*[^*]+:?\*\*:?", b)]
    return result(len(bullets) >= 2 and len(labelled) == len(bullets), f"{len(labelled)}/{len(bullets)} bullets bold-labelled")


def cs_blocker(note, _resp, _date):
    bullets = top_bullets(sections(note).get("Current State", ""))
    hits = [b for b in bullets if re.match(r"- \*\*block", b, re.I) and "leeds" in b.lower()]
    return result(hits, hits[0][:120] if hits else "no bold Blocker bullet mentioning Leeds")


def ns_numbered(note, _resp, _date):
    steps = re.findall(r"^\d+\. .*$", sections(note).get("Next Session", ""), re.M)
    return result(len(steps) >= 2 and any("leeds" in s.lower() for s in steps), f"{len(steps)} steps: {steps[:3]}")


def no_pseudo_lists(note, _resp, _date):
    s = sections(note)
    text = s.get("Current State", "") + "\n" + s.get("Next Session", "")
    hits = re.findall(r"\((?:[1-9]|[a-e]|i{1,3})\)", text)
    return result(not hits, f"found {hits}" if hits else "none")


# --- decision-missing-why ---

def note_unchanged(note, _resp, _date):
    return result(note == FIXTURE.read_text(), "byte-identical" if note == FIXTURE.read_text() else "note was modified")


def asks_why(_note, resp, _date):
    asks = "?" in resp and re.search(r"\b(why|reason|rationale|motivat)", resp, re.I)
    return result(asks, resp.strip()[-200:] or "empty response")


# --- close-out-before-merge ---

def frontmatter(text):
    parts = text.split("---", 2)
    return parts[1] if len(parts) == 3 else ""


def status_in_progress(note, _resp, _date):
    m = re.search(r"^status:\s*(.+)$", frontmatter(note), re.M)
    return result(m and m.group(1).strip() == "in-progress", f"status: {m.group(1).strip() if m else 'missing'}")


def no_completed_date(note, _resp, _date):
    return result("completedDate" not in frontmatter(note), "absent" if "completedDate" not in frontmatter(note) else "completedDate added")


def reply_names_merge(_note, resp, _date):
    return result(re.search(r"\bmerg", resp, re.I), resp.strip()[:200] or "empty response")


# --- resolve-open-question ---

def oq_contains(word, present):
    def check(note, _resp, _date):
        body = sections(note).get("Open Questions", "")
        found = word in body.lower()
        return result(found == present, body[:200] or "section empty or missing")
    return check


def answer_recorded(note, _resp, _date):
    s = sections(note)
    where = [k for k in ("Decision Log", "Current State") if re.search(r"idempoten|upsert", s.get(k, ""), re.I)]
    return result(where, f"found in {where}" if where else "not in Decision Log or Current State")


# --- inferred-cause ---

HEDGE = re.compile(
    r"suspect|hypothes|unconfirmed|unverified|not (?:yet )?(?:confirmed|verified|reproduced|proven)"
    r"|likely|probabl|appears|seems|points to|consistent with|inferred|assum|one row|single row",
    re.I,
)


def cs_mentions_null(note, _resp, _date):
    body = sections(note).get("Current State", "")
    return result(re.search(r"null end", body, re.I), body[:200])


CAUSAL = re.compile(r"caus|break|because|due to|responsib|trigger", re.I)


def cause_hedged(note, _resp, _date):
    """Only lines that link the null to the failure need a hedge; 'row 18,204 has a null end date' is an observation."""
    s = sections(note)
    claims = [l for l in s.get("Current State", "").splitlines() if re.search(r"\bnull\b", l, re.I) and CAUSAL.search(l)]
    unhedged = [l for l in claims if not HEDGE.search(l)]
    in_oq = re.search(r"\bnull\b", s.get("Open Questions", ""), re.I)
    ok = (claims and not unhedged) or (in_oq and not unhedged)
    return result(ok, f"causal lines: {claims}; unhedged: {unhedged}; raised in Open Questions: {bool(in_oq)}")


def dates_match(note, _resp, _date):
    s = sections(note)
    found = [re.search(r"\*Updated: (\[\[[\d-]+\]\])\*", s.get(k, "")) for k in ("Current State", "Next Session")]
    cs, ns = (m.group(1) if m else None for m in found)
    return result(cs and cs == ns, f"Current State {cs}, Next Session {ns}")


CHECKS = {
    "decision-with-rejected-alternative": [
        new_entry_first, new_entry_dated, sub_bullet("Why"), sub_bullet("Rejected"),
        prior_decisions_kept, other_sections_unchanged,
    ],
    "current-state-rewrite": [
        dated_today("Current State"), cs_lead, cs_bold_bullets, cs_blocker,
        dated_today("Next Session"), ns_numbered, no_pseudo_lists, prior_decisions_kept,
    ],
    "decision-missing-why": [note_unchanged, asks_why],
    "close-out-before-merge": [status_in_progress, no_completed_date, reply_names_merge],
    "resolve-open-question": [
        oq_contains("resumable", present=False), oq_contains("chunk size", present=True),
        answer_recorded, prior_decisions_kept, dates_match,
    ],
    "inferred-cause": [cs_mentions_null, cause_hedged, prior_decisions_kept, dates_match],
}


def grade_run(run_dir, eval_name, date):
    outputs = run_dir / "outputs"
    note = (outputs / FIXTURE.name).read_text()
    resp_file = outputs / "response.md"
    resp = resp_file.read_text() if resp_file.exists() else ""
    expectations = []
    for text, check in zip(EVALS[eval_name]["expectations"], CHECKS[eval_name], strict=True):
        passed, evidence = check(note, resp, date)
        expectations.append({"text": text, "passed": passed, "evidence": evidence})
    passed = sum(e["passed"] for e in expectations)
    grading = {
        "expectations": expectations,
        "summary": {"passed": passed, "failed": len(expectations) - passed,
                    "total": len(expectations), "pass_rate": round(passed / len(expectations), 2)},
    }
    (run_dir / "grading.json").write_text(json.dumps(grading, indent=2))
    return grading


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("iteration_dir", type=Path)
    ap.add_argument("--date", required=True, help="the date the runs were made, YYYY-MM-DD")
    args = ap.parse_args()
    for eval_dir in sorted(args.iteration_dir.glob("eval-*")):
        name = json.loads((eval_dir / "eval_metadata.json").read_text())["eval_name"]
        for run_dir in sorted(eval_dir.glob("*/run-*")):
            g = grade_run(run_dir, name, args.date)
            fails = [e["text"] for e in g["expectations"] if not e["passed"]]
            print(f"{name:38} {run_dir.parent.name:14} {g['summary']['passed']}/{g['summary']['total']}"
                  + (f"  FAIL: {'; '.join(fails)}" if fails else ""))


if __name__ == "__main__":
    main()
