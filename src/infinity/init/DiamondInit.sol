// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * \
 * Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
 * EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
 *
 * Implementation of a diamond.
 * /*****************************************************************************
 */

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import "../AppStorage.sol";
import {LibMeta} from "../libraries/LibMeta.sol";
import {LibApprove} from "../libraries/Token/LibApprove.sol";
import {IBentoBoxMinimal} from "../interfaces/ITrident.sol";
import "../C.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

contract DiamondInit {
    AppStorage internal s;

    uint private constant MAX_INT = 2 ** 256 - 1;

    // You can add parameters to this function in order to pass in
    // data to set your own state variables
    function init() external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // add your own state variables
        // EIP-2535 specifies that the `diamondCut` function takes two optional
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface

        s.domainSeparator = LibMeta.domainSeparator("KlimaInfinityDiamond", "V1");

        s.bridges[0].name = "Toucan";
        s.poolBridge[C.bct()] = LibRetire.CarbonBridge.TOUCAN;
        s.isPoolToken[C.bct()] = true;
        s.poolBridge[C.nct()] = LibRetire.CarbonBridge.TOUCAN;
        s.isPoolToken[C.nct()] = true;

        s.bridges[1].name = "Moss";
        s.poolBridge[C.mco2()] = LibRetire.CarbonBridge.MOSS;
        s.isPoolToken[C.mco2()] = true;

        s.bridges[2].name = "C3";
        s.poolBridge[C.ubo()] = LibRetire.CarbonBridge.C3;
        s.isPoolToken[C.ubo()] = true;
        s.poolBridge[C.nbo()] = LibRetire.CarbonBridge.C3;
        s.isPoolToken[C.nbo()] = true;

        // Retirement convenience fee
        s.fee = 1000;

        // Default BCT Swap setup
        s.swap[C.bct()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.bct()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.bct()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima(), C.bct()];

        s.swap[C.bct()][C.klima()].swapDexes = [0];
        s.swap[C.bct()][C.klima()].ammRouters = [C.sushiRouter()];
        s.swap[C.bct()][C.klima()].swapPaths[0] = [C.klima(), C.bct()];

        // Default NCT Swap setup
        s.swap[C.nct()][C.usdc_bridged()].swapDexes = [0];
        s.swap[C.nct()][C.usdc_bridged()].ammRouters = [C.sushiRouter()];
        s.swap[C.nct()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.nct()];

        s.swap[C.nct()][C.klima()].swapDexes = [0];
        s.swap[C.nct()][C.klima()].ammRouters = [C.sushiRouter()];
        s.swap[C.nct()][C.klima()].swapPaths[0] = [C.klima(), C.nct()];

        // Default MCO2 Swap setup
        s.swap[C.mco2()][C.usdc_bridged()].swapDexes = [0, 0];
        s.swap[C.mco2()][C.usdc_bridged()].ammRouters = [C.sushiRouter(), C.quickswapRouter()];
        s.swap[C.mco2()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima()];
        s.swap[C.mco2()][C.usdc_bridged()].swapPaths[1] = [C.klima(), C.mco2()];

        s.swap[C.mco2()][C.klima()].swapDexes = [0];
        s.swap[C.mco2()][C.klima()].ammRouters = [C.quickswapRouter()];
        s.swap[C.mco2()][C.klima()].swapPaths[0] = [C.klima(), C.mco2()];

        // Default UBO Swap setup
        s.swap[C.ubo()][C.usdc_bridged()].swapDexes = [0, 1];
        s.swap[C.ubo()][C.usdc_bridged()].ammRouters = [C.sushiRouter(), C.sushiTridentRouter()];
        s.swap[C.ubo()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima()];
        s.swap[C.ubo()][C.usdc_bridged()].swapPaths[1] = [C.klima(), C.ubo()];

        s.swap[C.ubo()][C.klima()].swapDexes = [1];
        s.swap[C.ubo()][C.klima()].ammRouters = [C.sushiTridentRouter()];
        s.swap[C.ubo()][C.klima()].swapPaths[0] = [C.klima(), C.ubo()];

        s.tridentPool[C.klima()][C.ubo()] = 0x5400A05B8B45EaF9105315B4F2e31F806AB706dE;

        // Default NBO Swap setup
        s.swap[C.nbo()][C.usdc_bridged()].swapDexes = [0, 1];
        s.swap[C.nbo()][C.usdc_bridged()].ammRouters = [C.sushiRouter(), C.sushiTridentRouter()];
        s.swap[C.nbo()][C.usdc_bridged()].swapPaths[0] = [C.usdc_bridged(), C.klima()];
        s.swap[C.nbo()][C.usdc_bridged()].swapPaths[1] = [C.klima(), C.nbo()];

        s.swap[C.nbo()][C.klima()].swapDexes = [1];
        s.swap[C.nbo()][C.klima()].ammRouters = [C.sushiTridentRouter()];
        s.swap[C.nbo()][C.klima()].swapPaths[0] = [C.klima(), C.nbo()];

        s.tridentPool[C.klima()][C.nbo()] = 0x251cA6A70cbd93Ccd7039B6b708D4cb9683c266C;

        // Staking and wrapping batch token approvals
        LibApprove.approveToken(IERC20(C.wsKlima()), C.wsKlima(), MAX_INT);
        LibApprove.approveToken(IERC20(C.sKlima()), C.wsKlima(), MAX_INT);
        LibApprove.approveToken(IERC20(C.sKlima()), C.staking(), MAX_INT);
        LibApprove.approveToken(IERC20(C.klima()), C.staking(), MAX_INT);
        LibApprove.approveToken(IERC20(C.klima()), C.stakingHelper(), MAX_INT);

        // AMM DEX Bulk approvals
        LibApprove.approveToken((IERC20(C.klima())), C.sushiBento(), MAX_INT);

        // Approve BentoBox
        IBentoBoxMinimal(C.sushiBento()).setMasterContractApproval(address(this), C.sushiTridentRouter(), true, 0, 0, 0);
    }
}
