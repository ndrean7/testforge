# Example Gap Report

A worked example on the sample vault in `examples/vault/`. The
numbers below are the real output of running the sample suite — not
illustrative figures.

## Scope

- Repository: `testforge` sample vault (`examples/vault/`)
- Commit: sample code shipped with the skill (teaching example, not a
  real protocol)
- Measured with: `forge coverage --report summary` and `forge test`

## Baseline

Before adding tests, the vault had 0 tests. Coverage: 0% lines,
0% functions. Every function was a gap.

## Tests added

| Test | Covers | Asserts |
| --- | --- | --- |
| `testDepositUpdatesBalance` | `SimpleVault.deposit` | Exact balance and total assets after deposit |
| `testWithdrawReturnsFunds` | `SimpleVault.withdraw` | Exact balance, assets, and ETH received |
| `testWithdrawTwice` | `SimpleVault.withdraw` (second call) | Second withdraw empties the balance and reverts on a third |
| `testDepositZeroReverts` | `SimpleVault.deposit` (edge) | Reverts with `ZeroAmount` |
| `testWithdrawMoreThanBalanceReverts` | `SimpleVault.withdraw` (edge) | Reverts with `InsufficientBalance` |
| `testNonOwnerCannotPause` | `SimpleVault.pause` (access) | Non-owner call reverts |
| `testInvariantSolvency` | whole contract (invariant) | Vault ETH always equals total recorded assets |

## Bugs caught

None in the sample — it is written correct on purpose. In real runs,
this section lists every test that failed on real code, the fix, and
the test kept as a regression test. A run with an empty "Bugs caught"
section is normal; it means the code passed, not that the tests were
weak — provided the tests assert numbers, which these do.

## Still untested

Real coverage output (`forge coverage --report summary`):

| File | % Lines | % Statements | % Branches | % Funcs |
| --- | --- | --- | --- | --- |
| `src/SimpleVault.sol` | 64.00% (16/25) | 54.17% (13/24) | 33.33% (3/9) | 62.50% (5/8) |

The uncovered parts:

| File:line | Gap | Risk | Why not closed |
| --- | --- | --- | --- |
| `SimpleVault.sol:59` | `rescue()` has no test | Low — owner-only, moves excess ETH, but untested means a wrong address silently does nothing | Out of scope for the sample; add a test before using this pattern in production |
| `SimpleVault.sol:53` | `unpause()` has no test | Low — owner-only, one line, but an untested state change is still a gap | Out of scope for the sample |
| `SimpleVault.sol:31` | Deposit/withdraw while paused never tested | Medium — the pause is the emergency brake; if the guard is wrong, the brake fails when it matters most | Needs a pause-then-call test; listed here instead of written |
| `SimpleVault.sol:46,63` | Transfer-failure branches (`require(ok, ...)`) never tested | Low — hard to trigger without a malicious receiver, but the branch exists | Needs a receiver contract that rejects ETH |

## Final result

- `forge test`: 7 passed, 0 failed (6 unit + 1 invariant, 64 runs, 2,048 calls).
- `forge coverage`: 64.00% lines (16/25) on `SimpleVault.sol` — the
  gaps above are the remaining 9 lines.

Tests prove the cases they cover; they do not prove the codebase is
bug-free.
