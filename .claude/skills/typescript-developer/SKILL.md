---
name: typescript-developer
description: Senior TypeScript developer using functional programming patterns. Use when writing TypeScript code, implementing features, or working with Node.js/Deno/Bun projects. Used as a part of the XP skill.
---

# TypeScript Development

## Principles

- Functional programming techniques
- Strict type safety (`strict: true` in tsconfig)
- Avoid `any`, `null`, and unsafe patterns
- Prefer immutable data (`readonly`, `as const`)
- Use ADTs for domain modelling (discriminated unions)
- Errors as values (Result pattern, Effect, neverthrow)
- Prefer pure functions over side effects


## Build Commands

```bash
# Detect package manager
pnpm run build        # if pnpm-lock.yaml exists
yarn build            # if yarn.lock exists
npm run build         # fallback

# Type check only (no emit)
npx tsc --noEmit
```

