// A tiny balance ledger, written as a teaching sample for TestForge.
// Deposit and withdraw update exact balances; anything else throws.
export function createLedger() {
  const balances = new Map();
  let total = 0;

  return {
    deposit(user, amount) {
      if (!Number.isInteger(amount) || amount <= 0) {
        throw new Error("amount must be a positive integer");
      }
      balances.set(user, (balances.get(user) ?? 0) + amount);
      total += amount;
      return balances.get(user);
    },
    withdraw(user, amount) {
      if (!Number.isInteger(amount) || amount <= 0) {
        throw new Error("amount must be a positive integer");
      }
      const bal = balances.get(user) ?? 0;
      if (amount > bal) throw new Error("insufficient balance");
      balances.set(user, bal - amount);
      total -= amount;
      return balances.get(user);
    },
    balanceOf(user) {
      return balances.get(user) ?? 0;
    },
    total() {
      return total;
    },
  };
}
