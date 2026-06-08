#!/usr/bin/env python3
"""
Topic-maintenance helpers for an Obsidian project that has Topics/ and Tasks/
(and usually Events/) sub-folders.

Philosophy: PROPOSE then APPLY. Read commands (clusters, audit, linkcheck) only
print findings. The one write command (backlink) is dry-run by default and needs
--apply to touch files.

Usage:
  python3 topic_tools.py clusters  --project DIR [--keywords map.json] [--min 4]
  python3 topic_tools.py backlink  --project DIR --map "Topic=regex" [...] [--exclude file] [--apply]
  python3 topic_tools.py audit     --project DIR
  python3 topic_tools.py linkcheck --project DIR

DIR is a project folder, e.g. ~/Documents/Notes/Projects/Patchwork
"""
import argparse, glob, json, os, re
from collections import Counter

LINK = re.compile(r'\[\[([^\]]+)\]\]')

def base(p): return os.path.splitext(os.path.basename(p))[0]
def read(p): return open(p, encoding='utf-8').read()
def write(p, s): open(p, 'w', encoding='utf-8').write(s)

def md_files(*dirs):
    out = []
    for d in dirs:
        if d and os.path.isdir(d):
            out += glob.glob(os.path.join(d, '**', '*.md'), recursive=True)
    return out

def link_targets(txt):
    out = set()
    for m in LINK.findall(txt):
        if '\\' in m.split('|')[0]:        # \| table-escape artifact, not a real link
            continue
        t = m.split('|')[0].split('#')[0].split('/')[-1].strip()
        if t:
            out.add(t.lower())
    return out

def frontmatter_aliases(txt):
    m = re.match(r'^---\n(.*?)\n---', txt, re.S)
    if not m:
        return []
    am = re.search(r'aliases:\s*\n((?:\s*-\s*.+\n?)*)', m.group(1))
    if not am:
        return []
    return [re.sub(r'^\s*-\s*', '', l).strip().strip('"')
            for l in am.group(1).splitlines() if l.strip()]

def topic_index(topics_dir):
    names, alias2name = set(), {}
    for f in glob.glob(os.path.join(topics_dir, '*.md')):
        n = base(f).lower(); names.add(n)
        for a in frontmatter_aliases(read(f)):
            alias2name[a.lower()] = n
    return names, alias2name

def dirs(args):
    p = os.path.expanduser(args.project)
    return p, os.path.join(p, 'Topics'), os.path.join(p, 'Tasks'), os.path.join(p, 'Events')

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
    # heuristic discovery when no keyword map is supplied
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
        adds = [k for k, rx in mapping.items()
                if rx.search(txt) and f'[[{k}]]' not in txt]
        if not adds:
            continue
        if args.apply:
            lines = txt.split('\n')
            idx = next((i for i, l in enumerate(lines) if l.startswith('# ')), None)
            if idx is None:   # no H1: fall back to end of frontmatter, else top
                idx = (next((i for i in range(1, len(lines))
                             if lines[i].strip() == '---'), -1)
                       if lines and lines[0].strip() == '---' else -1)
            lines[idx + 1:idx + 1] = ['', ' '.join(f'[[{k}]]' for k in adds)]
            write(f, '\n'.join(lines))
        changed += 1
        for k in adds:
            per[k] += 1
    print('APPLIED' if args.apply else 'DRY-RUN  (re-run with --apply to write)')
    for k, n in per.items():
        print(f"  +{n:<4} [[{k}]]")
    print(f"  {changed} files affected")

# ---------------------------------------------------------------- audit
def cmd_audit(args):
    _, topics, tasks, events = dirs(args)
    names, alias2 = topic_index(topics)
    keys = names | set(alias2)
    for kind, d in [('Tasks', tasks), ('Events', events)]:
        files = md_files(d)
        if not files:
            continue
        miss = [f for f in files if not (link_targets(read(f)) & keys)]
        print(f"{kind}: {len(files)} notes — {len(files)-len(miss)} link a Topic, "
              f"{len(miss)} do NOT")
        for m in sorted(miss):
            print("   -", base(m))
    out, inn = {}, {n: set() for n in names}
    for f in glob.glob(os.path.join(topics, '*.md')):
        b = base(f).lower(); res = set()
        for t in link_targets(read(f)):
            if t in names and t != b: res.add(t)
            elif t in alias2 and alias2[t] != b: res.add(alias2[t])
        out[b] = res
        for r in res: inn[r].add(b)
    print(f"\n{len(names)} Topic notes")
    print("No OUTGOING topic link:", sorted(n for n in names if not out.get(n)) or "none")
    print("No INCOMING topic link:", sorted(n for n in names if not inn.get(n)) or "none")

# ---------------------------------------------------------------- linkcheck
def cmd_linkcheck(args):
    proj, _, _, _ = dirs(args)
    files = glob.glob(os.path.join(proj, '**', '*.md'), recursive=True)
    names = {base(f).lower() for f in files}
    alias = set()
    for f in files:
        for a in frontmatter_aliases(read(f)):
            alias.add(a.lower())
    resolvable = names | alias
    broken = Counter()
    for f in files:
        for raw in LINK.findall(read(f)):
            if '\\' in raw.split('|')[0]:
                continue
            t = raw.split('|')[0].split('#')[0].split('/')[-1].strip().lower()
            if t and t not in resolvable:
                broken[t] += 1
    print(f"Unresolved link targets within {proj}")
    print("(daily-notes, @people and attachments live elsewhere in the vault — "
          "expected to show here):")
    for t, c in broken.most_common():
        print(f"  {c:4}  {t}")

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest='cmd', required=True)
    for name in ('clusters', 'backlink', 'audit', 'linkcheck'):
        s = sub.add_parser(name)
        s.add_argument('--project', required=True)
        if name == 'clusters':
            s.add_argument('--keywords'); s.add_argument('--min', type=int, default=4)
        if name == 'backlink':
            s.add_argument('--map', action='append', default=[], required=True)
            s.add_argument('--exclude'); s.add_argument('--apply', action='store_true')
    args = ap.parse_args()
    {'clusters': cmd_clusters, 'backlink': cmd_backlink,
     'audit': cmd_audit, 'linkcheck': cmd_linkcheck}[args.cmd](args)

if __name__ == '__main__':
    main()
