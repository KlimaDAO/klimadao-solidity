// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../AppStorage.sol";
import "../C.sol";

contract C3SushiInit {
    AppStorage internal s;

    function init() external {
        // Default UBO Swap setup
        s.swap[C.ubo()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.ubo()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.ubo()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima(), C.ubo()];

        s.swap[C.ubo()][C.klima()].swapDexes = [0];
        s.swap[C.ubo()][C.klima()].ammRouters = [C.sushiRouter()];
        s.swap[C.ubo()][C.klima()].swapPaths[0] = [C.klima(), C.ubo()];

        // Default NBO Swap setup
        s.swap[C.nbo()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.nbo()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.nbo()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima(), C.nbo()];

        s.swap[C.nbo()][C.klima()].swapDexes = [0];
        s.swap[C.nbo()][C.klima()].ammRouters = [C.sushiRouter()];
        s.swap[C.nbo()][C.klima()].swapPaths[0] = [C.klima(), C.nbo()];
    }
}
