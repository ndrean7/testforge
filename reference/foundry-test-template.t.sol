// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Target} from "../src/Target.sol";

/// Template: one test contract per contract under test.
/// Replace Target with the contract under test and fill in the
/// behaviors. Every test asserts an observable outcome with a number.
contract TargetTest is Test {
    Target internal target;
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    function setUp() public {
        target = new Target();
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    /// Happy path: assert the exact state change, with numbers.
    function testHappyPath() public {
        vm.prank(alice);
        target.doSomething{value: 1 ether}(1 ether);

        assertEq(target.balanceOf(alice), 1 ether, "balance after action");
    }

    /// Second call: state bugs hide behind the first call.
    function testSecondCall() public {
        vm.startPrank(alice);
        target.doSomething{value: 1 ether}(1 ether);
        target.doSomething{value: 1 ether}(1 ether);
        vm.stopPrank();

        assertEq(target.balanceOf(alice), 2 ether, "balance after two actions");
    }

    /// Boundary: zero input must fail with the exact reason.
    function testZeroReverts() public {
        vm.prank(alice);
        vm.expectRevert(Target.ZeroAmount.selector);
        target.doSomething{value: 0}(0);
    }

    /// Failure: an over-limit input must revert with the exact reason.
    function testOverLimitReverts() public {
        vm.prank(alice);
        vm.expectRevert(Target.InsufficientBalance.selector);
        target.doSomethingElse(2 ether);
    }

    /// Access control: a non-authorized caller must revert.
    function testNonAdminCannotCallAdmin() public {
        vm.prank(alice);
        vm.expectRevert(Target.NotAuthorized.selector);
        target.adminOnly();
    }
}
