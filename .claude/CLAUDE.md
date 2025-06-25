# Claude

## General rules

1. Memory Retrieval:
  - Always begin your chat by saying only "Remembering..." and retrieve all relevant information from your knowledge graph
  - Always refer to your knowledge graph as your "memory"
2. Memory
  - While conversing with the user, be attentive to any new information that falls into these categories:
    a. Basic Identity (age, gender, location, job title, education level, etc.)
    b. Behaviours (interests, habits, etc.)
    c. Preferences (communication style, preferred language, etc.)
    d. Goals (goals, targets, aspirations, etc.)
    e. Relationships (personal and professional relationships)
    f. Projects
  - If any new information was gathered during the interaction, update your memory as follows:
    a. Create entities for recurring organizations, people, and significant events
    b. Connect them to the current entities using relations
    c. Store facts about them as observations
3. Projects:
  - Remember project specific information that would be useful when returning to the project
4. Obsidian vault
  - Refer to the obsidian vault at `~/Documents/Notes/` to garner more information
    - Project specific information is in `~/Documents/Notes/Permanent/Projects`
  - Refer to my GitHub profile and projects: `channingwalton`

## Development Guidelines for Claude

### Quick Reference

**Key Principles:**

- Write tests first (TDD)
- Commit after writing the test and before implementing the code to make it pass
- Commit after writing the implementation and the test passes
- Test behaviour, not implementation
- No `Any` types, type assertions or null
- Immutable data only
- Small, pure functions
- Projects should be layered with clear responsibilities for each layer
- Use Context7 to pull up-to-date, version-specific, documentation and code examples.

Keep the README up-to-date.

**Preferred Scala Tools:**

- **Libraries**: Typelevel libraries: cats, cats-effect, Http4s, Circe, doobie
- **Testing**: munit, munit-cats-effect, scalacheck
- **Builds**: SBT

### Core Philosophy

**TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.** Every single line of production code must be written in response to a failing test. No exceptions. This is not a suggestion or a preference - it is the fundamental practice that enables all other principles in this document.

Follow Test-Driven Development (TDD) and functional programming principles. All work should be done in small, incremental changes that maintain a working state throughout development.

### Testing Principles

- Tests should verify expected behaviour, treating implementation as a black box
- Test through the public API exclusively - internals should be invisible to tests
- 100% coverage should be expected at all times but it isn't the goal, it should emerge from TDD 
- Tests must document expected business behaviour

### Scala Guidelines

- **No `Any`** - ever
- **No null** - ever
- **No type assertions** (`asInstanceOf`) unless absolutely necessary with clear justification
- These rules apply to test code as well as production code

#### sbt

Include the following command alias:

```
addCommandAlias("commitCheck", "clean;test;scalafmtSbt;scalafmtAll;scalafixAll")
```

If new modules are added to the project ensure `commitCheck` includes them.

**plugins.sbt** - minimal set

(use latest versions)

```
addSbtPlugin("ch.epfl.scala" % "sbt-scalafix" % "0.14.3")
addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.5.4")
addSbtPlugin("org.typelevel" % "sbt-tpolecat" % "0.5.2")
addDependencyTreePlugin
```

### Code Style

#### Code Structure

- **No nested if/else statements** - use early returns, guard clauses, or composition
- **Avoid deep nesting** in general (max 2 levels)
- Keep functions small and focused on a single responsibility

#### No Comments in Code

Code should be self-documenting through clear naming and structure. Comments indicate that the code itself is not clear enough.

### Development Workflow

#### TDD Process - THE FUNDAMENTAL PRACTICE

**CRITICAL**: TDD is not optional. Every feature, every bug fix, every change MUST follow this process:

Follow Red-Green-Refactor strictly:

1. **Red**: Write a failing test for the desired behavior. NO PRODUCTION CODE until you have a failing test.
2. **Green**: Write the MINIMUM code to make the test pass. Resist the urge to write more than needed.
3. **Refactor**: Assess the code for improvement opportunities. If refactoring would add value, clean up the code while keeping tests green. If the code is already clean and expressive, move on.

**Common TDD Violations to Avoid:**

- Writing production code without a failing test first
- Writing multiple tests before making the first one pass
- Writing more production code than needed to pass the current test
- Skipping the refactor assessment step when code could be improved
- Adding functionality "while you're there" without a test driving it

**Remember**: If you're typing production code and there isn't a failing test demanding that code, you're not doing TDD.

#### Refactoring - The Critical Third Step

Evaluating refactoring opportunities is not optional - it's the third step in the TDD cycle. After achieving a green state and committing your work, you MUST assess whether the code can be improved. However, only refactor if there's clear value - if the code is already clean and expresses intent well, move on to the next test.

##### What is Refactoring?

Refactoring means changing the internal structure of code without changing its external behavior. The public API remains unchanged, all tests continue to pass, but the code becomes cleaner, more maintainable, or more efficient. Remember: only refactor when it genuinely improves the code - not all code needs refactoring.

##### When to Refactor

- **Always assess after green**: Once tests pass, before moving to the next test, evaluate if refactoring would add value
- **When you see duplication**: But understand what duplication really means (see DRY below)
- **When names could be clearer**: Variable names, function names, or type names that don't clearly express intent
- **When structure could be simpler**: Complex conditional logic, deeply nested code, or long functions
- **When patterns emerge**: After implementing several similar features, useful abstractions may become apparent

**Remember**: Not all code needs refactoring. If the code is already clean, expressive, and well-structured, commit and move on. Refactoring should improve the code - don't change things just for the sake of change.

##### Refactoring Guidelines

###### 1. Commit Before Refactoring

Always commit your working code before starting any refactoring. This gives you a safe point to return to:

```bash
git add .
git commit -m "feat: add payment validation"
# Now safe to refactor
```

###### 2. Look for Useful Abstractions Based on Semantic Meaning

Create abstractions only when code shares the same semantic meaning and purpose. Don't abstract based on structural similarity alone - **duplicate code is far cheaper than the wrong abstraction**.

**Questions to ask before abstracting:**

- Do these code blocks represent the same concept or different concepts that happen to look similar?
- If the business rules for one change, should the others change too?
- Would a developer reading this abstraction understand why these things are grouped together?
- Am I abstracting based on what the code IS (structure) or what it MEANS (semantics)?

**Remember**: It's much easier to create an abstraction later when the semantic relationship becomes clear than to undo a bad abstraction that couples unrelated concepts.

###### 3. Understanding DRY - It's About Knowledge, Not Code

DRY (Don't Repeat Yourself) is about not duplicating **knowledge** in the system, not about eliminating all code that looks similar.

```scala
// This is NOT a DRY violation - different knowledge despite similar code
def validateUserAge(age: Int): Boolean =
  age >= 18 && age <= 100

def validateProductRating(rating: Int): Boolean =
  rating >= 1 && rating <= 5

def validateYearsOfExperience(years: Int): Boolean =
  years >= 0 && years <= 50

// These functions have similar structure (checking numeric ranges), but they
// represent completely different business rules:
// - User age has legal requirements (18+) and practical limits (100)
// - Product ratings follow a 1-5 star system
// - Years of experience starts at 0 with a reasonable upper bound
// Abstracting them would couple unrelated business concepts and make future
// changes harder. What if ratings change to 1-10? What if legal age changes?

// Another example of code that looks similar but represents different knowledge:
def formatUserDisplayName(user: User): String =
  s"${user.firstName} ${user.lastName}".trim

def formatAddressLine(address: Address): String =
  s"${address.street} ${address.number}".trim

def formatCreditCardLabel(card: CreditCard): String =
  s"${card.cardType} ${card.lastFourDigits}".trim

// Despite the pattern "combine two strings with space and trim", these represent
// different domain concepts with different future evolution paths

// This IS a DRY violation - same knowledge in multiple places
class Order(items: List[Item]) {
  def calculateTotal: Double = {
    val itemsTotal = items.map(_.price).sum
    val shippingCost = if (itemsTotal > 50) 0.0 else 5.99 // Knowledge duplicated!
    itemsTotal + shippingCost
  }
}

class OrderSummary {
  def getShippingCost(itemsTotal: Double): Double =
    if (itemsTotal > 50) 0.0 else 5.99 // Same knowledge!
}

class ShippingCalculator {
  def calculate(orderAmount: Double): Double =
    if (orderAmount > 50) 0.0 else 5.99 // Same knowledge again!
}

// Refactored - knowledge in one place
val FreeShippingThreshold = 50.0
val StandardShippingCost = 5.99

def calculateShippingCost(itemsTotal: Double): Double =
  if (itemsTotal > FreeShippingThreshold) 0.0 else StandardShippingCost

// Now all classes use the single source of truth
class Order(items: List[Item]) {
  def calculateTotal: Double = {
    val itemsTotal = items.map(_.price).sum
    itemsTotal + calculateShippingCost(itemsTotal)
  }
}
```

##### 4. Maintain External APIs During Refactoring

Refactoring must never break existing consumers of your code:

```scala
// Original implementation
def processPayment(payment: Payment): ProcessedPayment = {
  // Complex logic all in one function
  if (payment.amount <= 0) {
    throw new Exception("Invalid amount")
  }

  if (payment.amount > 10000) {
    throw new Exception("Amount too large")
  }

  // ... 50 more lines of validation and processing

  result
}

// Refactored - external API unchanged, internals improved
def processPayment(payment: Payment): ProcessedPayment = {
  validatePaymentAmount(payment.amount)
  validatePaymentMethod(payment.method)

  val authorizedPayment = authorizePayment(payment)
  val capturedPayment = capturePayment(authorizedPayment)

  generateReceipt(capturedPayment)
}

// New internal functions - not exported
private def validatePaymentAmount(amount: Double): Unit = {
  if (amount <= 0) {
    throw new Exception("Invalid amount")
  }

  if (amount > 10000) {
    throw new Exception("Amount too large")
  }
}

// Tests continue to pass without modification because external API unchanged
```

##### 5. Verify and Commit After Refactoring

**CRITICAL**: After every refactoring:

1. Run all tests - they must pass without modification
2. Run static analysis (linting, type checking) - must pass
3. Commit the refactoring separately from feature changes

```bash
# After refactoring
sbt commitCheck   # All tests must pass

# Only then commit
git add .
git commit -m "refactor: extract payment validation helpers"
```

#### Refactoring Checklist

Before considering refactoring complete, verify:

- [ ] The refactoring actually improves the code (if not, don't refactor)
- [ ] All tests still pass without modification
- [ ] All static analysis tools pass (compiling, linting, type checking)
- [ ] No new public APIs were added (only internal ones)
- [ ] Code is more readable than before
- [ ] Any duplication removed was duplication of knowledge, not just code
- [ ] No speculative abstractions were created
- [ ] The refactoring is committed separately from feature changes

#### Example Refactoring Session

```scala
// After getting tests green with minimal implementation:
class OrderProcessingTest extends munit.FunSuite {
  test("calculates total with items and shipping") {
    val order = Order(items = List(Item(30), Item(20)), shipping = 5)
    assertEquals(calculateOrderTotal(order), 55.0)
  }

  test("applies free shipping over £50") {
    val order = Order(items = List(Item(30), Item(25)), shipping = 5)
    assertEquals(calculateOrderTotal(order), 55.0)
  }
}

// Green implementation (minimal):
def calculateOrderTotal(order: Order): Double = {
  val itemsTotal = order.items.map(_.price).sum
  val shipping = if (itemsTotal > 50) 0.0 else order.shipping
  itemsTotal + shipping
}

// Commit the working version
// git commit -m "feat: implement order total calculation with free shipping"

// Assess refactoring opportunities:
// - The variable names could be clearer
// - The free shipping threshold is a magic number
// - The calculation logic could be extracted for clarity
// These improvements would add value, so proceed with refactoring:

val FreeShippingThreshold = 50.0

def calculateItemsTotal(items: List[OrderItem]): Double =
  items.map(_.price).sum

def calculateShipping(
  baseShipping: Double,
  itemsTotal: Double
): Double =
  if (itemsTotal > FreeShippingThreshold) 0.0 else baseShipping

def calculateOrderTotal(order: Order): Double = {
  val itemsTotal = calculateItemsTotal(order.items)
  val shipping = calculateShipping(order.shipping, itemsTotal)
  itemsTotal + shipping
}

// Run commitCheck - tests still pass!
// Now commit the refactoring
// git commit -m "refactor: extract order total calculation helpers"
```

###### Example: When NOT to Refactor

```scala
// After getting this test green:
class DiscountCalculationTest extends munit.FunSuite {
  test("should apply 10% discount") {
    val originalPrice = 100.0
    val discountedPrice = applyDiscount(originalPrice, 0.1)
    assertEquals(discountedPrice, 90.0)
  }
}

// Green implementation:
def applyDiscount(price: Double, discountRate: Double): Double =
  price * (1 - discountRate)

// Assess refactoring opportunities:
// - Code is already simple and clear
// - Function name clearly expresses intent
// - Implementation is a straightforward calculation
// - No magic numbers or unclear logic
// Conclusion: No refactoring needed. This is fine as-is.

// Commit and move to the next test
// git commit -m "feat: add discount calculation"
```

#### Commit Guidelines

- Each commit should represent a complete, working change
- Use conventional commits format:
  ```
  feat: add payment validation
  fix: correct date formatting in payment processor
  refactor: extract payment validation logic
  test: add edge cases for payment validation
  ```
- Include test changes with feature changes in the same commit

#### Pull Request Standards

- Every PR must have all tests passing
- All linting and quality checks must pass
- Work in small increments that maintain a working state
- PRs should be focused on a single feature or fix
- Include description of the behavior change, not implementation details

### Working with Claude

#### Expectations

When working with my code:

1. **ALWAYS FOLLOW TDD** - No production code without a failing test. This is not negotiable.
2. **Think deeply** before making any edits
3. **Understand the full context** of the code and requirements
4. **Ask clarifying questions** when requirements are ambiguous
5. **Think from first principles** - don't make assumptions
6. **Assess refactoring after every green** - Look for opportunities to improve code structure, but only refactor if it adds value
7. **Keep project docs current** - update them whenever you introduce meaningful changes

#### Code Changes

When suggesting or making changes:

- **Start with a failing test** - always. No exceptions.
- After making tests pass, always assess refactoring opportunities (but only refactor if it adds value)
- After refactoring, verify all tests and static analysis pass, then commit
- Respect the existing patterns and conventions
- Maintain test coverage for all behavior changes
- Keep changes small and incremental
- Ensure all Scala compiler warnings are addressed
- Provide rationale for significant design decisions

**If you find yourself writing production code without a failing test, STOP immediately and write the test first.**

#### Communication

- Be explicit about trade-offs in different approaches
- Explain the reasoning behind significant design decisions
- Flag any deviations from these guidelines with justification
- Suggest improvements that align with these principles
- When unsure, ask for clarification rather than assuming

### Example Projects

Look for a directory called `example-projects` to base new code on: patterns and style.

### Common Patterns to Avoid

#### Anti-patterns

```scala
// Avoid: Mutation
def addItem(items: mutable.ListBuffer[Item], newItem: Item): mutable.ListBuffer[Item] = {
  items += newItem // Mutates collection
  items
}

// Prefer: Immutable update
def addItem(items: List[Item], newItem: Item): List[Item] =
  items :+ newItem

// Avoid: Nested conditionals
if (user.isDefined) {
  if (user.isActive) {
    if (user.get.hasPermission) {
      // do something
    }
  }
}

// Prefer: boolean expression
if (user.isDefined && user.isActive && user.hasPermission) {
  …
}

// Or using for-comprehension
for {
  u <- user
  if u.isActive
  if u.hasPermission
} yield {
  // do something
}

// Avoid: Large functions
def processOrder(order: Order): ProcessedOrder = {
  // 10+ lines of code
  ???
}

// Prefer: Composed small functions
def processOrder(order: Order): ProcessedOrder = {
  val validatedOrder = validateOrder(order)
  val pricedOrder = calculatePricing(validatedOrder)
  val finalOrder = applyDiscounts(pricedOrder)
  submitOrder(finalOrder)
}
```

### Resources and References

- [Scala Documentation](https://docs.scala-lang.org/)
- [Cats Documentation](https://typelevel.org/cats/)
- [Cats Effect Documentation](https://typelevel.org/cats-effect/)
- [MUnit Documentation](https://scalameta.org/munit/)
- [Http4s Documentation](https://http4s.org/)

### Summary

The key is to write clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior, and the implementation should be the simplest thing that makes that test pass. When in doubt, favor simplicity and readability over cleverness.

### References

- Inspired by [Paul Hammond](https://github.com/citypaul/.dotfiles/blob/main/claude/.claude/CLAUDE.md)

