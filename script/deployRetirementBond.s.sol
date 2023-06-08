// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Authors: Cujo <rawr@cujowolf.dev>
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535

* Script to deploy Retirement Bonds. Uses the Infinity address in .env
/******************************************************************************/

import "forge-std/Script.sol";

import {CarbonRetirementBondDepository} from "../src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "../src/protocol/allocators/RetirementBondAllocator.sol";

contract DeployRetirementBonds is Script {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        CarbonRetirementBondDepository retireBonds = new CarbonRetirementBondDepository();
        RetirementBondAllocator allocator = new RetirementBondAllocator(address(retireBonds));

        retireBonds.setAllocator(address(allocator));

        console.log("Retirement Bonds deployed to %s", address(retireBonds));
        console.log("Retirement Bond Allocator deployed to %s", address(allocator));
        vm.stopBroadcast();
    }
}
