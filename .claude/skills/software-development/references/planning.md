# Planning

## Core Rules (Non-Negotiable)

1. **NEVER skip requirements discussion** — understand before decomposing
2. **Ask at least one clarifying question** before breaking down tasks
3. **Vertical slices only** — each task delivers working functionality
4. **Confirm understanding** — summarise and agree before moving on

## The Planning Cycle

```
💬 DISCUSS  → Understand the problem and expected behaviour
❓ CLARIFY  → Surface hidden premises, resolve ambiguities
✂️ SLICE    → Break into tasks
🧪 FALSIFY  → Ask "how would we know if we're wrong?"
📋 CONFIRM  → Summarise and agree on first task
```

## ❓ CLARIFY — Surface Hidden Premises

**Find the missing premises** — restate the requirement as "Given [premises], then [conclusion]" and ask what's been left unsaid:

- **Who** — which actor triggers this, and do different actors expect different things?
- **When** — at what point in the process? What state must already exist?
- **Boundaries** — what counts as valid input? Smallest/largest/emptiest case?
- **Failure** — what happens when this *can't* work? Who finds out and how?
- **Definitions** — are we using the same words to mean the same things? (→ `glossary` skill)
- **User-facing strings** — does this change error messages, UI copy, or notifications? Who reads them (operator, end-user, ops triage)? Does the change preserve diagnostic value?

**Example:**

> "Send a notification when a shift is unfilled"
>
> Hidden premises: What counts as "unfilled"? When is this checked? "Send" how? To whom? What if it fails?

## ✂️ SLICE — Break Into Tasks

```
✅ Good: "Add a book to the library" — clear input, output, testable
❌ Bad:  "Create the Book class" — implementation detail, no visible behaviour
```

## 🧪 FALSIFY — Test Your Understanding

1. **State what you believe** — "We understand the feature to mean X"
2. **Seek disconfirmation** — "What scenario would prove this wrong?"
3. **Check for gaps** — "Is there a case this plan doesn't handle?"
4. **Check ordering** — "Does any task depend on something unplanned?"

If you can't think of anything that would prove your understanding wrong, that's a warning sign — not a green light.
