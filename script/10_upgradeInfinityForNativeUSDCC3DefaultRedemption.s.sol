// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import "../src/infinity/facets/DiamondCutFacet.sol";
import "../src/infinity/facets/DiamondLoupeFacet.sol";
import "../src/infinity/facets/OwnershipFacet.sol";
import {RedeemC3PoolFacet} from "../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";

import "../test/infinity/HelperContract.sol";

contract UpgradeInfinityForNativeUSDCC3DefaultRedemption is Script, HelperContract {
    function run() external returns (bytes memory) {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");
        bytes memory updateFacetCalldata;

        vm.startBroadcast(deployerPrivateKey);

        //deploy updated facets and init contract
        RedeemC3PoolFacet redeemC3PoolF = new RedeemC3PoolFacet();

        // FacetCut array which contains the facet to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        // Klima Infinity specific facets
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(redeemC3PoolF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemC3PoolFacet")
            })
        );

        vm.stopBroadcast();

        // get calldata for the upgrade without init for internal library function view
        updateFacetCalldata = abi.encodeWithSelector(IDiamondCut.diamondCut.selector, cut, address(0), "");

        console2.log("New redeemC3PoolF address");
        console2.logAddress(address(redeemC3PoolF));

        console2.log("diamondCut calldata");
        console2.logBytes(updateFacetCalldata);

        return updateFacetCalldata;
    }
}
