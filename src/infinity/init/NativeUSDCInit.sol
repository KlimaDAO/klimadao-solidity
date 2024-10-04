// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC173} from "../interfaces/IERC173.sol";
import "../AppStorage.sol";
import "../C.sol";



contract NativeUSDCInit {
    AppStorage internal s;
    function init() external {

        /* Default BCT Swap setup */
        s.swap[C.bct()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.bct()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.bct()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima(), C.bct()];

        /* Default NCT Swap setup */
        s.swap[C.nct()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.nct()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.nct()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.nct()];

        /* Default MCO2 Swap setup */
        s.swap[C.mco2()][C.usdc_bridged()].swapDexes = [0, 0];
        s.swap[C.mco2()][C.usdc_bridged()].ammRouters = [C.sushiRouter(), C.quickswapRouter()];
        s.swap[C.mco2()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima()];
        s.swap[C.mco2()][C.usdc_bridged()].swapPaths[1] = [C.klima(), C.mco2()];

        /* Default UBO Swap setup */
        s.swap[C.ubo()][C.usdc_bridged()].swapDexes = [0, 1];
        s.swap[C.ubo()][C.usdc_bridged()].ammRouters = [C.sushiRouter(), C.sushiTridentRouter()];
        s.swap[C.ubo()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima()];
        s.swap[C.ubo()][C.usdc_bridged()].swapPaths[1] = [C.klima(), C.ubo()];

        /* Default NBO Swap setup */
        s.swap[C.nbo()][C.usdc_bridged()].swapDexes = [0, 1];
        s.swap[C.nbo()][C.usdc_bridged()].ammRouters = [C.sushiRouter(), C.sushiTridentRouter()];
        s.swap[C.nbo()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima()];
        s.swap[C.nbo()][C.usdc_bridged()].swapPaths[1] = [C.klima(), C.nbo()];

        /* Default Coorest CCO2 Swap Setup */
        s.swap[C.coorestCCO2Token()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.coorestCCO2Token()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.coorestCCO2Token()][C.usdc_bridged()].swapPaths[0] =
        [C.usdc_bridged(), C.klima(), C.coorestCCO2Token()];

    }
}
