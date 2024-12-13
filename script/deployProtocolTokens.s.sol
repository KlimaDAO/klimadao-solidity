// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

/**
 * \
 * Authors: Cujo <rawr@cujowolf.dev>
 *
 * Script to deploy the Klima tokens and protocol contracts
 * /*****************************************************************************
 */
import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {console} from "forge-std/console.sol";

import {KlimaToken} from "../src/protocol/tokens/regular/KlimaToken.sol";
import {sKLIMAv2} from "../src/protocol/tokens/regular/sKlimaToken_v2.sol";
import {wsKLIMA} from "../src/protocol/tokens/regular/wsKLIMA.sol";

// import "../test/infinity/HelperContract.sol";

contract DeployKlimaProtocolTokens is Script {
    function run() external returns (address, address, address) {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy tokens

        KlimaToken klima = new KlimaToken();
        console.log("  Klima Token Deployed at: ", address(klima));

        sKLIMAv2 sKlima = new sKLIMAv2();
        console.log(" sKlima Token Deployed at: ", address(sKlima));

        wsKLIMA wsKlima = new wsKLIMA(address(sKlima));
        console.log("wsKlima Token Deployed at: ", address(wsKlima));

        vm.stopBroadcast();

        return (address(klima), address(sKlima), address(wsKlima));
    }
}
