---
name: TypeScript Development
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

## Testing (Vitest / Jest)

```typescript
describe('FeatureName', () => {
  it('describes expected behaviour', () => {
    // Arrange
    const input = createTestData()

    // Act
    const result = functionUnderTest(input)

    // Assert
    expect(result).toEqual(expected)
  })
})
```

**Assertions:**

- `expect(obtained).toEqual(expected)`
- `expect(list).toHaveLength(n)`
- `expect(fn).toThrow(ErrorType)`
- `expect(result).toBeUndefined()`

**Run tests:**

```bash
pnpm test                           # full suite
pnpm test -- --testPathPattern=file # specific file
npx vitest run src/feature.test.ts  # vitest specific file
npx jest --testPathPattern=feature  # jest specific file
```

## Functional Patterns

**Transform with map:**

```typescript
// ❌ Imperative
const results: Output[] = []
for (const item of items) {
  results.push(transform(item))
}

// ✅ Functional
const results = items.map(transform)
```

**Pipeline with reduce:**

```typescript
const pipeline = <T>(...fns: Array<(x: T) => T>) =>
  (initial: T): T =>
    fns.reduce((acc, fn) => fn(acc), initial)
```

**Option type for nullable values:**

```typescript
type Option<T> = T | undefined

const map = <T, U>(opt: Option<T>, fn: (t: T) => U): Option<U> =>
  opt !== undefined ? fn(opt) : undefined

const getOrElse = <T>(opt: Option<T>, defaultValue: T): T =>
  opt !== undefined ? opt : defaultValue
```

## Error Handling

**Result pattern:**

```typescript
type ParseError = { message: string; line: number }

const parse = (input: string): Result<Value, ParseError> => {
  try {
    return ok(JSON.parse(input))
  } catch (e) {
    return err({ message: String(e), line: 0 })
  }
}

// Pattern match on result
const handle = (result: Result<Value, ParseError>) => {
  switch (result._tag) {
    case 'Ok':
      return processValue(result.value)
    case 'Err':
      return handleError(result.error)
  }
}
```

## Common Libraries

- **Effect** - Typed functional effects
- **zod** - Schema validation
- **neverthrow** - Result type
- **fp-ts** - Functional programming utilities
- **tsx** - TypeScript execution
