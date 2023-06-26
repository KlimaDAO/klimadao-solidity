// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Authors: Cujo <rawr@cujowolf.dev>
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535

* Script to upgrade Infinity diamond with new and revised facets
/******************************************************************************/

import "forge-std/Script.sol";
import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import "../src/infinity/facets/DiamondCutFacet.sol";
import "../src/infinity/facets/DiamondLoupeFacet.sol";
import "../src/infinity/facets/OwnershipFacet.sol";
import {RedeemC3PoolFacet} from "../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RetireC3C3TFacet} from "../src/infinity/facets/Bridges/C3/RetireC3C3TFacet.sol";
import {RedeemToucanPoolFacet} from "../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RetireToucanTCO2Facet} from "../src/infinity/facets/Bridges/Toucan/RetireToucanTCO2Facet.sol";
import {RetireCarbonFacet} from "../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetireInfoFacet} from "../src/infinity/facets/Retire/RetireInfoFacet.sol";
import {RetireSourceFacet} from "../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../src/infinity/facets/RetirementQuoter.sol";
import {DiamondInit} from "../src/infinity/init/DiamondInit.sol";
import "../test/infinity/HelperContract.sol";

contract DeployInfinityScript is Script, HelperContract {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        //deploy facets and init contract
        RedeemC3PoolFacet c3RedeemF = new RedeemC3PoolFacet();
        RetireC3C3TFacet c3RetireF = new RetireC3C3TFacet();
        RedeemToucanPoolFacet toucanRedeemF = new RedeemToucanPoolFacet();
        RetireToucanTCO2Facet toucanRetireF = new RetireToucanTCO2Facet();
        RetireCarbonFacet retireCarbonF = new RetireCarbonFacet();
        RetireSourceFacet retireSourceF = new RetireSourceFacet();
        RetirementQuoter retirementQuoterF = new RetirementQuoter();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](7);

        // Klima Infinity specific facets

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(c3RedeemF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemC3PoolFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(c3RetireF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireC3C3TFacet")
            })
        );

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(toucanRedeemF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemToucanPoolFacet")
            })
        );

        cut[3] = (
            IDiamondCut.FacetCut({
                facetAddress: address(toucanRetireF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireToucanTCO2Facet")
            })
        );

        cut[4] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cut[5] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireSourceF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireSourceFacet")
            })
        );

        cut[6] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retirementQuoterF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );

        // deploy diamond and perform diamondCut
        IDiamondCut(diamond).diamondCut(cut, address(0), "");

        vm.stopBroadcast();
    }
}
