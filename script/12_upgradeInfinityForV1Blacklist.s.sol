// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/infinity/interfaces/IDiamondCut.sol";
import {RetireCarbonFacet} from "../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetireSourceFacet} from "../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {console2} from "forge-std/console2.sol";
import "../test/infinity/HelperContract.sol";


contract UpgradeInfinityForV1BlacklistScript is Script, HelperContract {
    RetireCarbonFacet public retireCarbonF;
    RetireSourceFacet public retireSourceF;

    bytes public updateFacetsCalldata;

    function run() external returns (bytes memory facetsCalldata) {
        // Primary: keystore
        uint256 fallbackPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0));

        if (fallbackPrivateKey == 0) {
            vm.startBroadcast();
        } else {
            vm.startBroadcast(fallbackPrivateKey);
        }

        // Deploy updated facets
        retireCarbonF = new RetireCarbonFacet();
        retireSourceF = new RetireSourceFacet();

        vm.stopBroadcast();

        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](2);
        facetCuts[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );
        facetCuts[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireSourceF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireSourceFacet")
            })
        );

        // No storage init needed 
        updateFacetsCalldata =
            abi.encodeWithSelector(IDiamondCut.diamondCut.selector, facetCuts, address(0), "");

        console2.log("New RetireCarbonFacet Address:");
        console2.logAddress(address(retireCarbonF));
        console2.log("\nNew RetireSourceFacet Address:");
        console2.logAddress(address(retireSourceF));
        console2.log("\nFacet Update Calldata (execute via diamond owner):");
        console2.logBytes(updateFacetsCalldata);

        return updateFacetsCalldata;
    }
}
