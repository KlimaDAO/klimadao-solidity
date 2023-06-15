// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Author: Cujo

import "../AppStorage.sol";
import "../C.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

contract InitCrossPoolSwap {
    AppStorage internal s;

    function init() external {

        // s.swap[Final Token][Source token]
        
        // {SOURCE} <> KLIMA <> BCT Swaps
        s.swap[C.bct()][C.nct()].swapDexes = [0];
        s.swap[C.bct()][C.nct()].ammRouters = [C.sushiRouter()];
        s.swap[C.bct()][C.nct()].swapPaths[0] = [C.nct(), C.klima(), C.bct()];

        s.swap[C.bct()][C.ubo()].swapDexes = [1, 0];
        s.swap[C.bct()][C.ubo()].ammRouters = [C.sushiTridentRouter(), C.sushiRouter()];
        s.swap[C.bct()][C.ubo()].swapPaths[0] = [C.ubo(), C.klima()];
        s.swap[C.bct()][C.ubo()].swapPaths[1] = [C.klima(), C.bct()];

        s.swap[C.bct()][C.nbo()].swapDexes = [1, 0];
        s.swap[C.bct()][C.nbo()].ammRouters = [C.sushiTridentRouter(), C.sushiRouter()];
        s.swap[C.bct()][C.nbo()].swapPaths[0] = [C.nbo(), C.klima()];
        s.swap[C.bct()][C.nbo()].swapPaths[1] = [C.klima(), C.bct()];

        s.swap[C.bct()][C.mco2()].swapDexes = [0, 0];
        s.swap[C.bct()][C.mco2()].ammRouters = [C.quickswapRouter(), C.sushiRouter()];
        s.swap[C.bct()][C.mco2()].swapPaths[0] = [C.mco2(), C.klima()];
        s.swap[C.bct()][C.mco2()].swapPaths[1] = [C.klima(), C.bct()];


        // {SOURCE} <> KLIMA <> NCT Swaps
        s.swap[C.nct()][C.bct()].swapDexes = [0];
        s.swap[C.nct()][C.bct()].ammRouters = [C.sushiRouter()];
        s.swap[C.nct()][C.bct()].swapPaths[0] = [C.nct(), C.klima(), C.nct()];

        s.swap[C.nct()][C.ubo()].swapDexes = [1, 0];
        s.swap[C.nct()][C.ubo()].ammRouters = [C.sushiTridentRouter(), C.sushiRouter()];
        s.swap[C.nct()][C.ubo()].swapPaths[0] = [C.ubo(), C.klima()];
        s.swap[C.nct()][C.ubo()].swapPaths[1] = [C.klima(), C.nct()];

        s.swap[C.nct()][C.nbo()].swapDexes = [1, 0];
        s.swap[C.nct()][C.nbo()].ammRouters = [C.sushiTridentRouter(), C.sushiRouter()];
        s.swap[C.nct()][C.nbo()].swapPaths[0] = [C.nbo(), C.klima()];
        s.swap[C.nct()][C.nbo()].swapPaths[1] = [C.klima(), C.nct()];

        s.swap[C.nct()][C.mco2()].swapDexes = [0, 0];
        s.swap[C.nct()][C.mco2()].ammRouters = [C.quickswapRouter(), C.sushiRouter()];
        s.swap[C.nct()][C.mco2()].swapPaths[0] = [C.mco2(), C.klima()];
        s.swap[C.nct()][C.mco2()].swapPaths[1] = [C.klima(), C.nct()];

        // {SOURCE} <> KLIMA <> MCO2 Swaps
        s.swap[C.mco2()][C.bct()].swapDexes = [0, 0];
        s.swap[C.mco2()][C.bct()].ammRouters = [C.sushiRouter(), C.quickswapRouter()];
        s.swap[C.mco2()][C.bct()].swapPaths[0] = [C.bct(), C.klima()];
        s.swap[C.mco2()][C.bct()].swapPaths[0] = [C.klima(), C.mco2()];

        s.swap[C.mco2()][C.nct()].swapDexes = [0, 0];
        s.swap[C.mco2()][C.nct()].ammRouters = [C.sushiRouter(), C.quickswapRouter()];
        s.swap[C.mco2()][C.nct()].swapPaths[0] = [C.nct(), C.klima()];
        s.swap[C.mco2()][C.nct()].swapPaths[0] = [C.klima(), C.mco2()];

        s.swap[C.mco2()][C.ubo()].swapDexes = [1, 0];
        s.swap[C.mco2()][C.ubo()].ammRouters = [C.sushiTridentRouter(), C.quickswapRouter()];
        s.swap[C.mco2()][C.ubo()].swapPaths[0] = [C.ubo(), C.klima()];
        s.swap[C.mco2()][C.ubo()].swapPaths[1] = [C.klima(), C.mco2()];

        s.swap[C.mco2()][C.nbo()].swapDexes = [1, 0];
        s.swap[C.mco2()][C.nbo()].ammRouters = [C.sushiTridentRouter(), C.quickswapRouter()];
        s.swap[C.mco2()][C.nbo()].swapPaths[0] = [C.nbo(), C.klima()];
        s.swap[C.mco2()][C.nbo()].swapPaths[1] = [C.klima(), C.mco2()];

        // {SOURCE} <> KLIMA <> UBO Swaps
        s.swap[C.ubo()][C.bct()].swapDexes = [0, 1];
        s.swap[C.ubo()][C.bct()].ammRouters = [C.sushiRouter(), C.sushiTridentRouter()];
        s.swap[C.ubo()][C.bct()].swapPaths[0] = [C.bct(), C.klima()];
        s.swap[C.ubo()][C.bct()].swapPaths[1] = [C.klima(), C.ubo()];

        s.swap[C.ubo()][C.nct()].swapDexes = [0, 1];
        s.swap[C.ubo()][C.nct()].ammRouters = [C.sushiRouter(), C.sushiTridentRouter()];
        s.swap[C.ubo()][C.nct()].swapPaths[0] = [C.nct(), C.klima()];
        s.swap[C.ubo()][C.nct()].swapPaths[1] = [C.klima(), C.ubo()];

        s.swap[C.ubo()][C.mco2()].swapDexes = [1, 0];
        s.swap[C.ubo()][C.mco2()].ammRouters = [C.quickswapRouter(), C.sushiTridentRouter()];
        s.swap[C.ubo()][C.mco2()].swapPaths[0] = [C.mco2(), C.klima()];
        s.swap[C.ubo()][C.mco2()].swapPaths[1] = [C.klima(), C.ubo()];

        s.swap[C.ubo()][C.nbo()].swapDexes = [1];
        s.swap[C.ubo()][C.nbo()].ammRouters = [C.sushiTridentRouter()];
        s.swap[C.ubo()][C.nbo()].swapPaths[0] = [C.nbo(), C.klima(), C.ubo()];

        // {SOURCE} <> KLIMA <> NBO Swaps
        s.swap[C.nbo()][C.bct()].swapDexes = [0, 1];
        s.swap[C.nbo()][C.bct()].ammRouters = [C.sushiRouter(), C.sushiTridentRouter()];
        s.swap[C.nbo()][C.bct()].swapPaths[0] = [C.bct(), C.klima()];
        s.swap[C.nbo()][C.bct()].swapPaths[1] = [C.klima(), C.nbo()];

        s.swap[C.nbo()][C.nct()].swapDexes = [0, 1];
        s.swap[C.nbo()][C.nct()].ammRouters = [C.sushiRouter(), C.sushiTridentRouter()];
        s.swap[C.nbo()][C.nct()].swapPaths[0] = [C.nct(), C.klima()];
        s.swap[C.nbo()][C.nct()].swapPaths[1] = [C.klima(), C.nbo()];

        s.swap[C.nbo()][C.mco2()].swapDexes = [1, 0];
        s.swap[C.nbo()][C.mco2()].ammRouters = [C.quickswapRouter(), C.sushiTridentRouter()];
        s.swap[C.nbo()][C.mco2()].swapPaths[0] = [C.mco2(), C.klima()];
        s.swap[C.nbo()][C.mco2()].swapPaths[1] = [C.klima(), C.nbo()];

        s.swap[C.nbo()][C.ubo()].swapDexes = [1];
        s.swap[C.nbo()][C.ubo()].ammRouters = [C.sushiTridentRouter()];
        s.swap[C.nbo()][C.ubo()].swapPaths[0] = [C.ubo(), C.klima(), C.nbo()];
    }
}
