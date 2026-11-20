// Tests for the sample ledger. Run with: node --test
// Uses only node:test and node:assert/strict — no dependencies.
import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { createLedger } from "./ledger.mjs";

describe("ledger", () => {
  it("deposit updates the exact balance", () => {
    const ledger = createLedger();
    assert.equal(ledger.deposit("alice", 100), 100);
    assert.equal(ledger.balanceOf("alice"), 100);
    assert.equal(ledger.total(), 100);
  });

  it("withdraw returns funds and updates the total", () => {
    const ledger = createLedger();
    ledger.deposit("alice", 200);
    assert.equal(ledger.withdraw("alice", 80), 120);
    assert.equal(ledger.total(), 120);
  });

  it("second withdraw empties the balance, third throws", () => {
    const ledger = createLedger();
    ledger.deposit("alice", 50);
    ledger.withdraw("alice", 50);
    assert.equal(ledger.balanceOf("alice"), 0);
    assert.throws(() => ledger.withdraw("alice", 1), /insufficient balance/);
  });

  it("zero deposit throws with the exact message", () => {
    const ledger = createLedger();
    assert.throws(() => ledger.deposit("alice", 0), /positive integer/);
  });

  it("withdrawing more than the balance throws", () => {
    const ledger = createLedger();
    ledger.deposit("alice", 10);
    assert.throws(() => ledger.withdraw("alice", 11), /insufficient balance/);
  });

  it("users are independent", () => {
    const ledger = createLedger();
    ledger.deposit("alice", 30);
    ledger.deposit("bob", 70);
    assert.equal(ledger.total(), 100);
    ledger.withdraw("bob", 70);
    assert.equal(ledger.balanceOf("alice"), 30);
    assert.equal(ledger.total(), 30);
  });
});
