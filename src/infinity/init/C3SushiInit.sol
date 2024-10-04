// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../AppStorage.sol";
import "../C.sol";

contract C3SushiInit {
    AppStorage internal s;

    function init() external {
        // Default UBO Swap setup
        s.swap[C.ubo()][C.usdc()].swapDexes = [0];
        s.swap[C.ubo()][C.usdc()].ammRouters = [C.sushiRouter()];
        s.swap[C.ubo()][C.usdc()].swapPaths[0] = [C.usdc(), C.klima(), C.ubo()];

        s.swap[C.ubo()][C.klima()].swapDexes = [0];
        s.swap[C.ubo()][C.klima()].ammRouters = [C.sushiRouter()];
        s.swap[C.ubo()][C.klima()].swapPaths[0] = [C.klima(), C.ubo()];

        // Default NBO Swap setup
        s.swap[C.nbo()][C.usdc()].swapDexes = [0];
        s.swap[C.nbo()][C.usdc()].ammRouters = [C.sushiRouter()];
        s.swap[C.nbo()][C.usdc()].swapPaths[0] = [C.usdc(), C.klima(), C.nbo()];

        s.swap[C.nbo()][C.klima()].swapDexes = [0];
        s.swap[C.nbo()][C.klima()].ammRouters = [C.sushiRouter()];
        s.swap[C.nbo()][C.klima()].swapPaths[0] = [C.klima(), C.nbo()];
    }
}
