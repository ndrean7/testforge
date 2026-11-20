# Coverage Gap Checklist

Work this list top to bottom when mapping gaps. A gap is only real
once it has a file, a line, and a one-line risk note — "line 42 is
uncovered" without a reason it matters is not a gap, it is a statistic.

## 1. Money-moving code first

- [ ] Every function that changes a balance has a test that asserts
      the balance before and after, with exact numbers.
- [ ] Every function that moves funds out (withdraw, claim, redeem,
      payout) has a test that calls it twice in a row.
- [ ] Every fee, share, or split calculation has a test at the
      boundary: zero amount, one unit, and an amount that divides
      unevenly (rounding goes somewhere — check where).
- [ ] Every path that can leave funds stuck (failed transfer, paused
      contract, empty pool) has a test that reaches it.

## 2. Access control

- [ ] Every admin-only function has a test calling it from a
      non-admin address, asserting the exact revert.
- [ ] Every role change (grant, revoke, transfer ownership) has a
      test that checks the old holder loses access and the new holder
      gains it.
- [ ] Every function with a caller-dependent result (allowances,
      per-user limits) has a test with at least two different callers.

## 3. Error and edge paths

- [ ] Every `require` / revert condition has a test that triggers it
      and asserts the exact reason.
- [ ] Every zero case is tested: zero amount, zero address, empty
      array, empty string.
- [ ] Every limit is tested on both sides: at the limit and one over
      it (max deposit, max supply, deadline, array length).
- [ ] Every external call has a test where the call fails, and the
      contract's behavior after the failure is asserted.

## 4. State and sequences

- [ ] Every state transition is tested in both directions where one
      exists (pause/unpause, open/close, activate/deactivate).
- [ ] Every multi-step flow (deposit then withdraw, propose then
      execute) has a test that runs the full sequence, not just each
      step alone.
- [ ] Every invariant the code claims ("total supply equals the sum
      of balances", "no user can withdraw more than they deposited")
      has an invariant test that hammers it with random sequences.

## 5. The boring-but-real ones

- [ ] View/pure functions that other code depends on have tests —
      a wrong getter breaks everything downstream silently.
- [ ] Constructor and initializer parameters are tested with the
      values the deployment actually uses, not just the defaults.
- [ ] Upgrade paths (if any) have a test that upgrades and then
      calls the old functions to confirm state survived.

## How to use the list

Check off what is covered with the test name that covers it. What is
left unchecked is the gap list — copy it into the report with file
and line. If an item does not apply (no upgrades, no fees), write
"n/a — reason" next to it. An unchecked item with no note is not
finished work, it is forgotten work.
