// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Authors: Cujo <rawr@cujowolf.dev>
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535

* Script to deploy Retirement Bonds. Uses the Infinity address in .env
/******************************************************************************/

import "forge-std/Script.sol";

import {CarbonRetirementBondDepository} from "../src/protocol/bonds/CarbonRetirementBondDepository.sol";

contract DeployRetirementBonds is Script {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        //deploy facets and init contract

        CarbonRetirementBondDepository retireBonds = new CarbonRetirementBondDepository();

        console.log("Retirement Bonds deployed to %s", address(retireBonds));
        vm.stopBroadcast();
    }
}
