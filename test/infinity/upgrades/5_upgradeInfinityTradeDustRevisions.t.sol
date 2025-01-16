// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../script/5_upgradeInfinityTradeDustRevisions.s.sol"; // Updated script path
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
import {DiamondUpgradeTestBase} from "./DiamondUpgradeTestBase.t.sol";
import "../TestHelper.sol";

contract UpgradeInfinityForTradeDustRevisionsTest is TestHelper, DiamondUpgradeTestBase {
    UpgradeInfinityForTradeDustRevisions upgradeScript;
    uint256 deployerPrivateKey;
    uint256 polygonFork;

    AppStorage s;

    function setUp() public {
        upgradeScript = new UpgradeInfinityForTradeDustRevisions();
        deployerPrivateKey = 0xabc123;
        setUpDiamond();
    }

    function testFacetsDeployments() public {
        upgradeScript.run();

        verifyFacetsDeployment(upgradeScript.getFacets());
    }

    function testReplacingFacetsOnDiamond() public {
        upgradeScript.run();

        IDiamondCut.FacetCut[] memory cuts = upgradeScript.getCuts();

        vm.prank(multisig);
        IDiamondCut(diamond).diamondCut(cuts, address(0), "");

        verifyFacetReplacement(
            address(upgradeScript.retireCarbonF()),
            RetireCarbonFacet.retireExactCarbonSpecific.selector,
            "RetireCarbonFacet not replaced correctly"
        );
        verifyFacetReplacement(
            address(upgradeScript.c3RedeemF()),
            RedeemC3PoolFacet.c3RedeemPoolSpecific.selector,
            "RedeemC3PoolFacet not replaced correctly"
        );
        verifyFacetReplacement(
            address(upgradeScript.toucanRedeemF()),
            RedeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific.selector,
            "RedeemToucanPoolFacet not replaced correctly"
        );
    }
}
