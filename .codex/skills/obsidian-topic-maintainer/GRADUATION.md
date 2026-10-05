# Graduation (step 6)

Step 6 of the topic-maintainer workflow in [SKILL.md](SKILL.md). Steps 5 and 8 below refer to that workflow.

Most Topics describe *this* project and stay. A few are really **cross-cutting concepts** that will recur elsewhere — promote those into a shared domain folder so project work compounds into reusable knowledge. Canonical procedure: the vault note `[[Topic graduation]]`. This step is **conservative by default** — when in doubt, leave it in the project.

**Where to look.** The prime suspects are the notes step 5 parks in the skip-list as "standalone definition / reference stubs", and any note whose links already resolve vault-wide rather than to project topics. Re-evaluate those here instead of parking them forever. The `crosscut` command (read-only) ranks them:
```
python3 <skill-dir>/scripts/topic_tools.py crosscut --project "<PROJECT_DIR>"    # --max-words tunes the stub threshold (default 40)
```
One line per suspect: fired signals (definition-style stub, links resolving outside the project, linked from other projects, skip-listed as standalone), cross-project reference count, and a suggested destination domain folder where one fits. It only detects — apply the three-part test below yourself.

**The test — graduate only if all three hold:**
1. **Concept-oriented, not project-oriented.** Ask: *would I want this note when working on a different project?* Names tied to this project (clients, sites, internal systems, ticket-specific behaviour) fail — they stay.
2. **A real destination domain folder already exists** (`Development/`, `Artificial Intelligence/`, ...). If the concept is genuinely cross-cutting but has **no** home folder, do **not** invent a top-level folder — surface it to the user as a naming decision and leave the note in place until they choose. (A dense project-specific domain — e.g. an NHS rostering product — is correct as-is; do not strip it for the sake of promotion.)
3. **The concept is actually stated.** A stub title is not knowledge. If the note is a stub, distil it into a proper atomic note first (or flag that it needs writing) — don't move an empty hull.

Present graduation candidates with destinations and a one-line rationale when those choices remain open. Apply moves already authorised by the user directly. Expect the candidate list to be short or empty.

**To graduate an approved Topic:**
- Distil it into an atomic, concept-oriented note in your own words (drop project-specific incidental detail, or split it out — keep the project-specific part as a project Topic that links the new general note).
- Move it to the domain folder (`git mv` if the vault is a git repo). Preserve its basename, update affected path-qualified incoming links and source-relative outgoing links, and leave no stub behind.
- Re-point the parent link from `[[Topics]]`/`[[<Project>]]` to `[[<Domain>]]`, drop the `project:` frontmatter binding, and add a `Used in [[<Project>]]` line so the project relationship stays explicit.
- Ensure the note links `[[<Domain>]]`; a Dataview-backed MOC then surfaces it automatically. If the domain hub is a hand-maintained list, add the note to it.
- Verify file targets with `linkcheck` (step 8) and inspect any ambiguous or heading/block links affected by the move.
