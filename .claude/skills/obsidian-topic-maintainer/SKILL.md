---
name: obsidian-topic-maintainer
description: Keep an Obsidian vault project's Topics folder up to date from its Tasks (and Events). Use when the user wants to refresh or maintain a project's topics, find missing or new topics, add task-to-topic backlinks, audit topic interlinking, fix orphan topics, resolve duplicate/alias collisions, or convert a dated retrospective into a Task. Assumes each project under the vault has Topics/ and Tasks/ sub-folders (and usually Events/).
---

# Obsidian Topic Maintainer

Maintains the **Topics** layer of an Obsidian project from its **Tasks** and **Events**: surfaces subjects that deserve a Topic hub, creates those hubs, wires task->topic backlinks, and keeps the whole thing interlinked and tidy.

This skill is **propose-then-apply**: always analyse, show candidates and counts, and get the user's go-ahead before writing. Never bulk-edit notes without confirmation.

A helper script lives at `scripts/topic_tools.py` (run it with `python3 <skill-dir>/scripts/topic_tools.py ...`). Read commands are safe; the one write command (`backlink`) is dry-run unless `--apply` is passed.

## Vault model & conventions

- Vault root is typically `~/Documents/Notes`; projects live under `Projects/<Name>/`, each with `Topics/`, `Tasks/`, and usually `Events/`.
- **Every note's H1 is a self wikilink**: `# [[Note Title]]`, followed by a parent link line `[[<Project>]]`.
- **Topic hub** = an evergreen, conceptual note in `Topics/`. It describes a subject in prose, links to related topics, recipes and glossary terms, and ends with a `## See also` line of middot-separated wikilinks. A hub does **not** enumerate task notes.
- **Direction of links is one-way: tasks -> topics.** Task/Event notes carry a bare-wikilink backlink line (e.g. `[[Importers]] [[Leave Entitlements]]`) immediately under their H1. Topics never list their tasks.
- **Definitions vs hubs**: short "what is X" notes (a glossary term) and longer "what we did / how it works" hubs both live in `Topics/`. Don't create a second note for a concept that already has one - merge instead.
- **Aliases**: give abbreviations and singular/plural variants an `aliases:` entry so existing links keep resolving (e.g. hub `kmono Architecture` with alias `kmono`; hub `Job Plans` with alias `Job Plan`). Keep note **basenames unique** across the project - duplicate basenames force Obsidian to write fragile full-path links.
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
- **Topics -> Topics: no orphans.** Give any topic with no outgoing link a `## See also`; give any with no incoming link a mention from a related hub. Peripheral dev/admin/reference notes may legitimately have no incoming topic link - note them but don't force it.

### 6. Hygiene
- **Duplicate names / alias collisions**: if a concept exists twice (or a definition + a hub), merge into one note, fold the alias on so links resolve, and delete the duplicate. After removing duplicates, collapse any `[[Projects/.../full/path]]` links Obsidian created for disambiguation back to bare `[[Name]]`.
- **Dated retrospectives**: a dated, completed write-up (a retro, a posted Slack analysis) belongs in `Tasks/`, not `Topics/`. Convert it - add task frontmatter (`completedDate` = its date, `tags: task`), move it to `Tasks/`, and **extract its durable lessons** into the relevant evergreen hubs, leaving the dated note as an archived task. Links resolve by basename, so moving folders doesn't break them.

### 7. Verify
```
python3 scripts/topic_tools.py linkcheck --project "<PROJECT_DIR>"
```
Confirms no links were broken. Daily-notes (`2026-05-22`), `@people` and attachments live elsewhere in the vault and will always appear here - ignore those; look only for newly-unresolved Topic/Task names. `\|` table-escape artifacts are already filtered out.

## Notes
- Deleting files in a connected vault may need delete permission - if `rm` reports "Operation not permitted", request it rather than reporting it impossible.
- Run on demand. If the user wants it kept fresh, offer to schedule a periodic run (e.g. weekly) that does steps 1-2 and proposes new topics.
- Generalises across projects: nothing here is specific to one project - point it at any `Projects/<Name>/` with `Topics/` + `Tasks/`.
