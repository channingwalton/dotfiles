# Unison Common Pitfalls

## Pipe Operator Syntax

❌ **WRONG:**
```unison
postKeys = rangeClosed.prefix.keys.tx table prefix id id
  |> Stream.toList
```

✅ **CORRECT:**
```unison
postKeys = (rangeClosed.prefix.keys.tx table prefix id id |> Stream.toList)
```

## List.foreach Argument Order

❌ **WRONG:**
```unison
List.foreach items (item -> doSomething item)
```

✅ **CORRECT:**
```unison
List.foreach (item -> doSomething item) items
```

## Pattern Matching Tuples

✅ **CORRECT:**
```unison
Stream.filter (cases (_, predId) -> predId === id)
```

## Effect Signatures

Ensure function signatures include all required effects:

```unison
myFunction : Type ->{Transaction, Exception, Random} Result
```

## Delayed Computations

Use `'` for thunks (delayed computations):

```unison
-- Type: '{IO} Result means "a computation that when forced, does IO and returns Result"
myAction : '{IO, Exception} Result
myAction = do
  -- code here
```

## Do Blocks

`do` creates a delayed computation. Don't double-wrap:

❌ **WRONG:**
```unison
myTest = do
  '(test.verify do ...)
```

✅ **CORRECT:**
```unison
myTest = do
  test.verify do ...
```
