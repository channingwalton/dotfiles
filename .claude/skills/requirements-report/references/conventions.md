# Conventions

## The marker

A requirement is any line in a Markdown document carrying an id in backticks:

```markdown
- The service answers `/health` with 200 while it is running `#live-ok`
```

Ids match `[A-Za-z0-9][A-Za-z0-9._-]*`. They must be **unique across every document** — a
duplicate is a fatal error, because two requirements sharing a join key both match the same
test and silently double-count as coverage.

Lines without a marker are prose. They are shown as context under the nearest preceding
requirement and are otherwise ignored, so a document can carry as much explanation as it
needs.

## Structure

**The rendered report is the document**, in order: headings stay headings, prose stays prose,
lists stay lists. A marker adds a status badge and the test detail; it does not turn the line
into something else, and unmarked lines are not dropped.

Headings roll up — a heading shows the worst status of the marked lines beneath it, down to
the next heading of the same or higher level. **This needs no id.** Give a heading an id only
when you want a test to bind to the section as a whole; a marked heading with marked lines
under it is satisfied by them and does not demand a test of its own.

Bullet nesting gives the shape. A heading with a marker is a requirement that
owns everything under it; bullets under it are its children; nested bullets are children of
their parent bullet.

```markdown
# Health endpoints

Prose here is context, not a requirement.

## Liveness `#live`

Whether the process is running at all.

- The service answers `/health` with 200 while it is running `#live-ok`
- The body of that response says `OK` `#live-body`
```

`#live` is a parent: it goes red if either child does, and shows NO TEST if either child has
none. This is what lets a reader skim at section level and drill in only where it is red.

A bullet may wrap onto indented continuation lines, and the marker may land on the last of
them. That is handled.

## Granularity

Write at whatever level you would actually discuss the behaviour. A requirement can be broad
("due dates are optional") or as fine as a single case ("an item due at 09:00 is overdue at
14:00 the same day"), and both can exist in the same tree with the second as a child of the
first. There is no correct granularity to discover — it is whatever you wrote and marked.

## Test names

The id goes anywhere in the test name, and **anything may follow it** — the tool reads the
id and ignores the rest. Punctuation, underscores, a trailing full stop: all fine.

The id is resolved against the ids the documents define, longest first. That is what removes
the ambiguity: `.` and `-` are legal *inside* an id, so `#live-ok. Answers 200` would
otherwise bind `live-ok.` and fail as an orphan. An id matching nothing keeps its raw text
and is reported as an orphan, so typos surface rather than passing silently.

Write the rest of the name to say what *this test* checks. Restating the requirement adds
nothing — the report prints it directly above.

```scala
test("#live-ok /health answers 200 while the service is running") { … }
```

```python
def test_liveness():
    """#live-ok /health answers 200 while the service is running"""
```

Where test names are **identifiers** rather than free text — Rust, Go — write `req_<id>`
instead, with underscores for hyphens:

```rust
#[test]
fn req_live_ok() { … }
```

Underscores and hyphens are equivalent, so `req_live_ok` binds to `#live-ok`. The `req_`
prefix is required: a bare id would match by accident, since `live_ok` is a substring of
`live_ok_fails`.

**The id is resolved against the ids your documents define, longest match first**, so
anything after it is free text:

```rust
fn req_health_obs_received_on_rejected_method()   // binds #health-obs-received
fn req_health_live_ok_when_starting()             // binds #health-live-ok
```

That is what lets a test name stay readable. Where a document defines both `#health-obs` and
`#health-obs-received`, the more specific one wins.

## One requirement, one test

**Two tests naming the same id is fatal.** Not a warning — the run stops.

```
fn req_health_live_ok_happy_path()   // both bind #health-live-ok
fn req_health_live_ok_edge_case()    // -> reqreport: a requirement may be
                                     //    named by only one test
```

The reason is not tidiness. A second test asserting a second thing *is* a second
requirement — an edge case, an ordering guarantee, an immutability promise — and leaving it
under an existing id puts a design decision into the codebase that nobody reading the
requirements document can see. The rule forces it onto the page where it can be argued with.

The mechanical symptom is smaller but was what exposed it: the source disclosure is indexed
by id, so every test sharing an id displayed the *first* test's code beneath its own name.
Since that adjacency is the only check on a test that names one requirement and tests
another, a wrong join there defeats the one control the report has.

So when the build stops on a shared id, the fix is nearly always to **split the
requirement**, not to merge the tests:

```markdown
- given a library, I can add a book to it `#add-a-book`
  - adding returns a new library; the original is unchanged `#add-immutable`
```

Merging is right only when the assertions are genuinely one behaviour that happens to need
two `assert` calls — then put them in one test body.

A `req_` that matches no defined id keeps its raw text and is reported as an **orphan** —
so `req_helth_live_ok` (typo) fails the build rather than disappearing into the unlinked
pile. The marker may also sit later in the name: `rejected_method_req_health_obs` works.

Several ids in one name are allowed and the test appears under each — appropriate for an
integration test spanning requirements from more than one document.

Tests with no id are listed in the report but are not errors. Unit tests need not map to
requirements, and forcing them to would make the ids meaningless.

## One document, one page

The report writes one page per document, mirroring the source tree, plus an index.
Document-to-page is 1:1 and mechanical.

Document-to-*test-file* is deliberately **not** enforced. A test may legitimately cover
requirements from two documents; since the join is by id it simply appears on both pages.
The index reports which test classes serve each document, so scatter is visible without
being forbidden.

## Naming ids

- Prefix by area so they sort and read well: `live-ok`, `live-body`, `dd-clear`.
- Keep them stable. The id is the join key; renaming one orphans its tests. Wording can
  change freely — only the id is load-bearing.
- Do not encode status, priority or ownership in the id. It is an identifier, not a record.

## What is deliberately absent

**No content hash, no approvals file.** Version control already puts changed prose in front
of a reviewer at the moment they should ask "does the test still match?". A hash tripwire
duplicates that check, fires on every wording clarification, and trains people to
re-approve without reading.

**No staleness hint.** Earlier versions compared the document's last-changed time against
the test sources' and warned when the document was newer. Commit times are a poor proxy for
"the requirement's meaning changed": the warning fired on a formatting commit, and — since
the test side took the newest change across the whole source root — stayed silent whenever
any unrelated test file had been touched more recently. False both ways, so it said nothing.
The report is a build artefact regenerated on every run, so it is always current with the
document it renders; there is no staleness for it to report.

**No tables, fixtures, or expectation columns.** They bind a requirement's expected value,
which is real but narrow, at the cost of requiring every requirement to be tabular. Most are
not. Where a requirement *is* naturally tabular, its test can be a parameterised body over
rows and the binding comes back — same id, same report. An optimisation of a subset, not the
architecture.

One caveat, given *One requirement, one test* above: parameterisation must stay inside a
**single** test case. Runners that emit one JUnit `<testcase>` per row — pytest
`@parametrize`, JUnit 5 `@ParameterizedTest`, ScalaTest table-driven suites with generated
names — produce several distinct test names carrying the id, and the run stops. Either loop
over the rows inside one test body, or put the id on only one row and give the others their
own requirements.
