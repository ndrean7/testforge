---
name: testforge
description: Find the code nobody tested and write tests that actually catch bugs — map coverage gaps, write real Foundry and JavaScript tests that assert behavior, run them until green, and report what is still untested with file and line references. Use when a codebase needs tests, a test suite is thin, or a change needs proof it works.
summary: Untested code is where bugs hide — find the gaps, write real tests, run them until green.
version: 1.0.0
tags:
  - testing
  - foundry
  - solidity
  - javascript
  - coverage
  - invariant
keywords:
  - test coverage
  - untested code
  - foundry test
  - invariant test
  - write tests
use_cases:
  - Find untested code in a Solidity or JavaScript codebase
  - Write Foundry unit and invariant tests for a contract
  - Write JavaScript tests with the Node test runner
  - Prove a fix works by adding a failing-then-passing test
  - Produce a gap report before a release or audit
hosts: []
docs_url: https://github.com/ndrean7/testforge
---

# TestForge

## Name

testforge

## Description

Give it a codebase and it finds the code nobody tested — then writes
tests that actually catch bugs. Untested code is where bugs hide: the
error branch nobody took, the withdraw path nobody called twice, the
rounding edge nobody hit. A test suite that only covers the happy path
is a blanket with holes in it.

The skill works the way a careful developer works: measure what is
covered, list what is not, and close the gaps one function at a time.
For each gap it writes a real test — one that asserts observable
behavior (balances moved, state changed, the call reverted for the
right reason), not a test that calls a function and checks nothing.
Then it runs the suite, reads the failures, fixes the test or the code
(and says which one it was), and repeats until everything is green.
What is still untested at the end is written down with file and line
references, so nobody has to guess.

Two stacks are covered. Solidity goes through Foundry: unit tests,
fuzz tests, and stateful invariant tests that hammer a contract with
random sequences of calls. JavaScript and TypeScript go through the
Node test runner (`node:test` + `node:assert`), with zero dependencies
— no test framework to install, no config to fight.

This is not a scanner dump and not a promise. Tests prove the cases
they cover; they never prove a codebase is bug-free, and the gap report
says so.

## Why trust this workflow

It is the author's own testing practice, measured on real work:

- A 120-test suite for a code-forging tool, **120/120 passing**, with
  a measured CPU improvement of 7.6% — every test asserts a number,
  not a vibe.
- A chess engine verified with **perft 6/6** (exact move counts at
  depth 6) and an Elo gain measured across matches, not claimed.
- An agent codebase with **9/9 tests passing** (`npm test`), kept
  green across every change.

The same discipline is in this skill: assert numbers, run the suite,
and do not call a test done until it is green for the right reason.

## How it works

1. **Measure.** Run the coverage tool for the stack (`forge coverage`
   for Solidity, a coverage run or the gap scanner in `scripts/` for
   JavaScript) and record the baseline: which files, functions, and
   branches are covered, and which are not.
2. **Map the gaps.** Turn the coverage output into a gap list: every
   untested function and untested branch, with file and line, ordered
   by risk — money-moving code first, then access control, then
   everything else. See `reference/coverage-gap-checklist.md`.
3. **Write real tests.** For each gap, write a test that asserts
   observable behavior. A test that cannot fail is not a test. Use the
   templates in `reference/` and the worked examples in `examples/`.
4. **Run until green.** Run the suite, read each failure, and decide:
   is the test wrong, or is the code wrong? Fix the right one, re-run,
   and keep the failing case in the suite as a regression test when the
   code was at fault.
5. **Report.** Write the gap report: what was covered, what tests were
   added, what is still untested and why, and the final suite result.
   The report format is in `reference/example-gap-report.md`.

## Instructions

### Start a gap run

```sh
# From the skill directory. Scaffolds a test workspace for the target:
sh scripts/testforge-init.sh /path/to/repo-copy <name>
```

Work inside the workspace it creates. Never edit the original
repository. For Solidity, the workspace is a Foundry project
(`forge test` runs the suite). For JavaScript, it is a plain Node
project (`node --test` runs the suite).

### Step 1 — measure coverage

Solidity:

```sh
forge coverage --report summary
forge coverage --report lcov   # per-line detail, for the gap list
```

JavaScript / TypeScript: run the suite with coverage if the project
already has a tool for it. If it does not, run the gap scanner:

```sh
node scripts/gap-scan.mjs <src-dir> <test-dir>
```

It lists every exported function and whether any test file mentions
it. It is a rough map, not a proof — a function can be mentioned by a
test and still never asserted on. Read the tests before trusting the
map.

### Step 2 — map the gaps

Build the gap list from the coverage output, using the checklist in
`reference/coverage-gap-checklist.md`. Order it by risk:

1. Functions that move money or change balances.
2. Access control: who can call what, and what stops anyone else.
3. Error and edge paths: reverts, zero amounts, empty inputs, limits.
4. Everything else, in dependency order.

For each gap record: file, line, function or branch, and one line on
what could go wrong there untested. A gap without a risk note is a
guess, not a plan.

### Step 3 — write real tests

Use the templates in `reference/`. Every test must assert observable
behavior. These are the rules that separate a real test from a
placeholder:

- **Assert a number.** A balance, a count, a return value, a revert
  reason. "It did not revert" is not an assertion.
- **Test the second call.** Deposit twice, withdraw twice, call the
  admin function from a non-admin. The first call is the demo; the
  second call is where state bugs live.
- **Test the boundary.** Zero, one, max, empty, and one over the
  limit. Off-by-one errors live at boundaries.
- **Test the failure.** A function that should revert must be tested
  with the input that makes it revert, asserting the exact reason.
- **One behavior per test.** A test that checks five things tells you
  nothing when it fails.

#### Foundry unit tests

One test contract per contract under test. Set up from a clean deploy
in `setUp()`. Use `vm.prank` for caller control and `vm.expectRevert`
for failure cases. A passing test that never touches the target
function is a lie — check the coverage after adding it.

#### Foundry invariant tests

Stateful invariants catch what unit tests miss: sequences of calls
that leave the contract in a state no single call can reach. Lessons
from real invariant suites, learned the hard way:

- **Pin the fuzz target.** By default Foundry throws calls at every
  contract deployed in `setUp()`. Restrict the target set to the
  contracts under test, or most calls revert on admin-only and
  uninitialized functions and the run proves nothing. Verify with the
  per-selector call table, not with pass/fail.
- **Check a view before you sum it.** Some getters return a value
  that is already account-wide; summing it per key counts it many
  times and invents a fake shortfall. Read the getter before summing.
- **Drive the interesting paths.** Default parameters often sit at
  zero, so the fuzz never reaches the branches that matter. Add a
  handler action that moves the parameters across their range, bounded
  so the setters themselves never revert.
- **Fund the paying contract.** If the tested action pays out of a
  second contract (a vault, a treasury, a controller), fund that
  contract in `setUp()` — not just the users. Otherwise the payout
  path never executes and the invariants pass vacuously.
- **Assert against the contract's own ledger.** Do not re-implement
  the contract's formula inside the test to predict the result — the
  two will drift apart on edge arithmetic and produce false alarms.
  Execute, then read the contract's own recorded outcome and assert
  it is one of the valid outcomes.
- **A failing sequence is a lead, not a finding.** Re-run it
  standalone with explicit arguments and printed intermediate values
  before writing anything up. Two out of two breaks in one real
  campaign turned out to be harness mistakes, not protocol bugs.

#### JavaScript / TypeScript tests

Use `node:test` and `node:assert/strict` — no dependencies. One test
file per module, next to or under `test/`. Test the exported behavior,
not internals. For async code, await the promise and assert the
resolved value; an un-awaited promise passes even when it rejects.

### Step 4 — run until green

```sh
forge test            # Solidity: full suite
node --test           # JavaScript: full suite
```

Read every failure and decide: test wrong or code wrong?

- **Test wrong:** the setup, the expected value, or the assumption
  was mistaken. Fix the test and say why in the commit or the report.
- **Code wrong:** the code does what the test proves it should not.
  Fix the code, keep the failing test as a regression test, and note
  it in the report as a bug the suite caught.

Never silence a failure by deleting the test, weakening the assertion,
or skipping it without a written reason. A skipped test is an open gap
and goes in the report as one.

A suite is green only when every test passes for the right reason:
re-run with a different fuzz seed (`forge test --fuzz-seed <n>`) for
Solidity, and confirm the run is not order-dependent for JavaScript
(run the files in a different order at least once).

### Step 5 — report the gaps

Write the gap report in the format of
`reference/example-gap-report.md`:

1. **Scope** — repository, commit, and what was measured.
2. **Baseline** — coverage before, in numbers.
3. **Tests added** — one line each: what it covers and what it
   asserts.
4. **Bugs caught** — tests that failed on real code, with the fix.
5. **Still untested** — file and line for every remaining gap, with
   the risk note and the reason it was not closed.
6. **Final result** — suite command and outcome (e.g. `forge test`:
   14 passed, 0 failed), plus the honest line: "Tests prove the cases
   they cover; they do not prove the codebase is bug-free."

### Answering questions

- **"What is untested here?"** — Measure first, then answer from
  the gap list with file and line. Never guess from reading alone.
- **"Write a test for this function."** — Read the function, write
  the test to the template, run it, and report the result. A test
  that was never run is a draft, not a test.
- **"Is this code covered?"** — Answer from the coverage output, not
  from memory. If the tooling is missing, say so and use the gap
  scanner.
- **"My test fails — is the code broken?"** — Decide from the
  evidence: reproduce with a minimal case, print the intermediate
  values, and only then say which side is wrong.
- **"Are we done testing?"** — Answer with the gap report: what is
  covered, what is still open, and what the open gaps risk. "Done"
  is a decision the user makes with that list in front of them.

## Rules — do not break these

- **A test that never runs is a draft.** Every test ships with a
  recorded run: command and result.
- **A test that cannot fail is not a test.** Assert observable
  behavior with numbers. "It did not revert" is not an assertion.
- **Never delete or weaken a failing test to get green.** A failure
  is either a wrong test (fix it, say why) or a real bug (fix the
  code, keep the test).
- **Never claim full coverage you did not measure.** Coverage numbers
  come from the tool output, not from counting test files.
- **Tests prove cases, not safety.** The report always says tests
  prove the cases they cover and never claims the code is bug-free.
- **No copied tests.** Tests are written from reading this codebase,
  not lifted from another repo, another entry, or a public suite.
  Examples in this skill are teaching samples, written by the author,
  and are labelled as such.
- **Original work.** This skill is the author's own methodology (MIT,
  © 2026 ndrean7), written from the author's own testing practice and
  general testing knowledge. It is not copied from any other skill,
  course, or test suite.

## Requirements

- Foundry (`forge`) for Solidity tests, or Node.js 18+ for JavaScript
  tests (`node:test` is built in — no dependencies).
- A local copy of the target repository at a pinned commit.
- `forge coverage` for Solidity coverage; the gap scanner in
  `scripts/` for JavaScript projects without a coverage tool.
- No network access is required to write or run tests. A mainnet fork
  is used only when the user explicitly provides an RPC URL.
