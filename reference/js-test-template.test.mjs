// Template: one test file per module under test.
// Run with: node --test
// Uses only node:test and node:assert/strict — no dependencies.
import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { doSomething } from "../src/target.mjs";

describe("target", () => {
  it("happy path: returns the exact expected value", () => {
    const result = doSomething(2, 3);
    assert.equal(result, 5);
  });

  it("second call: state accumulates correctly", () => {
    doSomething(2, 3);
    const result = doSomething(2, 3);
    assert.equal(result, 10);
  });

  it("boundary: zero input throws with the exact message", () => {
    assert.throws(() => doSomething(0, 0), /zero/i);
  });

  it("boundary: over-limit input throws", () => {
    assert.throws(() => doSomething(Number.MAX_SAFE_INTEGER, 1), /limit/i);
  });

  it("async: await the promise and assert the resolved value", async () => {
    const result = await Promise.resolve(doSomething(1, 1));
    assert.equal(result, 2);
  });
});
