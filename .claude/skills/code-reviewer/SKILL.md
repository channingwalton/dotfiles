---
name: Code Reviewer
description: Review code for best practices and potential issues. Use when reviewing code, checking PRs, or analyzing code quality.
allowed-tools: Read, Grep, Glob
dependencies: []
related-skills:
  - test-driven-development
---

# Code Reviewer

## Dependencies

**None** - Standalone skill for code review.

### Related Skills
- **test-driven-development** - Reviews should verify TDD principles are followed

## Review Checklist

  ### 1. Code Organisation & Structure
  - [ ] Single Responsibility Principle followed
  - [ ] Appropriate abstraction levels
  - [ ] Clear naming conventions
  - [ ] Logical file/module organisation

  ### 2. Error Handling
  - [ ] All error cases handled
  - [ ] Appropriate error types used
  - [ ] User-friendly error messages
  - [ ] No silent failures

  ### 3. Performance
  - [ ] No obvious inefficiencies (N+1, unnecessary loops)
  - [ ] Appropriate data structures
  - [ ] Resource cleanup (files, connections)

  ### 4. Security
  - [ ] Input validation
  - [ ] No hardcoded secrets
  - [ ] Proper authentication/authorisation
  - [ ] SQL injection prevention (if applicable)

  ### 5. Test Coverage
  - [ ] Critical paths tested
  - [ ] Edge cases covered
  - [ ] Tests are maintainable

  ## Output Format
  Provide findings as:
  - 🔴 CRITICAL: Must fix before merge
  - 🟡 WARNING: Should address
  - ℹ️ SUGGESTION: Nice to have

## Instructions

1. Read the target files using Read tool
2. Search for patterns using Grep
3. Find related files using Glob
4. Provide detailed feedback on code quality
