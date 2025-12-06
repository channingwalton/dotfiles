# Code Review Checklist

## 1. Code Organisation & Structure
- [ ] Single Responsibility Principle followed
- [ ] Appropriate abstraction levels
- [ ] Clear naming conventions
- [ ] Logical file/module organisation
- [ ] Can code be simplified?
- [ ] Check for duplication

## 2. Error Handling
- [ ] All error cases handled
- [ ] Appropriate error types used
- [ ] User-friendly error messages
- [ ] No silent failures

## 3. Performance
- [ ] No obvious inefficiencies (N+1, unnecessary loops)
- [ ] Appropriate data structures
- [ ] Resource clean-up (files, connections)

## 4. Security
- [ ] Input validation
- [ ] No hardcoded secrets
- [ ] Proper authentication/authorisation
- [ ] SQL injection prevention (if applicable)

## 5. Test Coverage
- [ ] All code must have tests
- [ ] Edge cases covered
- [ ] Tests are maintainable

## 6. Bugs
- [ ] Run `bugmagnet` command on modified or new files
