---
name: bug-analysis
description: Analyse user-reported bugs before writing code. Use when the user describes an incident, customer report, support ticket, or production issue with symptoms like "users see X", "customers report Y", or "something's wrong with Z". Separates symptom triage from code-level debugging and prioritises source context before implementation guesses.
---

# Bug Analysis

## Overview

User-reported bugs are a different shape from "the test is red". Symptoms come from non-engineers, context is scattered across Slack/Jira/support, and the root cause often isn't in the code you first think.

**Core principle:** Find the context before you find the cause. Most wasted investigations misidentified *which code actually ran* — not the code's behaviour.

This skill runs before code-level debugging. Debugging requires knowing which code to debug. Analysis establishes that.

## When to Use

User message patterns:
- "Users report X"
- "Customer says Y"
- "Production is showing Z"
- "<Name> found a bug in ..."
- Any incident, support ticket, or help-channel thread
- Any Jira ticket that starts "investigate ..."

**Do NOT use when:** test failure in front of you, stack trace you triggered, error you can reproduce locally. Those go straight to normal code-level debugging.

## The Iron Law

```
NO HYPOTHESES WITHOUT HUMAN CONTEXT FIRST
```

Skipping Phase 1 has a recognisable failure mode: you spend N turns hypothesising against the wrong codebase, wrong tool, or a problem already fixed yesterday. Every turn of this is pure waste.

## The Four Phases

### Phase 1: Source the Report

**Before touching code, get the human record.**

Ask for or search using the strongest available source: direct links from the user, installed app connectors discovered through `tool_search`, local task notes, Jira/GitHub/Slack connectors, or the local repo history.

1. **Slack thread.** Where was this first reported? Who replied? What was already tried?
2. **Jira / support ticket.** Description, acceptance criteria, prior linked tickets, comments.
3. **Reproduction identifiers.** Org id, user/worker id, timestamps, specific record ids. Without these you're guessing at which rows matter.
4. **The user's own words.** Distinguish what they *saw* (observation) from what they *inferred* (theory). Observations are usually accurate; inferences are usually wrong.

**Concrete first moves:**

- Ask for the Slack/Jira/support link if none is present.
- Use installed Slack/Jira/GitHub app tools when available; call `tool_search` first if the relevant connector is not exposed yet.
- Search local task notes or memory only when they are likely to contain the task context.
- Run `git log` on relevant files for recent adjacent tickets; a partial fix may already have shipped.

**Do not proceed to Phase 2 until you have:**
- One concrete reproduction case (org + user + date, or record ids)
- One external reference (Slack link, Jira ticket, or explicit statement from the user that none exists)

### Phase 2: Identify the Pipeline

**Before diagnosing a tool's behaviour, prove the tool ran.**

Data-plumbing bugs have a dominant failure mode: you assume tool A processed the data when actually tool B did. Everything downstream of that assumption is wrong.

1. **Enumerate the candidate tools.** Multiple importers? Multiple services? Grep by filename patterns, XLSX headers, API endpoint paths, recent commits.
2. **Match evidence to tool.** File format, column names, timestamps, log lines. An XLSX with columns `Staff Number, Reason, Total Duration` is not the same tool as one with `Email, Yearly Total`.
3. **Ask the user which tool they ran** if multiple plausible. Cheap question, expensive assumption.
4. **Check repository boundaries.** Rails? Kmono? Apps? A bug in one doesn't live in another.

**Do not proceed to Phase 3 until you can name the specific file + function that processed the data.**

### Phase 3: Check Recent Changes

**Before hypothesising a new bug, check for a recent fix.**

1. `git log` on relevant files in the last 7 days.
2. Linked Jira tickets on the incident ticket.
3. Deploy history if accessible.
4. Slack messages in the thread after the initial report — someone may already have shipped a fix.

If a recent change is relevant, verify whether the user's incident predates or postdates it. A fix shipped yesterday may have already resolved half the problem; continuing to diagnose the old shape wastes time.

### Phase 4: Hand Off to Code Debugging

You now have:
- Concrete reproduction case
- Named tool + file
- Recent-change context
- User's observation separated from their inference

This is the input code-level debugging needs. Continue with the normal repository investigation: inspect the exact implementation path, write or run a reproduction when possible, then make the smallest justified fix.

## Red Flags — STOP and Return to Phase 1

Catch yourself thinking:

| Thought | Reality |
|---------|---------|
| "I'll just start grepping the code" | You don't know which code yet. Get the context. |
| "Slack probably won't help" | Slack held the answer in the last MWL investigation. 19 turns wasted before checking. |
| "I'll form the hypothesis quickly then verify" | You'll verify against the wrong tool. |
| "It must be [importer X]" | Why X? Prove X ran. |
| "I don't need the ticket, I have the symptom" | The ticket describes the symptom the user cares about, not the one you'd guess. |
| "This is taking too long, let me propose fixes" | Premature fixes propagate wrong assumptions. Cheaper to pause. |
| "The Slack thread is long, I'll skim" | Read the last 5 messages before the user's ask. That's where the state lives. |
| "Another agent and I both agree it's X" | Two agents reading the same code converge on the same bias. Agreement ≠ verification. |

## Multi-Agent Consultation

If using `chatter` or spawning a sub-agent for second opinion: confirm the other agent has **orthogonal context** (different tool access, different codebase, different knowledge domain). Two agents reading the same repo don't cross-verify — they co-hallucinate.

Orthogonal = adds signal. Redundant = amplifies error with false confidence.

## Common Rationalisations

| Excuse | Reality |
|--------|---------|
| "User already tried X, no point asking again" | Ask for the link, not the summary. Their summary omits what matters. |
| "I know this codebase, I'll skip the pipeline check" | Codebases grow. The tool you remember may not be the one that ran. |
| "Recent-changes check is low-value" | One recent-fix hit pays for a year of the habit. |
| "The user is busy, don't ask for ids" | 30 seconds of their time saves an hour of yours. |
| "The report is vague but I get the gist" | The gist is the user's inference. Extract the observation. |

## Quick Reference

| Phase | Activity | Exit criterion |
|-------|----------|----------------|
| **1. Source** | Slack + Jira + reproduction ids | External reference acquired, observation separated from inference |
| **2. Pipeline** | Match evidence to specific tool/file | Named file + function that processed the data |
| **3. Recent** | `git log`, linked tickets, thread tail | Recent-change context considered |
| **4. Handoff** | Continue code-level debugging | Has input it needs |

## Real-World Impact

Investigations that skip Phase 1 routinely burn 10–20 turns hypothesising against the wrong code — wrong tool, wrong repo, or a problem a colleague has already fixed. Phase 1 done first typically collapses those investigations to 2–3 turns by revealing the actual tool that ran, the recent fix that's already shipped, or the observation the user buried under their own inference.

## Related Skills

- **`chatter`** — multi-agent consultation; only useful with orthogonal context.
- **`vault`** — local task notes and project context.
- **`code-query`** — implementation and note search once the likely pipeline is known.
