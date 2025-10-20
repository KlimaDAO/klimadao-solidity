// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../AppStorage.sol";
import "../C.sol";

contract UpgradeBCTSwapPaths {
    AppStorage internal s;

    function init() external {
        // Update BCT swap path from USDC.e: Direct route instead of through KLIMA
        // OLD: [USDC.e, KLIMA, BCT]
        // NEW: [USDC.e, BCT]
        s.swap[C.bct()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.bct()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.bct()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.bct()];

        // Same for NCT
        s.swap[C.nct()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.nct()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.nct()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.nct()];

        // Remove the KLIMA direct paths (pools being deprecated)
        delete s.swap[C.bct()][C.klima()].swapDexes;
        delete s.swap[C.bct()][C.klima()].ammRouters;
        delete s.swap[C.bct()][C.klima()].swapPaths[0];

        delete s.swap[C.nct()][C.klima()].swapDexes;
        delete s.swap[C.nct()][C.klima()].ammRouters;
        delete s.swap[C.nct()][C.klima()].swapPaths[0];
    }
}
