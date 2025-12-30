---
name: Development
description: Implement features using strict test-driven development, TDD. Use when working with any code.
---

# Development

## Core Rules (Non-Negotiable)

0. Follow the TDD Cycle below
1. **NEVER write production code without a failing test first**
2. One behaviour per test
3. Write minimum code to make the test pass
4. Run tests and verify green state before proceeding
5. Keep project documentation up to date

## The TDD Cycle

```
📋 TASK     → Review task file (vault skill)
🔎 SEARCH   → Search vault for similar tasks for context (vault skill)
🧠 THINK    → Think deeply about the problem and produce a plan
🔴 RED      → Write a failing test
🟢 GREEN    → Write minimum code to pass the failing test
✅ VERIFY   → Run all tests, confirm all passing
👀 REVIEW   → Check changes (code-reviewer agent)
⚠️ FIX      → Address issues arising from review
🔵 REFACTOR → Improve code (refactor skill)
💾 COMMIT   → Save working state (commit-helper agent)
📝 LOG      → Update task file with decisions and outcomes
🧠 MEMORY   → Update memory with salient facts
❓ ASK      → Ask the user what to do next
```

## Common Mistakes

See `references/common-mistakes.md` for anti-patterns to avoid.
