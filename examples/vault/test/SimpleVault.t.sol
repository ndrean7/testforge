// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleVault} from "../src/SimpleVault.sol";

/// Unit tests for SimpleVault. Every test asserts an exact number.
contract SimpleVaultTest is Test {
    SimpleVault internal vault;
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    function setUp() public {
        vault = new SimpleVault();
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    function testDepositUpdatesBalance() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        assertEq(vault.balanceOf(alice), 1 ether, "alice balance after deposit");
        assertEq(vault.totalAssets(), 1 ether, "total assets after deposit");
        assertEq(address(vault).balance, 1 ether, "vault ETH after deposit");
    }

    function testWithdrawReturnsFunds() public {
        vm.prank(alice);
        vault.deposit{value: 2 ether}();

        uint256 before = alice.balance;
        vm.prank(alice);
        vault.withdraw(1 ether);

        assertEq(vault.balanceOf(alice), 1 ether, "alice balance after withdraw");
        assertEq(vault.totalAssets(), 1 ether, "total assets after withdraw");
        assertEq(alice.balance - before, 1 ether, "ETH actually received");
    }

    function testWithdrawTwice() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        vm.prank(alice);
        vault.withdraw(1 ether);
        assertEq(vault.balanceOf(alice), 0, "balance empty after full withdraw");

        vm.prank(alice);
        vm.expectRevert(SimpleVault.InsufficientBalance.selector);
        vault.withdraw(1 wei);
    }

    function testDepositZeroReverts() public {
        vm.prank(alice);
        vm.expectRevert(SimpleVault.ZeroAmount.selector);
        vault.deposit{value: 0}();
    }

    function testWithdrawMoreThanBalanceReverts() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();

        vm.prank(alice);
        vm.expectRevert(SimpleVault.InsufficientBalance.selector);
        vault.withdraw(2 ether);
    }

    function testNonOwnerCannotPause() public {
        vm.prank(alice);
        vm.expectRevert(SimpleVault.NotOwner.selector);
        vault.pause();

        vault.pause();
        assertTrue(vault.paused(), "owner can pause");
    }
}
