pragma solidity ^0.8.16;

import "../HelperContract.sol";
import {RetireToucanTCO2Facet} from "../../../src/infinity/facets/Bridges/Toucan/RetireToucanTCO2Facet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

contract RetireToucanTCO2FacetTest is TestHelper, AssertionHelper {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint retiredAmount
    );

    RetireToucanTCO2Facet retireToucanTCO2Facet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    uint defaultCarbonRetireAmount = 69 * 1e18;
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");

    // Addresses pulled from current diamond constants
    address BCT;
    address DEFAULT_PROJECT;

    function setUp() public {
        addConstantsGetter(diamond);
        constantsFacet = ConstantsGetter(diamond);
        retireToucanTCO2Facet = RetireToucanTCO2Facet(diamond);
        quoterFacet = RetirementQuoter(diamond);

        BCT = constantsFacet.bct();
        DEFAULT_PROJECT = IToucanPool(BCT).getScoredTCO2s()[0];
    }

    function test_toucanRetireExactTCO2() public {
        address sourceToken = DEFAULT_PROJECT;
        address carbonToken = DEFAULT_PROJECT;
        swipeERC20Tokens(DEFAULT_PROJECT, defaultCarbonRetireAmount, BCT, address(this));
        IERC20(sourceToken).approve(diamond, defaultCarbonRetireAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.TOUCAN,
            address(this),
            "KlimaDAO Retirement Aggregator",
            beneficiaryAddress,
            beneficiary,
            message,
            address(0),
            DEFAULT_PROJECT,
            defaultCarbonRetireAmount
        );

        uint retirementIndex = retireToucanTCO2Facet.toucanRetireExactTCO2(
            carbonToken,
            defaultCarbonRetireAmount,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        assertZeroTokenBalance(carbonToken, diamond);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(retirementIndex, expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_toucanRetireExactTCO2WithEntity() public {
        address sourceToken = DEFAULT_PROJECT;
        address carbonToken = DEFAULT_PROJECT;
        swipeERC20Tokens(DEFAULT_PROJECT, defaultCarbonRetireAmount, BCT, address(this));
        IERC20(sourceToken).approve(diamond, defaultCarbonRetireAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.TOUCAN,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            address(0),
            DEFAULT_PROJECT,
            defaultCarbonRetireAmount
        );

        uint retirementIndex = retireToucanTCO2Facet.toucanRetireExactTCO2WithEntity(
            carbonToken,
            defaultCarbonRetireAmount,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        assertZeroTokenBalance(carbonToken, diamond);
        assertZeroTokenBalance(DEFAULT_PROJECT, diamond);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(retirementIndex, expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }
}
