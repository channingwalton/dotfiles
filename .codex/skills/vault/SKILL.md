---
name: vault
description: Read and write notes in the Obsidian vault. Use for task logs, knowledge capture, and building context.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/` (vault name: `Notes`)

## Principles

1. **Obsidian vault for documents** — detailed notes, task logs, project context
2. **Plain Unix commands for vault operations** — treat the vault as Markdown files under `~/Documents/Notes`; do not use the `obsidian` CLI
3. **WikiLinks for connections** — build traversable knowledge graph
4. **ALWAYS**: New tasks should be in an `open` state

## Templates

Templates are in the skill directory, not the notes directory:

- `.codex/skills/vault/templates/knowledge-note.md`
- `.codex/skills/vault/templates/task.md`
- `.codex/skills/vault/templates/recipe.md`
- `.codex/skills/vault/templates/weekly-summary.md`

## Unix Commands

Set a vault variable when commands get long:

```bash
VAULT="$HOME/Documents/Notes"
```

**Spaces in paths**: quote the whole path:

```bash
sed -n '1,220p' "$HOME/Documents/Notes/Projects/2025-10 Patchwork/Note.md"
```

### Creating and writing

```bash
mkdir -p "$VAULT/<folder>"
printf '%s\n' "<text>" > "$VAULT/<folder/file.md>"
cp "$HOME/.codex/skills/vault/templates/<template>.md" "$VAULT/<folder/file.md>"
printf '%s\n' "<text>" >> "$VAULT/<folder/file.md>"
tmp="$(mktemp)" && { printf '%s\n' "<text>"; cat "$VAULT/<folder/file.md>"; } > "$tmp" && mv "$tmp" "$VAULT/<folder/file.md>"
```

### Reading

```bash
sed -n '1,220p' "$VAULT/<folder/file.md>"
cat "$VAULT/<folder/file.md>"
stat "$VAULT/<folder/file.md>"
rg -n '^#{1,6} ' "$VAULT/<folder/file.md>"
```

### Searching and finding

```bash
rg -n "<text>" "$VAULT/<folder>"
find "$VAULT/<folder>" -type f -name '*.md' | sort
rg -n "(^|[[:space:]])#<tag>\\b" "$VAULT"
rg -oh "(^|[[:space:]])#[A-Za-z0-9/_-]+" "$VAULT" | sed 's/^[[:space:]]*//' | sort | uniq -c | sort -nr
```

### Properties (frontmatter)

```bash
awk '/^---$/ {block++; next} block == 1 && /^<prop>:/ {print}' "$VAULT/<folder/file.md>"
perl -0pi -e 's/(^---\n(?:.*\n)*?)^status:.*$/${1}status: done/m' "$VAULT/<folder/file.md>"
perl -0pi -e 's/^<prop>:.*\n//m' "$VAULT/<folder/file.md>"
awk '/^---$/ {block++; next} block == 1 {print} block == 2 {exit}' "$VAULT/<folder/file.md>"
```

### Graph queries (linking)

```bash
note="$(basename "$VAULT/<folder/file.md>" .md)"; rg -n "\\[\\[$note(\\||\\])" "$VAULT"
rg -o "\\[\\[[^]|#]+(#[^]|]+)?(\\|[^]]+)?\\]\\]" "$VAULT/<folder/file.md>" | sort -u
for f in $(find "$VAULT" -type f -name '*.md'); do name="$(basename "$f" .md)"; rg -q "\\[\\[$name(\\||\\])" "$VAULT" || printf '%s\n' "$f"; done
rg -L "\\[\\[[^]]+\\]\\]" "$VAULT" -g '*.md'
rg -o "\\[\\[[^]|#]+(#[^]|]+)?(\\|[^]]+)?\\]\\]" "$VAULT" | sed -E 's/.*\\[\\[([^]|#]+).*/\\1/' | sort -u
```

### Tasks

```bash
rg -n '^\\s*- \\[ \\] ' "$VAULT"
rg -n '^\\s*- \\[x\\] ' "$VAULT"
rg -n '^\\s*- \\[[ x]\\] ' "$VAULT/<folder/file.md>"
perl -0pi -e 's/^(\s*- )\[ \]/$1[x]/m' "$VAULT/<folder/file.md>"
```

### File management

```bash
mkdir -p "$(dirname "$VAULT/<new-path>")"
mv "$VAULT/<old-path>" "$VAULT/<new-path>"
rm "$VAULT/<folder/file.md>"
```

### Time-based file queries

```bash
find "$VAULT" -type f -name '*.md' -mtime -7 | sort
find "$VAULT/Projects" -path '*/Tasks/*.md' -type f -mtime -7 | sort
```

## Timestamps

Always use real timestamps, never placeholders:

```bash
date +"%Y-%m-%d %H%M%S"    # task filename
date +"%Y-%m-%d %H:%M"      # log entry header
date -Iseconds               # frontmatter (ISO-8601)
```

## Task File Path

`~/Documents/Notes/Projects/<YYYY[-MM] Project>/Tasks/<YYYY-MM-DD HHMMSS> <Title>.md`

## Linking Strategy

> Link if it improves the note, not just because it matches a term.

1. **Semantic discovery** — `rg -n "<concept>" "$VAULT"`
2. **Backlinks** — `note="$(basename "$file" .md)"; rg -n "\\[\\[$note(\\||\\])" "$VAULT"`
3. **Tags overlap** — `rg -n "(^|[[:space:]])#<tag>\\b" "$VAULT"`
4. Add as WikiLinks using breadcrumb pattern: `[[Parent]] | [[Related]]`

## Capture Heuristics

**Worth capturing when:** principle applies across contexts, caused debugging time, method that saves time later, non-obvious choice with reasoning worth preserving, link to documentation.

**Where to capture:**

| Destination | When |
|-------------|------|
| **Existing note** | Extends/refines an existing topic (search first) |
| **New note** | Substantial, standalone, referenceable |
| **Task log only** | One-off detail that won't generalise |
| **Project recipe** | Repeatable steps specific to this project |

## Note Locations

| Folder | Purpose |
|--------|---------|
| `Development/` | Conceptual topics, paradigms, architectural patterns |
| `HowTo/` | Procedural guides, techniques, not project-specific |
| `Tools/` | Software tools and their usage |
| `Projects/<project>/` | Project-level knowledge |
| `Projects/<project>/Tasks/` | Task logs only — never knowledge notes |
| `Projects/<project>/Glossary/` | Glossary entries |
| `Projects/<project>/Recipes/` | Project-specific recipes and runbooks |
| `Projects/<project>/Meetings/` | Meetings with date prefix |
| `Journal/Weekly Notes/` | Weekly summaries (generated from task activity) |

**Extraction signal:** When a task log contains repeatable steps, extract into a recipe.

## Task Reference Resolution

**Every mention of a JIRA issue number must be a wiki-link to its task note.** Never leave bare issue numbers.

1. Build lookup from `find` results: issue number → full filename
2. If not found: `rg -n "RH-6949" "$VAULT/Projects"`
3. Use aliased wiki-links: `[[2026-02-13 141534 RH-6949 Performance issue|RH-6949]]`

Applies to **all sections** — summaries, blockers, carryover, etc.

## Generating Weekly Summaries

Path: `~/Documents/Notes/Journal/Weekly Notes/<YYYY>-W<WW>.md`

### Data gathering

```bash
find "$VAULT/Projects" -path '*/Tasks/*.md' -type f -mtime -7 | sort
rg -l '^status: in-progress$|^status: "in-progress"$' "$VAULT/Projects"
find "$VAULT/Projects" -type f -name '*.md' -mtime -7 ! -path '*/Tasks/*' | sort
find "$VAULT/Projects" -path '*/Recipes/*.md' -type f -mtime -7 | sort
```

### Workflow

1. Gather modified tasks, new notes, outstanding tasks from previous week
2. Read each: `sed -n '1,220p' "$task"`
3. Build JIRA → filename lookup (see Task Reference Resolution)
4. Populate weekly summary template, wiki-linking all references
5. Create: `printf '%s\n' "<text>" > "$VAULT/Journal/Weekly Notes/<YYYY>-W<WW>.md"`

## Generating Daily Notes

Path: `~/Documents/Notes/Journal/Daily Notes/<YYYY>/<YYYY-MM>/<YYYY-MM-DD>.md`

### Data gathering

```bash
find "$VAULT/Projects" -path '*/Tasks/*.md' -type f -mtime -1 | sort
find "$VAULT/Projects" -path "*/Meetings/$(date +%Y-%m-%d)*.md" -type f | sort
find "$VAULT/Projects" -type f -name '*.md' -mtime -1 ! -path '*/Tasks/*' ! -path '*/Meetings/*' | sort
```

### Slack conversations

Search Slack for important conversations **the user is involved in** today. Use `slack_search_public_and_private` with `from:<@USER_ID>` and date filters to find messages the user sent. Then read the threads of those messages to get full context. **Only include conversations the user participated in. Exclude DMs.**

For each noteworthy conversation, capture:
- A one-line summary
- A link to the thread (from the message permalink)

### Format

```markdown
---
---
# [[YYYY-MM-DD]]

## Work
- [[Task link|Short name]] — one-line summary

## Meetings
- [[Meeting note]]

## Notes created
- [[Note name]] (type)

## Slack conversations
- One-line summary of discussion — [link](permalink)
```

### Workflow

1. Find tasks, meetings, notes modified today
2. Read each: `sed -n '1,220p' "$task"`
3. Search Slack for conversations the user participated in today (`from:<@USER_ID>`, no DMs), then read threads for context
4. Build JIRA → filename lookup (see Task Reference Resolution)
5. Create or append daily note, wiki-linking all references

## What NOT to include

- **DO NOT** include changed files
