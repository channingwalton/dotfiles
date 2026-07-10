---
name: obsidian-topic-maintainer
description: Keep an Obsidian vault project's Topics folder up to date from its Tasks (and Events), and graduate evergreen Topics into shared domain folders. Use when the user wants to refresh or maintain a project's topics, find missing or new topics, add task-to-topic backlinks, audit topic interlinking, fix orphan topics, resolve duplicate/alias collisions, convert a dated retrospective into a Task, or promote a cross-cutting Topic out of the project into a domain folder (graduation). Assumes each project under the vault has Topics/ and Tasks/ sub-folders (and usually Events/).
---

# Obsidian Topic Maintainer

Maintains the **Topics** layer of an Obsidian project from its **Tasks** and **Events**: surfaces subjects that deserve a Topic hub, creates those hubs, wires task->topic backlinks, keeps the whole thing interlinked and tidy, and **graduates** the rare Topic that is really a cross-cutting concept out into a shared domain folder.

This skill is **propose-then-apply**: always analyse, show candidates and counts, and get the user's go-ahead before writing. Never bulk-edit notes without confirmation.

A helper script lives at `scripts/topic_tools.py` (run it with `python3 <skill-dir>/scripts/topic_tools.py ...`). Read commands are safe; the one write command (`backlink`) is dry-run unless `--apply` is passed.

## Vault model & conventions

- Vault root is typically `~/Documents/Notes`; projects live under `Projects/<Name>/`, each with `Topics/`, `Tasks/`, and usually `Events/`.
- **Domain knowledge lives outside projects.** Top-level folders (`Development/`, `Artificial Intelligence/`, `Process/`, `Knowledge management/`, ...) hold evergreen, project-independent notes. Each has a same-named hub note that acts as its **MOC (Map of Content)**; some are Dataview-backed, surfacing every note that links `[[<Domain>]]` automatically. A concept that recurs across projects belongs here, not trapped in one project's `Topics/`.
- **Every note's H1 is a self wikilink**: `# [[Note Title]]`, followed by a parent link line. For a project Topic that parent is `[[<Project>]]`; for a graduated domain note it is `[[<Domain>]]`.
- **Topic hub** = an evergreen, conceptual note in `Topics/`. It describes a subject in prose, links to related topics, recipes and glossary terms, and ends with a `## See also` line of middot-separated wikilinks. A hub does **not** enumerate task notes.
- **Direction of links is one-way: tasks -> topics.** Task/Event notes carry a bare-wikilink backlink line (e.g. `[[Importers]] [[Leave Entitlements]]`) immediately under their H1. Topics never list their tasks.
- **Definitions vs hubs**: short "what is X" notes (a glossary term) and longer "what we did / how it works" hubs both live in `Topics/`. Don't create a second note for a concept that already has one - merge instead.
- **Aliases**: give abbreviations and singular/plural variants an `aliases:` entry so existing links keep resolving (e.g. hub `kmono Architecture` with alias `kmono`; hub `Job Plans` with alias `Job Plan`). Keep note **basenames unique** across the project - duplicate basenames force Obsidian to write fragile full-path links.
- **Links resolve by basename, vault-wide.** Moving a note between folders (Topics -> a domain folder) does not break `[[wikilinks]]`, so graduation needs no stub or redirect. Never leave a same-named copy behind - duplicate basenames make links ambiguous.
- British spelling. Generate any timestamp with the shell `date` command, never a guess.
- **Task frontmatter** shape (match the project's existing tasks):
  ```
  ---
  status: done
  priority: normal
  projects:
    - "[[<Project>]]"
  dateCreated: <ISO8601>
  dateModified: <ISO8601>
  tags:
    - task
  completedDate: <YYYY-MM-DD>
  ---
  ```

## Workflow

Work one project at a time. Confirm the project folder and that `Topics/` and `Tasks/` exist before starting.

**Read the maintenance log first.** Each project's `Topics/_topic-maintenance-log.md` (if present) records the last pass: date, coverage counts, topics touched, and the agreed skip-list of notes deliberately left uncovered. Read it before auditing so you don't re-litigate settled ground or re-inspect the skip-list every run. Update it at the end (step 8).

### 1. Inventory
List existing topics (and their aliases) and the Task/Event notes:
```
python3 scripts/topic_tools.py audit --project "<PROJECT_DIR>"
```
This also reports current task->topic coverage and topic->topic connectivity - a baseline.

### 2. Find candidate topics
Surface recurring subjects that have no hub yet:
```
python3 scripts/topic_tools.py clusters --project "<PROJECT_DIR>"            # heuristic discovery
python3 scripts/topic_tools.py clusters --project "<PROJECT_DIR>" --keywords map.json
```
`map.json` is `{"Label": "regex", ...}` - use it to quantify specific themes you suspect. Read the results and judge: a good Topic is a recurring **subject** (10+ related notes is a strong signal, but a coherent smaller cluster counts), distinct from existing hubs. Classify each candidate as a work-theme hub or a short definition. **Present a ranked shortlist with counts and a one-line rationale each, then ask which to create** (offer "just the clearest", "top 3", "top 5"). Flag overlaps with existing topics and decide merge-vs-keep before splitting.

### 3. Create the hubs (after approval)
For each approved topic, write `Topics/<Topic>.md`:
- Frontmatter (with `aliases:` if it has an abbreviation/variant).
- `# [[<Topic>]]` then `[[<Project>]]`.
- 2-5 short prose sections: what it is, why it matters, recurring themes, where it lives in code.
- A `## See also` line linking related topics, recipes and glossary terms.
- **No enumerated task links.**
Match the voice of existing hubs in that project. Prefer a folder-topic or a loose note to match whatever layout the project already uses.

### 4. Add task->topic backlinks
Insert a bare-wikilink line under the H1 of every Task/Event that genuinely mentions the topic. Dry-run first, eyeball the counts and the matched files, curate out false positives, then apply:
```
python3 scripts/topic_tools.py backlink --project "<DIR>" \
    --map "Importers=\bimport(s|ed|ing|er|ers)?\b|\bupload" \
    --map "Leave Entitlements=entitlement"
# add --exclude false_positives.txt (one basename per line) and --apply to write
```
Use word-boundary regexes; `\bimport...` excludes "important". If a broad regex pulls in tangential notes (e.g. a field name that merely contains "GMC"), curate with `--exclude` rather than loosening the criterion. Idempotent: notes already carrying the link are skipped.

### 5. Interlink audit & orphans
Re-run `audit`. Aim for:
- **Tasks -> Topics: every note links at least one topic.** For stragglers, either the note needs an existing topic's backlink (a regex that missed it) or it signals a *new* topic - feed those back into step 2.
- **Topics -> Topics: links must be evidence-gated.** Add a `## See also` link between two topics **only when they co-occur in real task/event text** (the same notes mention both). Never invent a topic->topic link to clear the orphan-connectivity number — a false link is worse than an orphan. Give a topic with no *outgoing* link a `## See also` only if such evidence exists; otherwise leave it. Intentional peripheral orphans (dev/admin/reference, or a standalone definition) are acceptable — record them in the skip-list, don't force a link.

### 6. Graduation (promote evergreen concepts out of the project)
Most Topics describe *this* project and stay. A few are really **cross-cutting concepts** that will recur elsewhere — promote those into a shared domain folder so project work compounds into reusable knowledge. Canonical procedure: the vault note `[[Topic graduation]]`. This step is **conservative by default** — when in doubt, leave it in the project.

**Where to look.** The prime suspects are the notes step 5 parks in the skip-list as "standalone definition / reference stubs", and any note whose links already resolve vault-wide rather than to project topics. Re-evaluate those here instead of parking them forever. The `crosscut` command (read-only) ranks them:
```
python3 scripts/topic_tools.py crosscut --project "<PROJECT_DIR>"    # --max-words tunes the stub threshold (default 40)
```
One line per suspect: fired signals (definition-style stub, links resolving outside the project, linked from other projects, skip-listed as standalone), cross-project reference count, and a suggested destination domain folder where one fits. It only detects — apply the three-part test below yourself.

**The test — graduate only if all three hold:**
1. **Concept-oriented, not project-oriented.** Ask: *would I want this note when working on a different project?* Names tied to this project (clients, sites, internal systems, ticket-specific behaviour) fail — they stay.
2. **A real destination domain folder already exists** (`Development/`, `Artificial Intelligence/`, ...). If the concept is genuinely cross-cutting but has **no** home folder, do **not** invent a top-level folder — surface it to the user as a naming decision and leave the note in place until they choose. (A dense project-specific domain — e.g. an NHS rostering product — is correct as-is; do not strip it for the sake of promotion.)
3. **The concept is actually stated.** A stub title is not knowledge. If the note is a stub, distil it into a proper atomic note first (or flag that it needs writing) — don't move an empty hull.

**Propose-then-apply.** Present the shortlist of graduation candidates — each with its proposed destination and a one-line rationale — and get the user's go-ahead. Expect this list to be short or empty; that is the normal, healthy result.

**To graduate an approved Topic:**
- Distil it into an atomic, concept-oriented note in your own words (drop project-specific incidental detail, or split it out — keep the project-specific part as a project Topic that links the new general note).
- Move it to the domain folder (`git mv` if the vault is a git repo, to preserve history). Basename unchanged, so every existing `[[link]]` keeps resolving — leave **no** stub behind.
- Re-point the parent link from `[[Topics]]`/`[[<Project>]]` to `[[<Domain>]]`, drop the `project:` frontmatter binding, and add a `Used in [[<Project>]]` line so the project relationship stays explicit.
- Ensure the note links `[[<Domain>]]`; a Dataview-backed MOC then surfaces it automatically. If the domain hub is a hand-maintained list, add the note to it.
- Verify with `linkcheck` (step 7) that nothing broke.

### 7. Hygiene
- **Duplicate names / alias collisions**: if a concept exists twice (or a definition + a hub), merge into one note, fold the alias on so links resolve, and delete the duplicate. After removing duplicates, collapse any `[[Projects/.../full/path]]` links Obsidian created for disambiguation back to bare `[[Name]]`.
- **Dated retrospectives**: a dated, completed write-up (a retro, a posted Slack analysis) belongs in `Tasks/`, not `Topics/`. Convert it - add task frontmatter (`completedDate` = its date, `tags: task`), move it to `Tasks/`, and **extract its durable lessons** into the relevant evergreen hubs, leaving the dated note as an archived task. Links resolve by basename, so moving folders doesn't break them.

### 8. Verify
```
python3 scripts/topic_tools.py linkcheck --project "<PROJECT_DIR>"
```
Confirms no links were broken. Daily-notes (`2026-05-22`), `@people` and attachments live elsewhere in the vault and will always appear here - ignore those; look only for newly-unresolved Topic/Task names. `\|` table-escape artifacts are already filtered out. After a graduation, also confirm the moved note's old and new references still resolve.

Then **update `Topics/_topic-maintenance-log.md`**: append a dated entry (shell `date`) with the final coverage counts, the topics/backlinks touched this pass, **any promotions (Topic -> domain folder) and graduation candidates flagged-but-deferred**, and any notes added to the skip-list. This is the state the next run reads first — keep it short and append-only.

## Notes
- Deleting files in a connected vault may need delete permission - if `rm` reports "Operation not permitted", request it rather than reporting it impossible.
- Graduation needs a destination domain folder. Never create a new top-level domain folder unprompted — if a cross-cutting concept has no home, that is a decision for the user, not a default.
- Run on demand. If the user wants it kept fresh, offer to schedule a periodic run (e.g. weekly) that does steps 1-2 and proposes new topics.
- Generalises across projects: nothing here is specific to one project - point it at any `Projects/<Name>/` with `Topics/` + `Tasks/`.
