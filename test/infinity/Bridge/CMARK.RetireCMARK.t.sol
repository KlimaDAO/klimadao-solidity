pragma solidity ^0.8.16;

import "../HelperContract.sol";
import {RetireCMARKFacet} from "../../../src/infinity/facets/Bridges/CMARK/RetireCMARKFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IERC20} from "oz/token/ERC20/IERC20.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

contract RetireCMARKFacetTest is TestHelper, AssertionHelper {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint256 tokenId,
        uint256 retiredAmount
    );

    RetireCMARKFacet retireCMARKFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    uint256 defaultCarbonRetireAmount = 5 * 1e18;
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";
    string consumptionCountryCode = "US";

    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");

    address CMARK = 0x103A806A88199ED11f16f1ECc7aC40fEFE12feb5;

    function setUp() public {
        addConstantsGetter(diamond);
        constantsFacet = ConstantsGetter(diamond);
        retireCMARKFacet = RetireCMARKFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);

        upgradeCurrentDiamond(diamond);
    }

    function test_infinity_cmarkRetireExactCarbon() public {
        uint256 tokenId = 1; // TODO: decide how to set this
        uint256 retireAmount = 100e18;
        swipeERC20Tokens(CMARK, defaultCarbonRetireAmount, CMARK, address(this));
        IERC20(CMARK).approve(diamond, defaultCarbonRetireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint256 expectedRetirements = currentRetirements + 1;
        uint256 expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.CMARK,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            address(0),
            CMARK,
            tokenId,
            defaultCarbonRetireAmount
        );

        LibRetire.RetireDetails memory details = LibRetire.RetireDetails({
            retiringAddress: address(this),
            retiringEntityString: entity,
            beneficiaryAddress: beneficiaryAddress,
            beneficiaryString: beneficiary,
            retirementMessage: message,
            beneficiaryLocation: "",
            consumptionCountryCode: "DE",
            consumptionPeriodStart: 0,
            consumptionPeriodEnd: 0
        });

        uint256 retirementIndex = retireCMARKFacet.cmarkRetireExactCarbon(
            CMARK,
            defaultCarbonRetireAmount,
            details,
            LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        // assertZeroTokenBalance(carbonToken, diamond);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(retirementIndex, expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }
}
