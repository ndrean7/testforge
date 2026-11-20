// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleVault} from "../src/SimpleVault.sol";

/// Handler: the fuzzer calls these functions in random sequences.
contract VaultHandler is Test {
    SimpleVault internal vault;

    constructor(SimpleVault _vault) {
        vault = _vault;
    }

    receive() external payable {}

    function deposit(uint256 amount) public {
        amount = bound(amount, 0.01 ether, 5 ether);
        if (amount > address(this).balance) return;
        vault.deposit{value: amount}();
    }

    function withdraw(uint256 amount) public {
        uint256 bal = vault.balanceOf(address(this));
        if (bal == 0) return;
        amount = bound(amount, 0.01 ether, bal);
        vault.withdraw(amount);
    }
}

/// Invariant: the vault always holds exactly what users deposited —
/// no more, no less. The target is pinned to the handler only, so
/// the fuzzer never wastes calls on unrelated contracts.
contract SimpleVaultInvariant is Test {
    SimpleVault internal vault;
    VaultHandler internal handler;

    function setUp() public {
        vault = new SimpleVault();
        handler = new VaultHandler(vault);
        vm.deal(address(handler), 1000 ether);
        targetContract(address(handler));
    }

    /// forge-config: default.invariant.runs = 64
    /// forge-config: default.invariant.depth = 32
    function invariantSolvency() public view {
        assertEq(address(vault).balance, vault.totalAssets(), "vault ETH equals recorded assets");
    }
}
