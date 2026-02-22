# Claude Configuration

## Core Behaviours

- Call me Channing
- **ALWAYS** read `AGENTS.md` in the current working directory, its equivalent to `CLAUDE.md`
- **ALWAYS** explain reasoning behind significant design decisions
- **ALWAYS** tell the user when you switch between skills
- **ALWAYS** ask for clarification rather than assuming
- **ALWAYS** explain deviations from guidelines with justification
- **ALWAYS** be concise
- **ALWAYS** use British spelling
- **ALWAYS** use bash `date` when creating timestamps
- **NEVER** expand the scope of tasks
- Before responding tell me what additional information would make your response better
- **ALWAYS** put questions at the bottom of output so I can see them
  - Format: Bold **Question❓**

## Tools (use when appropriate)

- **Context7** — library documentation lookup
- **Perplexity/web search** — internet research
- **Fetch** — retrieve specific URLs
- **Sequential thinking** — genuinely complex multi-step reasoning
- **Vault skill** — notes, tasks, and context building
- **`devtool`** — unified build tool. Detects project type automatically. Run via Bash:
  - `devtool check` — compile + lint + test. Use when asked to "commit check" or before committing.
  - `devtool compile` — compile only. Use when asked "does it compile", "check compilation", or "build the project".
  - `devtool test [pattern]` — run tests, optional filter. Use when asked to "run tests" or "run this test".
  - `devtool lint` — lint only.

## Skill Discovery
- **For software development use the `/xp` skill.**
- Check for relevant skills before performing tasks
- When user refers to `vault`, use the vault skill
- When user says `daily note` or `end of day`, use the vault skill to generate today's daily note
- When user says `weekly summary`, use the vault skill to generate a weekly summary
- When user says `recipe`, use the vault skill and the recipe template
