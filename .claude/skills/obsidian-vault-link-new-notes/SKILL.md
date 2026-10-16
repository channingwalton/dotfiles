---
name: "obsidian-vault-link-new-notes"
description: "Use after new notes are added to the Obsidian vault (Readwise imports, Events, Topics, any note) to link them into existing notes, routing links through Topics."
---

# Link new notes into the vault

The vault is at `~/Documents/Notes`. This skill connects new notes to existing notes. It edits existing notes and the new notes. It never creates notes.

## Principles

- **Links go through Topics by default.** A new note is added to the relevant Topic note, and the new note links to that Topic. Do not add direct links between every pair of related notes.
- **Direct links only for citations or explicit mentions.** Add a direct link from an existing note to a new note only where the existing note cites the new note's source, or explicitly mentions its subject (the article, paper, author, person, tool, organisation or event).
- **Existing meeting and email Events are never edited.** They record a point in time. New notes may link to them.
- **Plugin-owned notes are never edited.** Readwise notes (`Readwise/`) are written by the sync plugin. They receive inbound links only.

## 1. Identify the new notes

Use the notes the user names. Otherwise list new and changed notes from git, without taking locks:

```
git --no-optional-locks status --porcelain -- '*.md'
```

Ignore `.obsidian/`, `.smart-env/`, `Vault Metadata/` and `Attachments/`. State the list before continuing.

## 2. Read each new note

Read it in full. Write down its distinct claims, terms and named entities (authors, papers, people, tools, organisations, projects). These drive the search.

## 3. Find related notes

Search the vault for each term and entity with `grep -rli --include=*.md`. Use synonyms and the vault's own vocabulary, not only the new note's wording. Read each candidate before deciding. Relevance means the note discusses the same idea, not that it shares a word.

Sort the candidates into:

- **Topics.** Project Topics in `Projects/<Project>/Topics/`, and general hub notes outside projects (for example in `Development/`, `Artificial Intelligence/`, `Knowledge management/`). Prefer a project Topic when the new note belongs to a project.
- **Citing or mentioning notes.** Existing notes containing a sentence that cites or explicitly mentions the new note's subject.
- **Merely related notes.** Neither of the above. These get no direct link. They are reached through the Topic.

## 4. Decide which notes may be edited

Never edit:

- Existing Events with `type: meeting` or `type: email` (frontmatter, or `meeting` / `email` in the filename after the timestamp).
- Existing daily notes in `Journal/Daily Notes/`.
- Plugin-owned notes in `Readwise/`.
- Backlink-target index files such as `Topics.md`, `Events.md`, `Readwise.md`, `Index.md` and other bare-heading hub files. The footer link from each note is the whole mechanism.

Everything else may be edited, including new meeting and email Events and existing Events of other types (`document`, `event`, `decision`, `observation`).

## 5. Add the links

Match the style the target note already uses. Do not add a new section if an existing one fits.

**Inbound to the new note:**

- Topic notes that are lists of links: `- [[Note Title]] — <one clause on what it contributes>`.
- Research strand notes citing an external source: `- Author, A. (Year). [[Note Title]]. Publisher. <one or two sentences on what it contributes>. <Caveat if vendor or opinion writing.>`
- A sentence that explicitly mentions the subject: link the mention inline, or add `See also [[Note Title]], which …` beside it.
- Notes with a `## See also` section: append `· [[Note Title]]`.

**Outbound from the new note** (skip for plugin-owned notes):

- Events: add relevant Topics to the `topics:` frontmatter list as `"[[Topic]]"`, and link explicitly mentioned people, organisations and notes inline. New meeting and email Events may link to existing meeting and email Events.
- Other notes: link the relevant Topic near the top, matching how sibling notes do it, and link explicit mentions inline.

For an Event, use the aliased form `[[YYYY-MM-DD HHMMSS Title|Title]]`. Otherwise the link text is the filename without `.md`.

Append today's date as `[[YYYY-MM-DD]]` to the footer of each existing note edited, when it has a date footer. Do not replace earlier dates. Get today's date from the system, not from memory.

Use British spelling. Keep added text short and in the note's voice.

## 6. Report

End with:

- A table of links added: from, to, kind (Topic, citation, mention, outbound), one line on why.
- New notes with no Topic, each with the Topic that could hold it. Do not create the Topic.
- New notes that received no links, each with a reason. A note with no links is a result to report, not to hide.
- Close calls considered and rejected, briefly.
