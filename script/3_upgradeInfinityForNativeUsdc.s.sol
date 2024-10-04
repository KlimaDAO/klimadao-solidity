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

        // deploy updated facet
        retireCarbonmarkF = new RetireCarbonmarkFacet();

        // updated init contracts
        nativeUSDCInitF = new NativeUSDCInit();

        vm.stopBroadcast();

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
            usdcInitCalldataabi.encodeWithSignature("init()")
        );

        console2.log("Update Swap Paths Call Data");
        console2.log(updateSwapPathsCalldata);

        addNewRetireCarbonmarkFacetCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            cut,
            address(0),
            ""
        );

        console2.log("Updated Retire Carbonmark Facet Call Data");
        console2.log(addNewRetireCarbonmarkFacetCalldata);
    }
}
