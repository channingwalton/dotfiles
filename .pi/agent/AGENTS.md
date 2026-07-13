## Tools (use when appropriate)

- **Vault skill** — notes, tasks, and context building
- **`devtool`** — unified build tool. Detects project type automatically. Run via Bash:
  - `devtool check` — compile + lint + test. Use when asked to "commit check" or before committing.
  - `devtool compile` — compile only. Use when asked "does it compile", "check compilation", or "build the project".
  - `devtool test [pattern]` — run tests, optional filter. Use when asked to "run tests" or "run this test".
  - `devtool lint` — lint only.
  - `devtool cpd <language> [directory]` — find duplicate code using PMD CPD. Use during code review or when asked to find duplicates.
  - Output is suppressed on success; on failure the full log is cat'd between `--- output ---` markers and the log file path is printed (no need to re-run). Set `DEVTOOL_VERBOSE=1` to stream live.
- Prefer LSP over Grep/Read for code navigation
  - After writing or editing code, check LSP diagnostics and fix errors before proceeding.
  - Use Grep or rg only when LSP isn't available or for text/pattern searches (comments, strings, config).
- ast-grep is installed. Reach for it when the *match condition itself is structural* and a text search can't express it without false positives (e.g. "useEffect missing deps", "catch blocks that swallow errors", "calls to X with a literal arg"), or for shape-based codemods (`-r`). Use `ast-grep --lang [language] -p '<pattern>'`; adjust `--lang` per language. It is syntactic, not type-aware — for "where is X defined / who calls it" use LSP, and for plain text-locate use rg. Do not lead with ast-grep for ordinary locate-then-read exploration; its iteration cost (standalone-parse traps, node kinds) only pays off on genuinely structural queries. When a `-p` pattern misbehaves, run `--debug-query=ast` to find the real node kind, then write a YAML rule (`kind`/`inside`/`regex`).
