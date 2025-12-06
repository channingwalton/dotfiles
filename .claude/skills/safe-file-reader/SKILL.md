---
name: Safe File Reader
description: Read-only file access without modification risk. Use when you need to view files, search content, or explore codebases without making changes.
---

# Safe File Reader

Read-only file operations:

1. **Read** — view file contents
2. **Grep/rg** — search within files
3. **Glob** — find files by pattern

## Large Files

For files over 1000 lines:
- Use `head`/`tail` to preview
- Use `grep`/`rg` to find specific sections
- Read in chunks if full content needed
