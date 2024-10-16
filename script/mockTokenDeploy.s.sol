// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/mock/MockERC20.sol";

contract DeployTokenResurrection is Script {
    function run() external {
        // Start the broadcast for transaction to go on-chain
        vm.startBroadcast();

        // Deploy the contract, setting the deployer as the initial owner
        TokenResurrection token = new TokenResurrection(msg.sender);

        // Mint 10,000 tokens to the deployer's address
        token.mint(msg.sender, 10000 ether);

        // Stop the broadcast after transactions
        vm.stopBroadcast();
    }
}
