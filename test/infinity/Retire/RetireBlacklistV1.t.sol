pragma solidity ^0.8.16;

import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetireSourceFacet} from "../../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {C} from "../../../src/infinity/C.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";


contract RetireBlacklistV1Test is TestHelper, AssertionHelper {
    RetireCarbonFacet retireCarbonFacet;
    RetireSourceFacet retireSourceFacet;
    ConstantsGetter constantsFacet;

    string constant BLACKLIST_REVERT = "Caller is blacklisted";
    string constant ZERO_REVERT = "Cannot retire zero tonnes";

    // Retirement details
    string entity = "Test Entity";
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");

    // The deprecated v1 aggregator that must be blocked
    address V1_AGGREGATOR = C.retirementV1Aggregator();

    address BCT;
    address DEFAULT_PROJECT_BCT;

    function setUp() public {
        addConstantsGetter(diamond);
        upgradeCurrentDiamond(diamond); // replaces RetireCarbonFacet (carries the modifier)
        replaceRetireSourceFacet(diamond); // replaces RetireSourceFacet (carries the modifier)

        retireCarbonFacet = RetireCarbonFacet(diamond);
        retireSourceFacet = RetireSourceFacet(diamond);
        constantsFacet = ConstantsGetter(diamond);

        BCT = constantsFacet.bct();
        DEFAULT_PROJECT_BCT = getDefaultToucanProject(BCT);
    }

    /// @dev The v1 aggregator constant should match the deprecated aggregator address.
    function test_infinity_blacklist_v1AggregatorAddress() public {
        assertEq(V1_AGGREGATOR, 0xEde3bd57a04960E6469B70B4863cE1c9d9363Cb8);
    }

    /* ========== v1 calls must revert ========== */

    function test_infinity_blacklist_retireExactCarbonDefault_reverts() public {
        vm.prank(V1_AGGREGATOR);
        vm.expectRevert(bytes(BLACKLIST_REVERT));
        retireCarbonFacet.retireExactCarbonDefault(
            BCT, BCT, 1e18, 1e18, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL
        );
    }

    function test_infinity_blacklist_retireExactCarbonSpecific_reverts() public {
        vm.prank(V1_AGGREGATOR);
        vm.expectRevert(bytes(BLACKLIST_REVERT));
        retireCarbonFacet.retireExactCarbonSpecific(
            BCT,
            BCT,
            DEFAULT_PROJECT_BCT,
            1e18,
            1e18,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );
    }

    function test_infinity_blacklist_retireExactSourceDefault_reverts() public {
        vm.prank(V1_AGGREGATOR);
        vm.expectRevert(bytes(BLACKLIST_REVERT));
        retireSourceFacet.retireExactSourceDefault(
            BCT, BCT, 1e18, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL
        );
    }

    function test_infinity_blacklist_retireExactSourceSpecific_reverts() public {
        vm.prank(V1_AGGREGATOR);
        vm.expectRevert(bytes(BLACKLIST_REVERT));
        retireSourceFacet.retireExactSourceSpecific(
            BCT,
            BCT,
            DEFAULT_PROJECT_BCT,
            1e18,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );
    }

    /* ========== Non-v1 callers still pass the modifier ========== */
    // A non-blacklisted caller sailing past the modifier hits the zero-amount guard
    // in the function body instead, proving the modifier does not block normal callers.

    function test_infinity_blacklist_allowsNonV1_retireExactCarbonDefault() public {
        vm.prank(makeAddr("normalUser"));
        vm.expectRevert(bytes(ZERO_REVERT));
        retireCarbonFacet.retireExactCarbonDefault(
            BCT, BCT, 0, 0, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL
        );
    }

    function test_infinity_blacklist_allowsNonV1_retireExactSourceDefault() public {
        vm.prank(makeAddr("normalUser"));
        vm.expectRevert(bytes(ZERO_REVERT));
        retireSourceFacet.retireExactSourceDefault(
            BCT, BCT, 0, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL
        );
    }

    /* ========== Facet upgrade helper ========== */

    function replaceRetireSourceFacet(address infinityDiamond) internal {
        OwnershipFacet ownership = OwnershipFacet(infinityDiamond);
        vm.startPrank(ownership.owner());

        RetireSourceFacet newSourceFacet = new RetireSourceFacet();

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(newSourceFacet),
            action: IDiamondCut.FacetCutAction.Replace,
            functionSelectors: generateSelectors("RetireSourceFacet")
        });

        IDiamondCut(infinityDiamond).diamondCut(cut, address(0), "");
        vm.stopPrank();
    }
}
