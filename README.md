# TestForge

Find the code nobody tested and write tests that actually catch bugs.

Give TestForge a codebase and it measures what is covered, lists what
is not, and closes the gaps one function at a time. For each gap it
writes a real test — one that asserts observable behavior with numbers,
not a test that calls a function and checks nothing. Then it runs the
suite until green and reports what is still untested, with file and
line references.

Two stacks: Solidity through Foundry (unit, fuzz, and stateful
invariant tests) and JavaScript/TypeScript through the Node test
runner, with zero dependencies.

## What is in here

- `SKILL.md` — the skill: how to map gaps, write real tests, run
  until green, and report.
- `reference/coverage-gap-checklist.md` — the checklist for mapping
  gaps, ordered by risk.
- `reference/example-gap-report.md` — a worked gap report on the
  sample vault, with real measured numbers.
- `reference/foundry-test-template.t.sol` — Foundry unit test template.
- `reference/js-test-template.test.mjs` — Node test template.
- `scripts/testforge-init.sh` — scaffold a test workspace for a
  target codebase.
- `scripts/gap-scan.mjs` — rough map of untested exports in a JS/TS
  project. No dependencies.
- `examples/vault/` — a sample ETH vault with Foundry unit tests and
  an invariant test. `forge test` passes 7/7. `forge-std` is vendored
  in `lib/`, so no install step is needed.
- `examples/ledger/` — a sample JS ledger with Node tests. `node
  --test` passes 6/6.

## Quick start

```sh
# Solidity: run the sample suite
cd examples/vault && forge test

# JavaScript: run the sample suite
cd examples/ledger && node --test

# Map gaps in your own JS/TS project
node scripts/gap-scan.mjs <src-dir> <test-dir>

# Scaffold a test workspace for a target repo
sh scripts/testforge-init.sh /path/to/repo-copy <name> [solidity|js]
```

## Track record

This workflow is the author's own testing practice, measured on real
work:

- A 120-test suite for a code-forging tool, **120/120 passing**.
- A chess engine verified with **perft 6/6** (exact move counts at
  depth 6).
- An agent codebase with **9/9 tests passing** (`npm test`).

## Honest limits

Tests prove the cases they cover; they never prove a codebase is
bug-free. A test suite can be green and still miss the bug — that is
what the gap report is for. This skill does not promise a bug will be
found, and it does not certify code as safe.

## Agensi

Listed on Agensi as **TestForge** (Testing & Debugging, free):
https://www.agensi.io/skills/testforge

## License

MIT © 2026 ndrean7. Original work — written from the author's own
testing practice and general testing knowledge, not copied from any
other skill, course, or test suite.
