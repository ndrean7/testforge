// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// A minimal ETH vault, written as a teaching sample for TestForge.
/// Users deposit ETH, withdraw it later, and the owner can pause.
/// The owner can also rescue excess ETH (ETH that arrived without a
/// deposit) — that path is intentionally left untested in the sample
/// and listed as the open gap in reference/example-gap-report.md.
contract SimpleVault {
    error ZeroAmount();
    error InsufficientBalance();
    error NothingToRescue();
    error Paused();
    error NotOwner();

    address public immutable owner;
    bool public paused;
    uint256 public totalAssets;
    mapping(address => uint256) public balanceOf;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert Paused();
        _;
    }

    function deposit() external payable whenNotPaused {
        if (msg.value == 0) revert ZeroAmount();
        balanceOf[msg.sender] += msg.value;
        totalAssets += msg.value;
    }

    function withdraw(uint256 amount) external whenNotPaused {
        if (amount > balanceOf[msg.sender]) revert InsufficientBalance();
        balanceOf[msg.sender] -= amount;
        totalAssets -= amount;
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    /// Sends ETH that arrived without a deposit to the owner.
    /// Untested in the sample — see the gap report.
    function rescue(address to) external onlyOwner {
        uint256 excess = address(this).balance - totalAssets;
        if (excess == 0) revert NothingToRescue();
        (bool ok,) = to.call{value: excess}("");
        require(ok, "transfer failed");
    }
}
