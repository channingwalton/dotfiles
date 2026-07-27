---
name: requirements-report
description: Link requirements to the tests that demonstrate them and render a report showing which requirements pass, fail, or have no test at all. Use whenever a requirements or specification document drives the work - implementing a feature from a requirements doc, writing tests for a spec, adding requirements to an existing project - and for requirements traceability, a living requirements document, acceptance criteria tied to tests, finding untested requirements, or seeing which requirement a failing test belongs to. Read this BEFORE writing any tests: it sets how they must be named. Works with any language and any test framework that can emit JUnit XML.
---

# Requirements report

Link human-readable requirements to the tests that demonstrate them, and render a report
showing which requirement each failure belongs to.

**The report is the document.** Headings, prose, lists and tables come out in their original order;
a status badge lands on every line carrying a marker, and the test source and failure fold in
beneath it. Nothing unmarked is discarded, and headings roll up the status of what sits under
them whether or not they carry an id of their own.

**The convention is tiny.** A requirement is a line of ordinary Markdown carrying a
`` `#id` `` marker. A test covers it by putting that id anywhere in its **test name** — or, where test names
are identifiers rather than free text, by naming the test `req_<id>`. A script joins the two
through the JUnit XML the test run already produces.

The id lives in the test *name* rather than an annotation because every test framework's
report carries the name. There is nothing to install per language and no adapter to write.

```
requirements/*.md          prose a non-technical person reads, each node with an `#id`
        |                  tests named "#dd-clear a due date can be removed"
        v
<junit xml dir>/*.xml       the test run's own output
        |  reqreport.py
        v
<out>/index.html + one page per document
```

## Do not build a renderer

`reqreport.py` (beside this file) is the renderer. It is stdlib-only Python 3 and needs no
install. **Never write a project-specific version of it** — two non-obvious bugs were found
the one time it was built, and re-deriving it per project reintroduces them.

```
python3 reqreport.py --requirements requirements/ \
                     --junit build/test-results/test/ \
                     --sources src/test/ \
                     --out target/requirements/
```

Exit 0 clean, 1 requirement problems, 2 bad input. Options can also live in
`.reqreport.json` (`requirements`, `junit`, `sources`, `out`, `root`). `--no-gate` writes the
report without failing.

Source paths in the report are shown relative to `--root`, which defaults to the working
directory. Set it from the project root your build tool already knows — sbt's
`baseDirectory`, Gradle's `projectDir`, `$PWD` in a Makefile — so the report reads the same
whichever directory the build was launched from and carries no trace of the machine that
rendered it. Do not derive it from git: that finds the *repository* root, which is the
project root only when the two coincide, and in a monorepo prefixes every path with the
project's own directory name.

## What to actually do

### Naming a test

**After the id, write whatever you like.** The tool takes the id and ignores the rest of the
name, so there is no format to get right:

```
"#live-ok /health answers 200 while the service is running"    ScalaTest, Jest, pytest…
"#live-ok. Answers 200."                                        punctuation is fine
fn req_live_ok_when_starting()                                  Rust, Go
```

The id is resolved against the ids the documents define, longest first, so a suffix costs
nothing. An id that matches nothing is reported as an **orphan** and fails the build — typos
do not pass silently.

**One requirement, one test.** Two tests naming the same id is fatal. If you want to assert a
second thing, that second thing is a requirement the document does not yet state — write it
down and give it its own id. This is the rule that stops design decisions being smuggled in
under an existing requirement, where nobody reviewing the document would ever see them.

Use the rest of the name to say what *this test* checks, not to restate the requirement. The
report already prints the requirement directly above it, so an echo reads like verification
while adding nothing.

### Setting it up

0. **Pick the marker form.** If test names are free text (ScalaTest, pytest, Jest, Vitest,
   JUnit `@DisplayName`), put `#the-id` in the name. If they are identifiers (Rust, Go),
   name the test `req_the_id` — plain `#[test]` and plain `go test` are then enough. Do not
   reach for `libtest-mimic`, subtest wrappers or a sidecar map to get a `#` into the name.
   The id is resolved against the ids the documents define, so `req_the_id_and_more_words`
   still binds `#the-id`. Go needs underscores — `Test_req_the_id`, not `TestReqTheId`.

1. **Find the test runner and make it emit JUnit XML.** This is the only genuinely
   project-specific step. See `references/junit-xml.md` for how, per runner, and where the
   files land. Confirm by running the tests and listing the directory — do not assume.

2. **Find or create `requirements/`.** If the project has specs, ADRs, tickets or a README
   describing behaviour, draft from those. If it has nothing, **grill the user** — see
   *Writing requirements* below. Do not invent requirements.

3. **Add `#id` markers.** See `references/conventions.md` for the marker rules and tree
   shape.

4. **Name the tests.** If you are writing the tests as part of this work, name them for
   their requirement as you go — that is far cheaper than renaming afterwards, and it is why
   this skill should be read before any test is written. If the tests already exist, add the
   id to the name of each one that clearly covers a requirement. Where you are not sure,
   leave it and tell the user: a wrongly linked test is worse than an unlinked one, because
   it reports coverage that does not exist.

5. **Wire it into the build**, after the tests, deleting the JUnit XML directory first. See
   *Wiring* below.

6. **Run it and show the user the index.** Expect red on the first run: untested
   requirements are the point, not a failure of setup.

## Writing requirements

Requirements come from the user, not from you. When drafting:

- **Everything you cannot decide goes in an "Undecided" list, not into a requirement.** A
  requirement with a value you guessed reads exactly like one the user chose.
- **Offer concrete alternatives rather than asking open questions.** Show two specific
  behaviours that both fit what the user said and ask which is right. People are far better
  at judging a concrete case than at enumerating rules.
- **Do not trust your own confidence.** In one trial, three independent models on three
  different model families drafted acceptance criteria from the same one-line requirement
  and *unanimously* assumed two things the user did not want. Agreement between readings is
  not evidence of correctness; it hides shared blind spots.
- Ask early about the things that are expensive to reverse: what the feature *does* rather
  than what it stores, date/time granularity and time zones, whether ordering changes, and
  whether the affordance the requirement assumes (editing, deleting) actually exists.

## Wiring

Run the tests, then the report. Two rules:

- **Delete the JUnit XML directory before the run.** A stale report looks entirely
  plausible and is silently one run old.
- **Force the ordering.** In build tools with parallel task graphs this needs to be
  explicit — sbt needs `Def.sequential`, not two `.value` calls.

The tests must not fail the build, or the report never runs. Let the report be the gate.

```makefile
report:
	rm -rf build/test-results/test
	-pytest --junitxml=build/test-results/test/report.xml
	python3 tools/reqreport.py --junit build/test-results/test --sources tests
```

## What the report gates on

| Check | Fails when |
|---|---|
| Failure | a test naming a requirement failed |
| Roll-up | any descendant of a requirement failed |
| No test | no test names a requirement — nothing demonstrates it works |
| Orphan | a test names an id no document defines |
| Duplicate | the same `#id` is defined twice — fatal, it double-counts coverage |
| Shared id | two tests name the same `#id` — fatal, the second assertion is an unwritten requirement |

Tests with no id are listed but are **not** errors. Unit tests need not map to requirements.

## The hole to tell the user about

**Nothing here detects a test that names one requirement and tests another.** No mechanical
check can. The report puts requirement prose next to the test source behind a disclosure
precisely so a reviewer or an agent can see the mismatch — that adjacency is the mitigation,
and review is the control.

Take this seriously rather than treating it as a footnote: the plausible-but-wrong test is
what a model writes *by default*, not what it writes when trying to cheat.

## Two audiences, one page

The top of each page is business-readable — requirement text and a status. Test source and
stack traces sit behind a disclosure. So the *source* document must stay free of code, but
the rendered report need not, because nobody authors there.
