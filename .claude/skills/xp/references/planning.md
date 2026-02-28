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

Requirements are arguments in disguise — they have stated conclusions ("the system should do X") resting on unstated premises. Your job is to find what's been left unsaid.

**Find the enthymemes** — the hidden premises in every requirement:

1. Restate the requirement as: "Given [premises], then [conclusion]"
2. Ask: **what premises are missing?** Common hiding places:
   - **Who** — which actor triggers this, and do different actors expect different things?
   - **When** — at what point in the process does this happen? What state must already exist?
   - **Boundaries** — what counts as valid input? What's the smallest/largest/emptiest case?
   - **Failure** — what happens when this *can't* work? Who finds out and how?
   - **Definitions** — are we using the same words to mean the same things? (→ `glossary` skill)
3. Challenge assumptions — especially those that feel obvious
4. **STOP** — Do not proceed until questions are answered

**Example:**

> Requirement: "Send a notification when a shift is unfilled"
>
> Hidden premises to surface:
> - What counts as "unfilled"? (no one assigned? assigned but unconfirmed? under minimum staffing?)
> - When is this check run? (real-time? batch? on a schedule?)
> - "Send" how? (email? push? in-app?)
> - To whom? (manager? all eligible staff? both?)
> - What if notifications fail? Retry? Escalate?

### ✂️ SLICE — Break Into Tasks

Create tasks that are:

- **Vertical** — each delivers working end-to-end functionality
- **Small** — completable in one TDD cycle
- **Ordered** — by dependency first, then by value
- **Testable** — clear acceptance criteria

### 🧪 FALSIFY — Test Your Understanding

Before committing to a plan, actively try to break it. This guards against the most common planning failure: stopping when things *feel* right rather than when they *are* right.

1. **State what you believe** — "We understand the feature to mean X"
2. **Seek disconfirmation** — "What scenario would prove this understanding wrong?"
3. **Check for missing slices** — "Is there a case this plan doesn't handle?"
4. **Check for wrong order** — "Does any task depend on something we haven't planned yet?"

If you can't think of anything that would prove your understanding wrong, that's a warning sign — not a green light.

### 📋 CONFIRM — Agree on Plan

1. Summarise understanding back to user
2. Present ordered task list
3. **STOP** — Explicitly agree on the first task to implement

## What Makes a Good Task

```
✅ Good: "Add a book to the library"
   - Has clear input (book details)
   - Has clear output (book stored)
   - Can be tested end-to-end

❌ Bad: "Create the Book class"
   - Implementation detail
   - No user-visible behaviour
   - Can't be validated independently
```

## Announcing Progress

```
💬 DISCUSS → Understanding [feature]
❓ CLARIFY → Surfacing hidden premise: [what's unstated]
✂️ SLICE → Breaking into tasks
🧪 FALSIFY → Testing assumption: [what could be wrong]
📋 CONFIRM → Proposed tasks: [list]
```

## Output Format

After planning, present tasks as:

```
## Tasks for [Feature]

1. [ ] [Task description] — [acceptance criteria]
2. [ ] [Task description] — [acceptance criteria]
3. [ ] [Task description] — [acceptance criteria]

**Assumptions surfaced:** [key premises uncovered during clarify/falsify]
**First task:** [Task 1 description]
```

## Common Mistakes

- Diving into implementation without understanding requirements
- **Accepting requirements at face value** — not surfacing hidden premises
- Creating horizontal slices (e.g., "build the database layer")
- Tasks too large to complete in one session
- Skipping confirmation step
- Not ordering by dependency
- **Stopping when the plan feels right** — not actively trying to break it
