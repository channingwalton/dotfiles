# Fix DST Issues in Compliance Module

## Problem
Duration calculations using `LocalDateTime` are DST-unaware. In Europe/London:
- Spring forward (30 March 2025): 01:00→02:00 (23-hour day)
- Fall back (26 October 2025): 02:00→01:00 (25-hour day)

`Duration.between(LocalDateTime, LocalDateTime)` calculates wall-clock difference, not actual elapsed time.

## Approach: Change Domain Model to ZonedDateTime

Convert `ComplianceShift` and `CompoundShift` from `LocalDateTime` to `ZonedDateTime` throughout. API continues to accept `LocalDateTime` but converts to `ZonedDateTime` using `defaultTimeZone` at the boundary.

---

## Files to Modify

### 1. Domain Models

**`compliance/src/main/kotlin/com/patchwork/compliance/model/ComplianceShift.kt`**
```kotlin
// Change:
val startDateTime: LocalDateTime  →  val startDateTime: ZonedDateTime
val endDateTime: LocalDateTime    →  val endDateTime: ZonedDateTime
```

**`compliance/src/main/kotlin/com/patchwork/compliance/model/CompoundShift.kt`**
```kotlin
// Change fields:
val startDateTime: LocalDateTime  →  val startDateTime: ZonedDateTime
val endDateTime: LocalDateTime    →  val endDateTime: ZonedDateTime

// Duration calculation now uses Instant for accurate DST-aware calculation:
val duration = Duration.between(startDateTime.toInstant(), endDateTime.toInstant()).toMinutes() / 60.0

// isBetween() - keep using LocalDate for calendar-day semantics (intentional):
fun isBetween(start: LocalDate, end: LocalDate): Boolean =
    this.startDateTime.toLocalDate().isAfterOrEqual(start) &&
    this.endDateTime.toLocalDate().isBeforeOrEqual(end)
```

### 2. Builder

**`compliance/src/main/kotlin/com/patchwork/compliance/CompoundShiftBuilder.kt`**
```kotlin
// Update grouping to use ZonedDateTime.toLocalDate():
val shiftsGroupedByDate = shifts.groupBy { it.startDateTime.toLocalDate() }
```

### 3. API Layer (Boundary Conversion)

**`compliance/src/main/kotlin/com/patchwork/compliance/api/ComplianceChecksContract.kt`**
```kotlin
import com.patchwork.common.util.defaultTimeZone

// ApiComplianceShift.toDomain() - convert LocalDateTime to ZonedDateTime:
fun toDomain(): ComplianceShift =
    ComplianceShift(
        id = id,
        startDateTime = start.atZone(defaultTimeZone),
        endDateTime = end.atZone(defaultTimeZone),
        isNonResidentOnCall = nonResidentOnCall,
        source = source.toDomain()
    )
```

### 4. Rules (Duration Calculations)

**`compliance/src/main/kotlin/com/patchwork/compliance/rules/MinRestBetweenShifts.kt`**
```kotlin
// Change Duration.between to use Instant:
val restHours = Duration.between(
    previousShift.endDateTime.toInstant(),
    currentShift.startDateTime.toInstant()
).toHours()
```

**`compliance/src/main/kotlin/com/patchwork/compliance/rules/MinRestInWeekOrTwoWeeks.kt`**
```kotlin
// Line 44-47: Change to Instant
val restHours = Duration.between(
    previousShift.endDateTime.toInstant(),
    currentShift.startDateTime.toInstant()
).toHours()

// Line 54-57: Change to Instant
val periodDays = Duration.between(
    compoundShifts[lastLongerBreak].startDateTime.toInstant(),
    currentShift.endDateTime.toInstant()
).toRoundedUpDays()
```

**`compliance/src/main/kotlin/com/patchwork/compliance/rules/MaxAverageHoursPerWeek.kt`**
- Review and update any duration calculations similarly

**`compliance/src/main/kotlin/com/patchwork/compliance/rules/MaxShiftDuration.kt`**
- Review and update any duration calculations similarly

### 5. Test Helpers

**`compliance/src/test/kotlin/com/patchwork/compliance/TestHelpers.kt`**
```kotlin
import com.patchwork.common.util.defaultTimeZone

fun ComplianceShift.Companion.sampleRotaShift(
    id: Long = Random.nextLong(),
    start: String = "2025-01-01T09:00:00",
    end: String = "2025-01-01T17:00:00"
) = ComplianceShift(
    id,
    startDateTime = LocalDateTime.parse(start).atZone(defaultTimeZone),
    endDateTime = LocalDateTime.parse(end).atZone(defaultTimeZone),
    ComplianceShiftSource.ROTA,
    false
)

// Similar changes for sampleTempStaffingShift, sampleNrocShift, createDayShiftsOnDates
```

---

## DST Tests (Historical Dates)

Create new test file: **`compliance/src/test/kotlin/com/patchwork/compliance/rules/DaylightSavingsTimeTest.kt`**

### Europe/London 2025 DST Transitions
- **Spring forward:** 30 March 2025 at 01:00 → 02:00 (clocks skip 1 hour)
- **Fall back:** 26 October 2025 at 02:00 → 01:00 (clocks repeat 1 hour)

### Test Cases

#### 1. MinRestBetweenShifts - Spring Forward
```kotlin
@Test
fun `rest period spanning spring DST transition is calculated correctly`() {
    // Shift ends at 23:00 on 29 March 2025
    // Next shift starts at 10:00 on 30 March 2025
    // Wall-clock difference: 11 hours
    // Actual elapsed time: 10 hours (due to DST skip)
    // Should FAIL the 11-hour minimum rest requirement
}
```

#### 2. MinRestBetweenShifts - Fall Back
```kotlin
@Test
fun `rest period spanning autumn DST transition is calculated correctly`() {
    // Shift ends at 23:00 on 25 October 2025
    // Next shift starts at 10:00 on 26 October 2025
    // Wall-clock difference: 11 hours
    // Actual elapsed time: 12 hours (due to DST repeat)
    // Should PASS the 11-hour minimum rest requirement
}
```

#### 3. MinRestBetweenShifts - Edge Case at Boundary
```kotlin
@Test
fun `exactly 11 hours rest with spring DST transition fails`() {
    // End: 29 March 2025 23:00
    // Start: 30 March 2025 11:00 (wall-clock 12h, actual 11h)
    // Should PASS (exactly 11 hours actual)
}

@Test
fun `exactly 11 hours wall-clock with spring DST transition fails`() {
    // End: 29 March 2025 23:00
    // Start: 30 March 2025 10:00 (wall-clock 11h, actual 10h)
    // Should FAIL (only 10 hours actual)
}
```

#### 4. MinRestInWeekOrTwoWeeks - Week Spanning DST
```kotlin
@Test
fun `7-day period spanning spring DST calculates rest correctly`() {
    // 7 calendar days from 24 March to 30 March 2025
    // Actual hours: 167 instead of 168
    // Test that rest calculation uses actual elapsed time
}
```

#### 5. CompoundShift Duration - Shift Crossing DST
```kotlin
@Test
fun `shift duration crossing spring DST boundary calculated correctly`() {
    // Shift from 30 March 2025 00:00 to 30 March 2025 04:00
    // Wall-clock: 4 hours, Actual: 3 hours
    // Duration should be 3.0 hours
}

@Test
fun `shift duration crossing autumn DST boundary calculated correctly`() {
    // Shift from 26 October 2025 00:00 to 26 October 2025 04:00
    // Wall-clock: 4 hours, Actual: 5 hours
    // Duration should be 5.0 hours
}
```

#### 6. MaxAverageHoursPerWeek - 182-day Period with DST
```kotlin
@Test
fun `182-day reference period spanning both DST transitions calculates hours correctly`() {
    // Period from 1 Feb 2025 to 2 Aug 2025 spans both transitions
    // Net effect: 0 hours (one gained, one lost)
    // Verify total hours calculation is accurate
}
```

---

## Implementation Order

1. Update `ComplianceShift.kt` - change fields to `ZonedDateTime`
2. Update `CompoundShift.kt` - change fields and fix duration calculation
3. Update `CompoundShiftBuilder.kt` - adapt to `ZonedDateTime`
4. Update `ComplianceChecksContract.kt` - add boundary conversion
5. Update all rule files to use `.toInstant()` in `Duration.between()`
6. Update `TestHelpers.kt` - create shifts with `ZonedDateTime`
7. Fix existing tests (should pass with same behaviour for non-DST dates)
8. Add `DaylightSavingsTimeTest.kt` with DST-specific tests
9. Run all tests and verify

---

## Key Design Decisions

1. **API stays with LocalDateTime** - Backwards compatible; conversion happens at boundary
2. **Domain uses ZonedDateTime** - Explicit timezone context throughout domain logic
3. **Duration calculations use Instant** - `Duration.between(Instant, Instant)` gives true elapsed time
4. **Calendar-day operations stay LocalDate** - `isBetween()` uses calendar semantics (intentional)
5. **Use existing `defaultTimeZone`** - Consistent with codebase pattern from `SystemClock.kt`
