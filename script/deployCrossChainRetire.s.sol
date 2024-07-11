// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

/**
 * \
 * Authors: Cujo <rawr@cujowolf.dev>
 *
 * Script to deploy the cross chain retirement target for Axelar ITS
 * /*****************************************************************************
 */
import "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {InfinityCrossChainRetire} from "src/axelar/InfinityCrossChainRetire.sol";

contract DeployInfinityCrossChain is Script {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy tokens

        address AXELAR_ITS = 0xB5FB4BE02232B1bBA4dC8f81dc24C26980dE9e3C;
        address AXELAR_GAS_RECEIVER = 0x2d5d7d31F671F86C782533cc367F14109a082712;

        InfinityCrossChainRetire retireTarget = new InfinityCrossChainRetire(AXELAR_ITS, AXELAR_GAS_RECEIVER);
        console.log("InfinityCrossChainRetire Deployed to: ", address(retireTarget));

        vm.stopBroadcast();
    }
}
