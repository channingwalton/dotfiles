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

## Detailed Steps

### 💬 DISCUSS — Understand Requirements

1. What problem does this feature solve?
2. What is the expected behaviour?
3. What are the acceptance criteria?
4. Are there any constraints or dependencies?

### ❓ CLARIFY — Surface Hidden Premises

Requirements are arguments in disguise — stated conclusions resting on unstated premises. Your job is to find what's been left unsaid.

**Find the enthymemes** — restate the requirement as "Given [premises], then [conclusion]" and ask what premises are missing:

- **Who** — which actor triggers this, and do different actors expect different things?
- **When** — at what point in the process? What state must already exist?
- **Boundaries** — what counts as valid input? Smallest/largest/emptiest case?
- **Failure** — what happens when this *can't* work? Who finds out and how?
- **Definitions** — are we using the same words to mean the same things? (→ `glossary` skill)

Challenge assumptions — especially those that feel obvious. **STOP** until questions are answered.

**Example:**

> "Send a notification when a shift is unfilled"
>
> Hidden premises: What counts as "unfilled"? When is this checked? "Send" how? To whom? What if it fails?

### ✂️ SLICE — Break Into Tasks

Tasks must be **vertical** (end-to-end functionality), **small** (one TDD cycle), **ordered** (dependency first, then value), and **testable** (clear acceptance criteria).

```
✅ Good: "Add a book to the library" — clear input, output, testable
❌ Bad:  "Create the Book class" — implementation detail, no visible behaviour
```

### 🧪 FALSIFY — Test Your Understanding

Before committing to a plan, actively try to break it.

1. **State what you believe** — "We understand the feature to mean X"
2. **Seek disconfirmation** — "What scenario would prove this wrong?"
3. **Check for gaps** — "Is there a case this plan doesn't handle?"
4. **Check ordering** — "Does any task depend on something unplanned?"

If you can't think of anything that would prove your understanding wrong, that's a warning sign — not a green light.

### 📋 CONFIRM — Agree on Plan

1. Summarise understanding back to user
2. Present ordered task list
3. **STOP** — Explicitly agree on the first task

## Output Format

```
## Tasks for [Feature]

1. [ ] [Task description] — [acceptance criteria]
2. [ ] [Task description] — [acceptance criteria]

**Assumptions surfaced:** [key premises uncovered during clarify/falsify]
**First task:** [Task 1 description]
```

## Common Mistakes

- Diving into implementation without understanding requirements
- Accepting requirements at face value — not surfacing hidden premises
- Creating horizontal slices (e.g., "build the database layer")
- Tasks too large to complete in one session
- Not ordering by dependency
- Stopping when the plan *feels* right rather than actively testing it
