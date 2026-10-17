---
name: obsidian-connect
description: Connect notes in Channing's Obsidian vault to their Topics — link new notes (Readwise imports, Events, Tasks, any note) into existing notes through the topics: frontmatter, audit a project for notes with no topic, find subjects that deserve a new Topic hub, fix orphan or duplicate Topics, and graduate evergreen Topics into shared domain folders. Use after new notes are added, or when the user wants a project's topics refreshed, audited or tidied.
---

# Connect

Attaches Tasks and Events to Topics and keeps the Topics layer tidy. Two scopes, one mechanism: a handful of new notes, or a whole project. Either way the link is the `topics:` frontmatter list, as `obsidian-vault` describes; this skill never inserts the old wikilink line under the H1.

Follow the `obsidian-vault` skill's Writing notes and Linking sections. Helpers live in `scripts/topic_tools.py` (`python3 <skill-dir>/scripts/topic_tools.py ...`). Read commands are safe; `backlink` is dry-run unless `--apply` is passed.

## What may be edited

- Tasks, Events and Topics: `topics:` and `aliases:` frontmatter, and link lines in prose, as below.
- Never edit plugin-owned notes in `Readwise/`; they receive inbound links only.
- Never edit existing daily notes, except to fix a path-qualified link broken by a move.
- Never edit hub notes that are queries (`Topics.md`, `Events.md`, a project note's Research section). The frontmatter is the whole mechanism.
- An Event's body records a point in time. Change its `topics:`; leave its prose alone.

## Linking new notes

Writes without asking first, then reports every change. That is safe because the edits only add links, and the vault is in git.

1. Identify the notes: the ones the user names, or `git --no-optional-locks status --porcelain -- '*.md'` ignoring `.obsidian/`, `.smart-env/`, `Vault Metadata/` and `Attachments/`. State the list before continuing.
2. Read each note in full. Note its distinct claims, terms and named entities.
3. Find the Topics it belongs to: search the project's `Topics/` and the domain folders for each term with `grep -rli --include=*.md`, using synonyms and the vault's own vocabulary. Read each candidate. Relevance means the note is about the subject, not that it shares a word; a mention in the body is not membership.
4. Write the Topics into the note's `topics:` list. Prefer a project Topic when the note belongs to a project. A Readwise note cannot carry `topics:`; link it from the Topic instead.
5. Add a direct link from an existing note to the new note only where the existing note cites the new note's source or explicitly mentions its subject: inline at the mention, or `See also [[Note Title]], which …`. Match the target's style. For an Event use the aliased form `[[YYYY-MM-DD HHMMSS Title|Title]]`. Append today's date as `[[YYYY-MM-DD]]` to the footer of each existing note edited, when it has a date footer.
6. Report: a table of links added (from, to, kind, why); notes with no fitting Topic, each with the Topic that could hold it; close calls rejected. A note that received no links is a result to report, not to hide.

## Project pass

Propose-then-apply: analyse, show candidates and counts, get the go-ahead, then write. Never bulk-edit without confirmation.

1. **Audit.** `topic_tools.py audit --project DIR` reports Tasks and Events whose `topics:` names no Topic, separating notes that still carry the legacy H1 link line from notes with none, plus Topic-to-Topic connectivity. Legacy notes are moved to `topics:` with `backlink --apply`, mapping each Topic to a regex of its name and aliases.
2. **Find candidate Topics.** `topic_tools.py clusters --project DIR` (add `--keywords map.json` of `{"Label": "regex"}` to quantify suspected themes). A good Topic is a recurring subject, distinct from existing hubs; 10+ related notes is a strong signal, a coherent smaller cluster counts. Present a ranked shortlist with counts and a one-line rationale each; flag overlaps with existing Topics and decide merge-versus-keep before splitting.
3. **Create approved hubs** in `Topics/`: frontmatter per `obsidian-vault` with `aliases:` for abbreviations and variants; `# [[<Topic>]]` then `[[<Project>]]`; 2–5 short prose sections (what it is, why it matters, recurring themes, where it lives in code); a `## See also` line of middot-separated wikilinks. No hand-enumerated task links; a Dataview table over `topics:` is fine. Match the voice of existing hubs. A recurring meeting series gets a Topic whose note lists its Events with a query.
4. **Attach notes.** `topic_tools.py backlink --project DIR --map "Topic=\bregex\b" ... [--exclude file]`. Dry-run first, read the matched files, curate false positives with `--exclude` rather than loosening the regex, then `--apply`. Idempotent.
5. **Interlink.** Topic-to-Topic `See also` links are evidence-gated: add one only when the two Topics co-occur in real Task or Event text. Never invent a link to clear an orphan count; a false link is worse than an orphan. A standalone definition with no outgoing link is acceptable.
6. **Hygiene.** Merge duplicate Topics (a definition and a hub for one concept) into one note, fold the alias on, delete the duplicate, and collapse any `[[Projects/.../full/path]]` links Obsidian created back to bare `[[Name]]`. A dated, completed write-up (a retro, a posted analysis) belongs in `Tasks/`: give it task frontmatter with `completedDate`, move it, and extract its durable lessons into the relevant hubs.
7. **Graduate.** On a full pass, or when asked, read [GRADUATION.md](GRADUATION.md). `topic_tools.py crosscut --project DIR` ranks suspects; the decision is the user's.
8. **Verify.** `topic_tools.py linkcheck --project DIR --vault VAULT`. After a move, run it from the vault root so cross-project incoming links are covered. It checks file existence only; inspect ambiguous basenames and heading anchors by hand.

## Notes

- Deleting files in a connected vault may need delete permission; if `rm` reports "Operation not permitted", request it rather than reporting it impossible.
- Nothing here is specific to one project: point it at any `Projects/<Name>/` with `Topics/` and `Tasks/`.
