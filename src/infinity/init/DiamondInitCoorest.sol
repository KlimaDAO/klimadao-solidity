// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {LibMeta} from "../libraries/LibMeta.sol";
import {LibApprove} from "../libraries/Token/LibApprove.sol";

import "../AppStorage.sol";
import "../C.sol";

contract DiamondInitCoorest {
    AppStorage internal s;

    function init() external {
        // Do we want to update the version?
        s.domainSeparator = LibMeta.domainSeparator("KlimaInfinityDiamond", "V1");
        
        s.bridges[0].name = "Coorest";
        s.poolBridge[C.coorestCCO2Token()] = LibRetire.CarbonBridge.COOREST;
        s.isPoolToken[C.coorestCCO2Token()] = true;

        // Default Coorest CCO2 Swap Setup
        s.swap[C.coorestCCO2Token()][C.usdc()].swapDexes = [0];
        s.swap[C.coorestCCO2Token()][C.usdc()].ammRouters = [C.sushiRouter()];
        s.swap[C.coorestCCO2Token()][C.usdc()].swapPaths[0] = [C.usdc(), C.klima(), C.coorestCCO2Token()];
    }
}
