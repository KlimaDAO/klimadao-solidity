// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import "../src/infinity/facets/DiamondCutFacet.sol";
import "../src/infinity/facets/DiamondLoupeFacet.sol";
import "../src/infinity/facets/OwnershipFacet.sol";
import { BatchCallFacet } from "../src/infinity/facets/Retire/BatchCallFacet.sol";

import "../test/infinity/HelperContract.sol";

contract UpgradeInfinityForBatchCall is Script, HelperContract {
    function run() external returns (bytes memory) {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");
        bytes memory updateFacetsCalldata;

        vm.startBroadcast(deployerPrivateKey);

        //deploy updated facets and init contract
        BatchCallFacet batchCallF = new BatchCallFacet();

        // FacetCut array which contains the facet to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        // Klima Infinity specific facets
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(batchCallF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("BatchCallFacet")
            })
        );
        
        vm.stopBroadcast();

        // get calldata for the upgrade without init for internal library function view
        updateFacetsCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            cut,
            address(0),
            ""
        );

        console2.log("New batchCallF address");
        console2.logAddress(address(batchCallF));

        console2.log("diamondCut calldata");
        console2.logBytes(updateFacetsCalldata);

        return updateFacetsCalldata;

    }
}
