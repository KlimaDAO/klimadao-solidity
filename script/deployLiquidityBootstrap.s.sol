// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * \
 * Authors: Cujo <rawr@cujowolf.dev>
 * EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
 *
 * Script to deploy Infinity diamond with Cut, Loupe, Ownership and Infinity facets
 * /*****************************************************************************
 */

import "forge-std/Script.sol";
import {KlimaLiquidityBootstrap} from "src/protocol/liquidity/KlimaLiquidityBootstrap.sol";

contract DeployInfinityScript is Script {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address DAO = vm.envAddress("DAO_MSIG");
        address depositor = 0x5a755a0955187eB8047536d10d769930bBc36CA8;
        address pairToken = 0x82B37070e43C1BA0EA9e2283285b674eF7f1D4E2;
        uint256 pairTokenDecimals = 18;
        uint256 bootstrapPrice = 1e7;

        vm.startBroadcast(deployerPrivateKey);

        KlimaLiquidityBootstrap bootstrap =
            new KlimaLiquidityBootstrap(depositor, pairToken, pairTokenDecimals, bootstrapPrice);

        bootstrap.transferOwnership(DAO);

        console.log("CCO2 bootstrap deployed: %s", address(bootstrap));

        vm.stopBroadcast();
    }
}
