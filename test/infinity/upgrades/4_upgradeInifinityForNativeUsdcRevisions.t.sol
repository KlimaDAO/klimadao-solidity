// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../script/4_upgradeInifinityForNativeUSDCRevisions.s.sol"; // Updated script path
import "../../../src/infinity/interfaces/IDiamondCut.sol";
import "../../../src/infinity/facets/DiamondCutFacet.sol";
import "../../../src/infinity/facets/DiamondLoupeFacet.sol";
import "../../../src/infinity/libraries/LibAppStorage.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RedeemC3PoolFacet} from "../../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RedeemToucanPoolFacet} from "../../../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {C} from "../../../src/infinity/C.sol";
import {LibDiamond} from "../../../src/infinity/libraries/LibDiamond.sol";
import {OwnershipFacet} from "../../../src/infinity/facets/OwnershipFacet.sol";
import {ConstantsGetter} from "../../../src/infinity/mocks/ConstantsGetter.sol";
import "../TestHelper.sol";

contract UpgradeInfinityForNativeUsdcRevisionsTest is TestHelper {
    UpgradeInfinityForNativeUsdcRevisions upgradeScript;
    address diamond;
    address carbonmark;
    uint256 deployerPrivateKey;
    uint256 polygonFork;

    address payable INFINITY_ADDRESS;
    address multisig;

    ConstantsGetter constantsFacet;

    AppStorage s;

    function contains(bytes4[] memory array, bytes4 element) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }
        return false;
    }

    function setUp() public {
        upgradeScript = new UpgradeInfinityForNativeUsdcRevisions();
        diamond = address(0x1234567890123456789012345678901234567890);
        deployerPrivateKey = 0xabc123;

        // Set up environment variables
        INFINITY_ADDRESS = payable(vm.envAddress("INFINITY_ADDRESS"));
        multisig = vm.envAddress("CONTRACT_MULTISIG");

        addConstantsGetter(INFINITY_ADDRESS);
        constantsFacet = ConstantsGetter(INFINITY_ADDRESS);
        carbonmark = constantsFacet.carbonmark();
    }


    function testFacetsDeployments() public {
        upgradeScript.run();

        assertTrue(address(upgradeScript.c3RedeemF()) != address(0), "RedeemC3PoolFacet not deployed");
        assertTrue(address(upgradeScript.toucanRedeemF()) != address(0), "RedeemToucanPoolFacet not deployed");
        assertTrue(address(upgradeScript.retirementQuoterF()) != address(0), "RetirementQuoter not deployed");
        assertTrue(address(upgradeScript.retireCarbonF()) != address(0), "RetireCarbonFacet not deployed");
    }

    function testReplacingFacetsOnDiamond() public {
        upgradeScript.run();

        IDiamondCut.FacetCut[] memory cuts = upgradeScript.getCuts();

        vm.prank(multisig);
        IDiamondCut(INFINITY_ADDRESS).diamondCut(cuts, address(0), "");


        // After the diamond cut, verify the facets are replaced correctly
        DiamondLoupeFacet loupe = DiamondLoupeFacet(INFINITY_ADDRESS);


        {
            bytes4 selector = RetirementQuoter.getSourceAmountSpecificRetirement.selector;
            address quoterFacetAddress = loupe.facetAddress(selector);
            assertEq(quoterFacetAddress, address(upgradeScript.retirementQuoterF()), "RetirementQuoter facet not replaced correctly");
        }

        {
            // Check a known selector
            bytes4 selector = RetireCarbonFacet.retireExactCarbonSpecific.selector;
            address retireCarbonFacetAddress = loupe.facetAddress(selector);
            assertEq(retireCarbonFacetAddress, address(upgradeScript.retireCarbonF()), "RetireCarbonFacet not replaced correctly");
        }

        {
            // Check a known selector
            bytes4 selector = RedeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific.selector;
            address toucanRedeemFacetAddress = loupe.facetAddress(selector);
            assertEq(toucanRedeemFacetAddress, address(upgradeScript.toucanRedeemF()), "RedeemToucanPoolFacet not replaced correctly");
        }

        {
            // Check a known selector
            bytes4 selector = RedeemC3PoolFacet.c3RedeemPoolSpecific.selector;
            address c3RedeemFacetAddress = loupe.facetAddress(selector);
            assertEq(c3RedeemFacetAddress, address(upgradeScript.c3RedeemF()), "RedeemC3PoolFacet not replaced correctly");
        }
    }
}
