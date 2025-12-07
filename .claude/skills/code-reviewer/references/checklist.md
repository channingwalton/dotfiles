# Code Review Checklist

## 1. Code Organisation & Structure
- [ ] Single Responsibility Principle followed
- [ ] Appropriate abstraction levels
- [ ] Clear naming conventions
- [ ] Logical file/module organisation
- [ ] Can code be simplified?
- [ ] Check for duplication → use `refactor` skill to address

## 2. Functional Programming
- [ ] Functions are pure where possible
- [ ] Side effects are explicit and contained
- [ ] Immutable data preferred
- [ ] No early returns (single return per function)
- [ ] Higher-order functions over imperative loops
- [ ] Referential transparency maintained

## 3. Error Handling
- [ ] All error cases handled
- [ ] Appropriate error types used (not exceptions for control flow)
- [ ] User-friendly error messages
- [ ] No silent failures
- [ ] Errors propagated via types (Either, Option) where appropriate

## 4. Performance
- [ ] No obvious inefficiencies (N+1, unnecessary loops)
- [ ] Appropriate data structures
- [ ] Resource clean-up (files, connections)
- [ ] Lazy evaluation considered where beneficial

## 5. Security
- [ ] Input validation
- [ ] No hardcoded secrets
- [ ] Proper authentication/authorisation
- [ ] SQL injection prevention (if applicable)

## 6. Test Coverage
- [ ] All code must have tests
- [ ] Edge cases covered
- [ ] Tests are maintainable
- [ ] Tests verify behaviour, not implementation

## 7. Bug Discovery
- [ ] Run `bugmagnet` command — comprehensive test coverage and bug discovery workflow
