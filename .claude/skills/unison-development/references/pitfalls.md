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

## Success Criteria

✅ All code typechecks successfully
✅ Tests written before implementation
✅ Fully qualified names in scratch.u
✅ Modified functions show `~` not `+`
✅ Comprehensive test coverage
✅ Memory updated with learnings
