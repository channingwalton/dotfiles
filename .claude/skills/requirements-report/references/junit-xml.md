# Getting JUnit XML out of a test runner

The report joins requirements to tests through JUnit XML. Every mainstream runner can
produce it; some do by default, most need a flag or a plugin. **Always verify by running the
tests and listing the output directory** — defaults change and projects override them.

## JVM

**Maven / Surefire** — emits by default to `target/surefire-reports/`. Failsafe (integration
tests) writes `target/failsafe-reports/`. No configuration needed.

**Gradle** — emits by default to `build/test-results/test/`. Other test tasks write
`build/test-results/<taskName>/`. Configurable via `test { reports.junitXml.outputLocation }`.

**sbt + ScalaTest** — not on by default:

```scala
Test / testOptions += Tests.Argument(TestFrameworks.ScalaTest, "-u", "target/test-reports")
```

**sbt + munit / JUnit interface** — `Test / testOptions += Tests.Argument(TestFrameworks.JUnit, "-v")`
plus `sbt-jupiter-interface`, or run under Gradle/Maven. Simpler: use the `-u` route above if
ScalaTest is available.

**Kotest** — `JunitXmlReporter` in `AbstractProjectConfig`, output under `build/test-results/test/`.

## Python

**pytest** — `--junitxml=path/report.xml`. One file, not a directory; point `--junit` at its
parent. Use `-o junit_family=xunit2` if a consumer complains about the schema.

```
pytest --junitxml=build/test-results/test/report.xml
```

**unittest** — no native support. Use `pytest` as the runner, or `unittest-xml-reporting`
(`xmlrunner.XMLTestRunner(output='build/test-results')`).

## JavaScript / TypeScript

**Vitest** — `--reporter=junit --outputFile=build/test-results/test/report.xml`. Multiple
reporters: `--reporter=default --reporter=junit`.

**Jest** — needs `jest-junit`:

```json
{ "reporters": ["default", ["jest-junit", { "outputDirectory": "build/test-results/test" }]] }
```

**Mocha** — `--reporter mocha-junit-reporter --reporter-options mochaFile=build/test-results/test/report.xml`.

**Playwright** — `--reporter=junit`, with `PLAYWRIGHT_JUNIT_OUTPUT_NAME` for the path.

## Go

No native JUnit output. Pipe through a converter:

```
go test -v ./... 2>&1 | go-junit-report -set-exit-code > build/test-results/test/report.xml
```

`gotestsum --junitfile build/test-results/test/report.xml` is the friendlier option.

Go test names are function identifiers — see *Languages where the test name is an
identifier* below. `func TestReqHealthLiveOk` works with plain `go test`.

## Rust

`cargo-nextest`: `cargo nextest run --profile ci` with

```toml
[profile.ci.junit]
path = "junit.xml"
```

Output lands under `target/nextest/ci/`. Plain `cargo test` cannot emit JUnit.

Test names are identifiers — see *Languages where the test name is an identifier* below.
`#[test] fn req_health_live_ok()` works with plain `cargo test` under nextest; there is no
need for `libtest-mimic` or any other trick to get a `#` into the name.

## .NET

`dotnet test --logger "junit;LogFilePath=build/test-results/test/report.xml"` — needs the
`JunitXml.TestLogger` package. The default `trx` logger is *not* JUnit XML; converting it is
possible but adding the logger is simpler.

## Ruby

**RSpec** — `rspec_junit_formatter` gem:
`rspec --format RspecJunitFormatter --out build/test-results/test/report.xml`.

**Minitest** — `minitest-reporters` with `JUnitReporter`.

## PHP

**PHPUnit** — `--log-junit build/test-results/test/report.xml`, or `<junit>` in
`phpunit.xml`.

## Languages where the test name is an identifier

Go, Rust, and anything that derives the test name from a function name cannot carry `#id`
in the name — `#` and `-` are not legal in an identifier. **Use the `req_` form instead:**

```rust
#[test]
fn req_health_live_ok() { … }
```

```go
func Test_req_health_live_ok(t *testing.T) { … }
```

Go's convention is CamelCase, but underscores are legal in a test function name and are
what the matcher needs — `TestReqHealthLiveOk` will **not** match.

`req_health_live_ok` binds to the requirement `#health-live-ok`; underscores and hyphens are
the same separator. Plain `#[test]` and plain `go test` work — **no `libtest-mimic`, no
subtest wrapper, no converter beyond the usual JUnit one.**

The id is matched against the ids your documents define, longest first, so a descriptive
suffix costs nothing and a requirement may have several tests:
`req_health_live_ok_when_starting` and `req_health_live_ok_under_load` both bind
`#health-live-ok`. An unrecognised `req_` is reported as an orphan, so typos fail the build.

The `req_` prefix is not decoration. Without it, a bare id would match by accident: `live_ok`
is a substring of `live_ok_fails`, and short ids like `err` would match almost anything. The
prefix makes the binding explicit and reads as documentation.

Subtests with string names still work if you prefer them —
`t.Run("#health-live-ok answers 200", …)` — and give you a human-readable name in the report.
That is the only reason to choose them.

Do **not** use a sidecar map from test name to ids. It is a second artefact to keep in sync,
which is what this design exists to avoid.

## Verifying

```
rm -rf <dir> && <run tests> ; ls -R <dir>
```

Then check a name survived:

```
grep -o 'name="[^"]*"' <dir>/*.xml | head
```

If the ids are not in those names, nothing downstream will work.
