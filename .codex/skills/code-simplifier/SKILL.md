---
name: code-simplifier
description: Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Focuses on recently modified code unless instructed otherwise.
---

# Code Simplifier

Code is an argument — simplification means making it **easier to follow**, not shorter or cleverer. If a reader can't trace from inputs to outputs without backtracking, the code is too complex.

## Process

### 1. Identify Target Files

- **Default scope**: `git diff --name-only HEAD~3` for recently modified files
- **Broader scope**: If instructed, use Glob/Grep to match a pattern or directory
- Filter out non-code files (configs, lockfiles, generated code)

### 2. Simplify Each File

Read thoroughly, then apply the guidelines below.

### 3. Report

Summarise all changes, grouped by file.

## Guidelines

### Preserve Functionality

Never change what the code does — only how it does it.

### Apply Project Standards

Follow established coding standards from `AGENTS.md`.

### Enhance Clarity

- Reduce nesting beyond 2 levels — exceeds working memory
- Eliminate redundant code — redundancy invites contradiction when one copy changes
- Use clear variable and function names — ambiguous names are **undefined terms**
- Consolidate related logic — premises that belong together should be together
- Remove comments that restate what code already says
- Avoid nested ternaries — prefer switch/if-else
- Choose clarity over brevity
- Avoid early returns in expression-oriented languages — prefer single return

### Maintain Balance

Simplification fails when it makes code *harder* to reason about:
- Overly clever solutions hide steps the reader must reconstruct
- Combining too many concerns conflates separate arguments
- Don't prioritise "fewer lines" over readability
- Don't remove abstractions that aid organisation
