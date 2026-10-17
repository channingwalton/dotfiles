#!/usr/bin/env python3
"""
Topic helpers for an Obsidian project with Topics/, Tasks/ and Events/ sub-folders.
Tasks and Events attach to Topics through the `topics:` frontmatter list.

Read commands (audit, clusters, linkcheck, crosscut) only print findings. The one
write command (backlink) is dry-run by default and needs --apply to touch files.

Usage:
  python3 topic_tools.py audit     --project DIR
  python3 topic_tools.py clusters  --project DIR [--keywords map.json] [--min 4]
  python3 topic_tools.py backlink  --project DIR --map "Topic=regex" [...] [--exclude file] [--apply]
  python3 topic_tools.py linkcheck --project DIR [--vault VAULT_DIR]
  python3 topic_tools.py crosscut  --project DIR [--max-words 40]

DIR is a project folder, e.g. ~/Documents/Notes/Projects/TXPLabs
"""
import argparse, glob, json, os, re
from collections import Counter

LINK = re.compile(r'\[\[([^\]]+)\]\]')
STRUCTURAL = ('topics', 'tasks', 'events', 'projects')   # folder/index/breadcrumb names

def base(p): return os.path.splitext(os.path.basename(p))[0]
def read(p): return open(p, encoding='utf-8').read()
def write(p, s): open(p, 'w', encoding='utf-8').write(s)

def md_files(*dirs):
    out = []
    for d in dirs:
        if d and os.path.isdir(d):
            out += glob.glob(os.path.join(d, '**', '*.md'), recursive=True)
    return out

def split_frontmatter(txt):
    """Return (frontmatter_text or None, body). Frontmatter closes at the first --- after line 0."""
    lines = txt.split('\n')
    if lines and lines[0].strip() == '---':
        for i in range(1, len(lines)):
            if lines[i].strip() == '---':
                return '\n'.join(lines[1:i]), '\n'.join(lines[i + 1:])
    return None, txt

def body_text(txt):
    return split_frontmatter(txt)[1]

def fm_list(fm, key):
    """Values of a YAML list field `key:` in frontmatter text; [] for `key: []` or absent."""
    if fm is None:
        return []
    m = re.search(r'^' + re.escape(key) + r':[ \t]*(.*)$', fm, re.M)
    if not m:
        return []
    inline = m.group(1).strip()
    if inline:
        if inline.startswith('[') and inline.endswith(']'):
            inner = inline[1:-1].strip()
            return [v.strip().strip('"\'') for v in inner.split(',')] if inner else []
        return [inline.strip('"\'')]
    rest = fm[m.end():]
    out = []
    for line in rest.split('\n'):
        im = re.match(r'^\s+-\s*(.+?)\s*$', line)
        if not im:
            break
        out.append(im.group(1).strip().strip('"\''))
    return out

def link_name(raw):
    return raw.replace(r'\|', '|').split('|')[0].split('#')[0].split('/')[-1].strip()

def topic_refs(fm):
    """Topic basenames named in `topics:` frontmatter (wikilinks or bare names), lower-cased."""
    out = set()
    for v in fm_list(fm, 'topics'):
        v = v.strip()
        if v.startswith('[['):
            v = link_name(v.strip('[]'))
        if v:
            out.add(v.lower())
    return out

def link_targets(txt):
    out = set()
    for m in LINK.findall(txt):
        if '\\' in m.split('|')[0]:        # \| table-escape artifact, not a real link
            continue
        t = link_name(m)
        if t:
            out.add(t.lower())
    return out

def frontmatter_aliases(txt):
    fm, _ = split_frontmatter(txt)
    return fm_list(fm, 'aliases') if fm else []

def topic_index(topics_dir):
    names, alias2name = set(), {}
    for f in glob.glob(os.path.join(topics_dir, '*.md')):
        n = base(f)
        if n.startswith('_') or n.lower() == 'topics':
            continue
        names.add(n.lower())
        for a in frontmatter_aliases(read(f)):
            alias2name[a.lower()] = n.lower()
    return names, alias2name

def dirs(args):
    p = os.path.expanduser(args.project)
    return p, os.path.join(p, 'Topics'), os.path.join(p, 'Tasks'), os.path.join(p, 'Events')

def set_topics(txt, add):
    """Return txt with the names in `add` appended to the `topics:` frontmatter list."""
    fm, body = split_frontmatter(txt)
    if fm is None:
        fm = ''
    existing = fm_list(fm, 'topics')
    links = [f'[[{n}]]' for n in add if f'[[{n}]]' not in existing]
    if not links:
        return txt
    items = [v for v in existing] + links
    block = 'topics:\n' + '\n'.join(f'  - "{v}"' for v in items)
    if re.search(r'^topics:', fm, re.M):
        # replace the whole existing field
        m = re.search(r'^topics:[ \t]*(.*)$', fm, re.M)
        end = m.end()
        if not m.group(1).strip():
            rest = fm[end:].split('\n')
            k = 1
            while k < len(rest) and re.match(r'^\s+-\s*', rest[k]):
                k += 1
            end = end + len('\n'.join(rest[:k]))
        fm = fm[:m.start()] + block + fm[end:]
    else:
        fm = (fm + '\n' if fm else '') + block
    return '---\n' + fm.strip('\n') + '\n---\n' + body

# ---------------------------------------------------------------- audit
def cmd_audit(args):
    _, topics, tasks, events = dirs(args)
    names, alias2 = topic_index(topics)
    keys = names | set(alias2)
    for kind, d in [('Tasks', tasks), ('Events', events)]:
        files = md_files(d)
        if not files:
            continue
        miss, legacy = [], []
        for f in files:
            txt = read(f)
            fm, body = split_frontmatter(txt)
            if topic_refs(fm) & keys:
                continue
            # legacy: topic links on the line(s) under the H1
            lines = body.split('\n')
            i = next((k for k, l in enumerate(lines) if l.startswith('# ')), None)
            seg = []
            if i is not None:
                for l in lines[i + 1:]:
                    if (l.strip() == '' and seg) or l.startswith('#'):
                        break
                    if l.strip():
                        seg.append(l)
            if seg and (link_targets('\n'.join(seg)) & keys):
                legacy.append(f)
            else:
                miss.append(f)
        print(f"{kind}: {len(files)} notes — {len(files)-len(miss)-len(legacy)} have topics:, "
              f"{len(legacy)} only link a Topic under the H1 (move to topics:), {len(miss)} have no Topic")
        for m in sorted(legacy):
            print("   legacy -", base(m))
        for m in sorted(miss):
            print("   none   -", base(m))
    out, inn = {}, {n: set() for n in names}
    for f in glob.glob(os.path.join(topics, '*.md')):
        b = base(f).lower()
        if b not in names:
            continue
        res = set()
        for t in link_targets(read(f)):
            if t in names and t != b: res.add(t)
            elif t in alias2 and alias2[t] != b: res.add(alias2[t])
        out[b] = res
        for r in res: inn[r].add(b)
    print(f"\n{len(names)} Topic notes")
    print("No OUTGOING topic link:", sorted(n for n in names if not out.get(n)) or "none")
    print("No INCOMING topic link:", sorted(n for n in names if not inn.get(n)) or "none")

# ---------------------------------------------------------------- clusters
def cmd_clusters(args):
    _, _, tasks, events = dirs(args)
    files = md_files(tasks, events)
    if args.keywords:
        kws = json.load(open(os.path.expanduser(args.keywords)))   # {"Label": "regex"}
        print(f"# keyword hit-counts over {len(files)} Task/Event notes")
        for label, pat in sorted(kws.items(), key=lambda kv: -sum(
                bool(re.search(kv[1], read(f), re.I)) for f in files)):
            rx = re.compile(pat, re.I)
            print(f"{sum(bool(rx.search(read(f))) for f in files):4}  {label}")
        return
    phrase = re.compile(r'\b([A-Z][a-zA-Z]+(?: [A-Z][a-zA-Z&]+){1,3})\b')
    pref   = re.compile(r'\b([A-Z]{2,5})-\d+')
    pc, tc = Counter(), Counter()
    for f in files:
        t = read(f)
        for m in phrase.findall(t): pc[m] += 1
        for m in pref.findall(t):   tc[m] += 1
    print(f"# Candidate themes from {len(files)} Task/Event notes "
          f"(capitalised phrases, count >= {args.min}):")
    for p, c in pc.most_common(60):
        if c >= args.min:
            print(f"{c:4}  {p}")
    print("\n# Ticket / ID prefixes (each is usually one workstream):")
    for p, c in tc.most_common(15):
        print(f"{c:4}  {p}-")

# ---------------------------------------------------------------- backlink
def cmd_backlink(args):
    _, _, tasks, events = dirs(args)
    mapping = {}
    for item in args.map:
        k, v = item.split('=', 1)
        mapping[k] = re.compile(v, re.I)
    excl = set()
    if args.exclude:
        excl = {l.strip() for l in open(os.path.expanduser(args.exclude)) if l.strip()}
    files = md_files(tasks, events)
    per = {k: 0 for k in mapping}; changed = 0
    for f in files:
        if base(f) in excl:
            continue
        txt = read(f)
        fm, _ = split_frontmatter(txt)
        have = topic_refs(fm)
        adds = [k for k, rx in mapping.items() if rx.search(txt) and k.lower() not in have]
        if not adds:
            continue
        if args.apply:
            write(f, set_topics(txt, adds))
        changed += 1
        for k in adds:
            per[k] += 1
    print('APPLIED' if args.apply else 'DRY-RUN  (re-run with --apply to write)')
    for k, n in per.items():
        print(f"  +{n:<4} [[{k}]]")
    print(f"  {changed} files affected")

# ---------------------------------------------------------------- crosscut
WIKI = re.compile(r'\[\[([^\]|]+)(\|[^\]]*)?\]\]')

def cmd_crosscut(args):
    """Read-only: list Topics that may be evergreen cross-cutting concepts
    worth graduating to a shared domain folder. Detection only — never writes."""
    proj, topics, _, _ = dirs(args)
    proj = os.path.normpath(proj)
    pname = base(proj)
    names, alias2 = topic_index(topics)
    root = os.path.dirname(os.path.dirname(proj))
    if base(os.path.dirname(proj)) != 'Projects':
        root = None
        print("NOTE: project is not under <vault>/Projects/ — "
              "vault-wide and cross-project signals skipped\n")
    inside = {base(f).lower() for f in md_files(proj)} | set(alias2)

    outside, domains, dom_names = set(), [], {}
    if root:
        for d in sorted(os.listdir(root)):
            top = os.path.join(root, d)
            if d.startswith('.') or not os.path.isdir(top):
                continue
            hub = d != 'Projects' and os.path.isfile(os.path.join(top, d + '.md'))
            if hub:
                domains.append(d); dom_names[d] = set()
            for f in md_files(top):
                if os.path.normpath(f).startswith(proj + os.sep):
                    continue
                outside.add(base(f).lower())
                if hub:
                    dom_names[d].add(base(f).lower())

    xrefs = {n: Counter() for n in names}
    if root:
        pdir = os.path.join(root, 'Projects')
        byproj = {}
        for f in md_files(pdir):
            fn = os.path.normpath(f)
            parts = os.path.relpath(fn, pdir).split(os.sep)
            if len(parts) >= 2 and not fn.startswith(proj + os.sep):
                byproj.setdefault(parts[0], []).append(fn)
        for other, fs in byproj.items():
            own = {base(f).lower() for f in fs}
            for f in fs:
                for t in {(t if t in names else alias2.get(t))
                          for t in link_targets(read(f))
                          if t not in own and t not in STRUCTURAL}:
                    if t in xrefs:
                        xrefs[t][other] += 1

    cands, scanned = [], 0
    for f in sorted(glob.glob(os.path.join(topics, '*.md'))):
        name = base(f); low = name.lower()
        if low not in names or low == pname.lower():
            continue
        scanned += 1
        txt = read(f)
        prose = [l.strip() for l in body_text(txt).splitlines()
                 if l.strip() and not l.strip().startswith('#')]
        wc = len(re.findall(r"[\w'-]+", WIKI.sub(r'\1', ' '.join(prose))))
        first = next((WIKI.sub(r'\1', l) for l in prose
                      if not re.fullmatch(r'(!?\[\[[^\]]+\]\]\s*)+', l)), '')
        defn = bool(re.match(r'(the |a |an )?' + re.escape(low) +
                             r'e?s? +(is|are|was|were|refers to|stands for)\b',
                             first.lower()))
        tgts = {t for t in link_targets(txt)
                if not t.startswith('@') and not re.match(r'\d{4}-\d{2}-\d{2}', t)
                and t not in STRUCTURAL}
        out_t = {t for t in tgts if t not in inside and t in outside}
        in_t = {t for t in tgts if t in inside and t not in (low, pname.lower())}
        xc = sum(xrefs.get(low, Counter()).values())

        sig = []
        if wc <= args.max_words or defn:
            sig.append('+'.join(filter(None, ['stub' if wc <= args.max_words else '',
                                              'definition' if defn else '']))
                       + f'({wc}w)')
        if out_t:
            sig.append(f'vault-wide({len(out_t)}/{len(out_t) + len(in_t)} links)')
        if xc:
            sig.append(f'x-project({xc} from {", ".join(sorted(xrefs[low]))})')
        if not (xc or len(sig) >= 2):
            continue
        votes = {d: len(out_t & dom_names[d]) + (2 if d.lower() in tgts else 0)
                 for d in domains}
        best = max(votes, key=votes.get) if votes and max(votes.values()) else None
        cands.append((len(sig), xc, len(out_t), name, sig, best))

    cands.sort(key=lambda c: (-c[0], -c[1], -c[2], c[3]))
    print(f"# Graduation suspects in {pname} — {scanned} Topics scanned, "
          f"{len(cands)} suspect(s)")
    print("# gate: x-project refs or >=2 signals — a short or empty list is the healthy result")
    for i, (_, xc, _, name, sig, best) in enumerate(cands, 1):
        dest = f'-> {best}/' if best else '-> no domain folder — needs a decision'
        print(f"{i:3}. {name:<32} [{', '.join(sig)}]  x-refs:{xc}  {dest}")
    if not cands:
        print("(none)")
    print("\nGraduation is a human decision — this command only detects; "
          "see GRADUATION.md and [[Topic graduation]].")

# ---------------------------------------------------------------- linkcheck
def cmd_linkcheck(args):
    proj, _, _, _ = dirs(args)
    proj = os.path.abspath(proj)
    root = os.path.abspath(os.path.expanduser(args.vault)) if args.vault else proj
    for directory in (proj, root):
        if not os.path.isdir(directory):
            raise SystemExit(f"not a directory: {directory}")
    paths, targets = set(), set()
    for f in glob.glob(os.path.join(root, '**', '*'), recursive=True):
        if not os.path.isfile(f):
            continue
        paths.add(os.path.normpath(f).lower())
        relative = os.path.relpath(f, root).replace(os.sep, '/').lower()
        variants = [relative]
        if relative.endswith('.md'):
            variants.append(relative[:-3])
            targets.update(a.lower() for a in frontmatter_aliases(read(f)))
        for variant in variants:
            parts = variant.split('/')
            targets.update('/'.join(parts[i:]) for i in range(len(parts)))
    broken = Counter()
    for f in md_files(proj):
        for raw in LINK.findall(read(f)):
            target = raw.replace(r'\|', '|').split('|')[0].split('#')[0].strip().lower()
            if not target:
                continue
            relative = target.startswith(('./', '../'))
            if not relative and target in targets:
                continue
            candidate = os.path.normpath(os.path.join(os.path.dirname(f), target)).lower()
            if candidate not in paths and candidate + '.md' not in paths:
                broken[target] += 1
    print(f"File targets from {proj}, resolved against {root}")
    if not args.vault:
        print("Project-only resolution; pass --vault to include external targets.")
    print(f"{len(broken)} unresolved file target(s)")
    for target, count in broken.most_common():
        print(f"  {count:4}  {target}")

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest='cmd', required=True)
    for name in ('audit', 'clusters', 'backlink', 'linkcheck', 'crosscut'):
        s = sub.add_parser(name)
        s.add_argument('--project', required=True)
        if name == 'clusters':
            s.add_argument('--keywords'); s.add_argument('--min', type=int, default=4)
        if name == 'backlink':
            s.add_argument('--map', action='append', default=[], required=True)
            s.add_argument('--exclude'); s.add_argument('--apply', action='store_true')
        if name == 'linkcheck':
            s.add_argument('--vault', help='Vault root for file-target resolution; defaults to project')
        if name == 'crosscut':
            s.add_argument('--max-words', type=int, default=40)
    args = ap.parse_args()
    {'audit': cmd_audit, 'clusters': cmd_clusters, 'backlink': cmd_backlink,
     'linkcheck': cmd_linkcheck, 'crosscut': cmd_crosscut}[args.cmd](args)

if __name__ == '__main__':
    main()
