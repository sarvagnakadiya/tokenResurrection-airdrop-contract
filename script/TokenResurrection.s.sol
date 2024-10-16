// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/TokenResurrection.sol"; // Adjust the import path according to your project structure;

contract DeployTokenResurrection is Script {
    function run() external {
        // Specify the address of the token you want to use for the airdrop
        // address tokenAddress = 0x4200000000000000000000000000000000000042; // Replace with the actual token address
        address tokenAddress = 0x969C1CeE57332E7e614c849Da2b6EfBC81f3fd60; // mock TRR token address

        // Start broadcasting the transaction
        vm.startBroadcast();

        // Deploy the TokenResurrection contract
        TokenResurrection tr = new TokenResurrection(tokenAddress);

        // Log the deployed contract address
        console.log("TokenResurrection deployed at:", address(tr));

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
