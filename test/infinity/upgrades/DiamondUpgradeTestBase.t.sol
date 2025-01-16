// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/infinity/interfaces/IDiamondCut.sol";
import "../../../src/infinity/facets/DiamondLoupeFacet.sol";
import {ConstantsGetter} from "../../../src/infinity/mocks/ConstantsGetter.sol";
import "../TestHelper.sol";

contract DiamondUpgradeTestBase is Test, TestHelper {
    address diamond;
    address multisig;

    function setUpDiamond() internal {
        diamond = payable(vm.envAddress("INFINITY_ADDRESS"));
        multisig = vm.envAddress("CONTRACT_MULTISIG");

        addConstantsGetter(diamond);
    }

    function verifyFacetReplacement(address expectedFacetAddress, bytes4 selector, string memory errorMessage)
        internal
    {
        DiamondLoupeFacet loupe = DiamondLoupeFacet(diamond);
        address actualFacetAddress = loupe.facetAddress(selector);
        assertEq(actualFacetAddress, expectedFacetAddress, errorMessage);
    }

    // pure utils

    function verifyFacetsDeployment(address[] memory deployedFacets) internal pure {
        for (uint256 i = 0; i < deployedFacets.length; i++) {
            require(deployedFacets[i] != address(0), "Facet not deployed");
        }
    }

    function contains(bytes4[] memory array, bytes4 element) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }
        return false;
    }
}
