// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import "../src/infinity/facets/DiamondCutFacet.sol";
import "../src/infinity/facets/DiamondLoupeFacet.sol";
import "../src/infinity/facets/OwnershipFacet.sol";
import { RetireCarbonmarkFacet } from "../src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";
import { RetireCMARKFacet } from "../src/infinity/facets/Bridges/CMARK/RetireCMARKFacet.sol";

import "../test/infinity/HelperContract.sol";

contract UpgradeInfinityForCMARK is Script, HelperContract {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");
        bytes updateFacetsCalldata;

        OwnershipFacet ownerF = OwnershipFacet(diamond);

        vm.startBroadcast(deployerPrivateKey);

        //deploy updated facets and init contract
        RetireCarbonmarkFacet retireCarbonmarkF = new RetireCarbonmarkFacet();
        RetireCMARKFacet retireCMARKF = new RetireCMARKFacet();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](2);

        // Klima Infinity specific facets
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonmarkF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonmarkFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCMARKF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireCMARKFacet")
            })
        );

        vm.stopBroadcast();

        // get calldata for the upgrade without init for interal library function view
        updateFacetsCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            cut,
            address(0),
            ""
        );

        console2.log("New retireCarbonmarkF address");
        console2.logAddress(address(retireCarbonmarkF));

        console2.log("New retireCMARKF address");
        console2.logAddress(address(retireCMARKF));

        console2.log("Updated Retire Carbonmark Facet Calldata");
        console2.logBytes(updateFacetsCalldata);

        return updateFacetsCalldata;

    }
}
