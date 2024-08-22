// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {LibRetire} from "../libraries/LibRetire.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {LibApprove} from "../libraries/Token/LibApprove.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import "../AppStorage.sol";
import "../C.sol";

contract DiamondInitCoorest {
    AppStorage internal s;

    function init() external {
        s.bridges[0].name = "Coorest";
        s.poolBridge[C.coorestCCO2Token()] = LibRetire.CarbonBridge.COOREST;
        s.isPoolToken[C.coorestCCO2Token()] = true;

        // Default Coorest CCO2 Swap Setup
        s.swap[C.coorestCCO2Token()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.coorestCCO2Token()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.coorestCCO2Token()][C.usdc_bridged()].swapPaths[0] =
            [C.usdc_bridged(), C.klima(), C.coorestCCO2Token()];

        s.swap[C.coorestCCO2Token()][C.klima()].swapDexes = [0];
        s.swap[C.coorestCCO2Token()][C.klima()].ammRouters = [C.sushiRouter()];
        s.swap[C.coorestCCO2Token()][C.klima()].swapPaths[0] = [C.klima(), C.coorestCCO2Token()];
    }
}
