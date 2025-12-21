# TDD Plan: HashMap Bug Fixes and Improvements

## Overview
Fix all critical bugs and issues identified in code review using strict TDD (RED-GREEN-REFACTOR).

## Files to Modify
- `src/main/scala/HashMap.scala` - Implementation fixes
- `src/test/scala/HashMapSuite.scala` - New tests

## Execution Order (TDD Cycles)

### Phase 1: Critical Bug Fixes

#### 1.1 Fix remove() hash inconsistency
- **RED**: Add test `remove uses correct hash calculation`
- **GREEN**: Change line 36 from `hash % capacity` to `index(k)`
- **REFACTOR**: None needed

#### 1.2 Fix infinite loop in get()
- **RED**: Add test `get non-existent key doesn't hang`
- **GREEN**: Add loop termination (track start position)
- **REFACTOR**: Extract probing logic if beneficial

#### 1.3 Fix infinite loop in remove()
- **RED**: Add test `remove non-existent key doesn't hang`
- **GREEN**: Add loop termination condition
- **REFACTOR**: Consolidate with get() fix if possible

#### 1.4 Fix tombstone handling (probe chain breakage)
- **RED**: Add test `get after remove with collision still finds key`
- **GREEN**: Implement rehashing of cluster after removal
- **REFACTOR**: Consider tombstone markers vs rehash approach

#### 1.5 Move rebalance() inside successful remove branch
- **RED**: Existing tests should still pass
- **GREEN**: Move rebalance() call inside `if` block
- **REFACTOR**: None needed

### Phase 2: Null/Option Consistency

#### 2.1 Standardise on null checks (simpler for mutable HashMap)
- **RED**: Existing tests pass
- **GREEN**: Change `Array[Option[K]]` to `Array[K]` with null sentinel
- **REFACTOR**: Update all option-related code

**OR** (alternative approach):

#### 2.1 Standardise on Option checks
- **RED**: Existing tests pass
- **GREEN**: Replace null checks with `== None` checks
- **REFACTOR**: Ensure consistency throughout

### Phase 3: Input Validation

#### 3.1 Validate constructor parameters
- **RED**: Add tests for invalid capacity/loadFactor
- **GREEN**: Add `require()` statements
- **REFACTOR**: None needed

### Phase 4: API Improvements (Optional)

#### 4.1 Return previous value from put()
- **RED**: Add test `put returns previous value`
- **GREEN**: Change return type to `Option[V]`
- **REFACTOR**: Update callers

#### 4.2 Return removed value from remove()
- **RED**: Add test `remove returns removed value`
- **GREEN**: Change return type to `Option[V]`
- **REFACTOR**: None needed

#### 4.3 Add contains() method
- **RED**: Add test for contains
- **GREEN**: Implement contains()
- **REFACTOR**: Use in other methods if beneficial

### Phase 5: Structural Improvements

#### 5.1 Change case class to class
- **RED**: Existing tests pass
- **GREEN**: Remove `case` keyword
- **REFACTOR**: None needed

#### 5.2 Fix toString()
- **RED**: Add test for readable toString
- **GREEN**: Fix implementation
- **REFACTOR**: None needed

## Test Cases to Add (Summary)

```scala
// Critical bug exposure tests
test("remove uses correct hash calculation")
test("get non-existent key returns None without hanging")
test("remove non-existent key completes without hanging")
test("get after remove with collision still finds key")
test("remove then re-add same key works")

// Validation tests
test("cannot create with zero capacity")
test("cannot create with negative capacity")
test("cannot create with loadFactor <= 0")
test("cannot create with loadFactor >= 1")

// Edge case tests
test("operations on empty HashMap")
test("key with negative hashCode")
test("key with zero hashCode")
test("near-full table operations")
```

## Decisions

- **Array type**: Null arrays (`Array[K]` with null checks)
- **Scope**: Full improvements (all phases)
