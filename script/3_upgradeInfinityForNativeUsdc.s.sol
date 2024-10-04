// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import "../src/infinity/facets/DiamondCutFacet.sol";
import "../src/infinity/facets/DiamondLoupeFacet.sol";
import {RetireCarbonmarkFacet} from "../src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";
import {NativeUSDCInit} from "../src/infinity/init/NativeUSDCInit.sol";

import {console2} from "forge-std/console2.sol";

import "../test/infinity/HelperContract.sol";

contract UpgradeInfinityForNativeUsdc is Script, HelperContract {
    RetireCarbonmarkFacet public retireCarbonmarkF;
    NativeUSDCInit public nativeUSDCInitF;
    IDiamondCut.FacetCut[] public cuts;

    bytes public usdcInitCalldata;
    bytes public updateSwapPathsCalldata;
    bytes public addNewRetireCarbonmarkFacetCalldata;

    function getCuts() public view returns (IDiamondCut.FacetCut[] memory) {
        return cuts;
    }

    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy updated Retire CM Facet
        retireCarbonmarkF = new RetireCarbonmarkFacet();

        // Deployed swap routes update init contract
        nativeUSDCInitF = new NativeUSDCInit();

        vm.stopBroadcast();

        // Given, all the following updates to the Klima Infinity will be
        // processed by a multiple, when we generate the calldata that will
        // be plugged to the safeSDK to propose multi-sign txn.

        // FacetCut array which contains the standard facet to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        // Klima Infinity specific facets
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonmarkF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonmarkFacet")
            })
        );

        cuts.push(cut[0]);

        updateSwapPathsCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            new IDiamondCut.FacetCut[](0),
            address(nativeUSDCInitF),
            abi.encodeWithSignature("init()")
        );

        console2.log("Update Swap Paths Call Data");
        console2.logBytes(updateSwapPathsCalldata);

        addNewRetireCarbonmarkFacetCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            cut,
            address(0),
            ""
        );

        console2.log("Updated Retire Carbonmark Facet Call Data");
        console2.logBytes(addNewRetireCarbonmarkFacetCalldata);
    }

    function run_test() external {
        address owner = vm.envAddress("INFINITY_OWNER_ADDRESS");
        address diamond = vm.envAddress("INFINITY_ADDRESS");

        // Deploy updated Retire CM Facet
        retireCarbonmarkF = new RetireCarbonmarkFacet();

        // Deployed swap routes update init contract
        nativeUSDCInitF = new NativeUSDCInit();

        // Given, all the following updates to the Klima Infinity will be
        // processed by a multiple, when we generate the calldata that will
        // be plugged to the safeSDK to propose multi-sign txn.

        // FacetCut array which contains the standard facet to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        // Klima Infinity specific facets
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonmarkF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonmarkFacet")
            })
        );

        cuts.push(cut[0]);

        updateSwapPathsCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            new IDiamondCut.FacetCut[](0),
            address(nativeUSDCInitF),
            abi.encodeWithSignature("init()")
        );

        address(diamond).call(updateSwapPathsCalldata);

        console2.log("Update Swap Paths Call Data");
        console2.logBytes(updateSwapPathsCalldata);

        addNewRetireCarbonmarkFacetCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            cut,
            address(0),
            ""
        );

        console2.log("Updated Retire Carbonmark Facet Call Data");
        console2.logBytes(addNewRetireCarbonmarkFacetCalldata);

        address(diamond).call(addNewRetireCarbonmarkFacetCalldata);
    }
}
