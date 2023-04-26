// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Authors: Cujo <rawr@cujowolf.dev>

* Script to deploy the Klima protocol contracts
/******************************************************************************/

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {console} from "forge-std/console.sol";

import {KlimaTreasury} from "../src/protocol/staking/utils/KlimaTreasury.sol";

contract DeployKlimaTreasury is Script {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address bctAddress = vm.envAddress("BCT_ERC20_ADDRESS");
        address klimaAddress = vm.envAddress("KLIMA_ERC20_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        KlimaTreasury treasury = new KlimaTreasury(
            klimaAddress,
            bctAddress,
            34560 // amount of blocks needed to queue txs before they can be executed
        );

        console.log("Treasury deployed to :", address(treasury));

        vm.stopBroadcast();
    }
}
