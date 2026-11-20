# Listing — TestForge (Agensi)

Copy ready for upload to Agensi. Free v1 — free so it gets users fast.

## Title

TestForge

## Tagline

Untested code is where bugs hide — find the gaps, write real tests, run them until green.

## Description

Every codebase has code nobody tested: the error branch nobody took,
the withdraw path nobody called twice, the rounding edge nobody hit.
That is where bugs live — and a test suite that only covers the happy
path is a blanket with holes in it.

Give TestForge a codebase and it finds the holes. It measures coverage,
lists every untested function and branch with file and line, ordered by
risk — money-moving code first — then writes a real test for each gap.
A real test asserts observable behavior with numbers: balances moved,
state changed, the call reverted for the exact reason. A test that
cannot fail is not a test, and this skill never writes one.

Then it runs the suite, reads the failures, and decides: is the test
wrong, or is the code wrong? It fixes the right one and repeats until
everything is green. What is still untested at the end is written down
in a gap report, so nobody has to guess.

Two stacks. Solidity goes through Foundry: unit tests, fuzz tests, and
stateful invariant tests that hammer a contract with random sequences
of calls — with the hard-won lessons built in (pin the fuzz target,
check a view before summing it, fund the paying contract, assert
against the contract's own ledger). JavaScript and TypeScript go
through the Node test runner with zero dependencies — no framework to
install, no config to fight.

Built from real testing practice, measured on real work: a 120-test
suite running 120/120, a chess engine verified with perft 6/6, an agent
codebase kept at 9/9 tests passing. The same discipline is in this
skill: assert numbers, run the suite, and do not call a test done until
it is green for the right reason.

What it does not do: it never claims full coverage it did not measure,
and it never promises a codebase is bug-free. Tests prove the cases
they cover — the gap report says the rest plainly.

## Category

Testing & Debugging

## Tags

testing, foundry, solidity, javascript, coverage, invariant,
test-gap, unit-test

## Price

Free

## What buyers get

- A coverage-gap map: every untested function and branch, with file
  and line, ordered by risk
- Real tests written for the gaps — Foundry unit, fuzz, and invariant
  tests for Solidity; Node test-runner tests for JavaScript/TypeScript
- A run-until-green loop: failures read and fixed on the right side
  (test or code), with regression tests kept for real bugs found
- A gap report: what was covered, what tests were added, what is
  still untested and why — with the final suite result
- A worked sample vault (7/7 Foundry tests passing, real coverage
  numbers) and a sample JS ledger (6/6 Node tests passing) to learn
  from and copy

## Example session

User: "This vault has no tests. What is untested?"

The skill runs `forge coverage` and finds the vault at 0% — every
function a gap. It orders them by risk (deposit and withdraw first),
writes six unit tests and one invariant test, and runs `forge test`:
7 passed, 0 failed. Coverage on the contract lands at 64% lines, and
the gap report lists exactly what is left — the rescue function, the
unpause function, and the paused-state paths — with file, line, and
risk for each. The buyer knows what is tested, what is not, and what
the open gaps risk. Full example in `reference/example-gap-report.md`.
