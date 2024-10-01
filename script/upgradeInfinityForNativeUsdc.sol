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

    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");


        vm.startBroadcast(deployerPrivateKey);

        //deploy updated facets and init contract
        RetireCarbonmarkFacet retireCarbonmarkF = new RetireCarbonmarkFacet();
        // updated init contracts
        NativeUSDCInit nativeUSDCInitF = new NativeUSDCInit();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        // Klima Infinity specific facets
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonmarkF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonmarkFacet")
            })
        );

        vm.stopBroadcast();

        // usdc init calldata
        bytes memory usdcInitCalldata = abi.encodeWithSignature("init()"); 

        // update diamond paths with native usdc init
        // IDiamondCut(address(diamond)).diamondCut([], address(nativeUSDCInitF), abi.encodeWithSignature("init()"));

        // dont need selectors for diamond correct as we're just hitting the fallback anyway?

        bytes memory diamondCutCalldata = abi.encode(new IDiamondCut.FacetCut[](0), address(nativeUSDCInitF), usdcInitCalldata);

        // upgrade without init for updated retireCarbonmarkListing implementation
        // IDiamondCut(diamond).diamondCut(cut, address(0), "");

        bytes memory addNewRetireCarbonmarkFacetCalldata = abi.encodeWithSelector(IDiamondCut.diamondCut.selector, cut, address(0), "");

        
        console2.log("usdcInitCalldata");
        console2.logBytes(usdcInitCalldata);
        console2.log("init address");
        console2.log(address(nativeUSDCInitF));
        console2.log("diamondCutCalldata");
        console2.logBytes(diamondCutCalldata);
        console2.log("addNewRetireCarbonmarkFacetCalldata");
        console2.logBytes(addNewRetireCarbonmarkFacetCalldata);



    }
}
