pragma solidity ^0.8.16;

import "../HelperContract.sol";
import {RetireC3C3TFacet} from "../../../src/infinity/facets/Bridges/C3/RetireC3C3TFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {IC3Pool} from "../../../src/infinity/interfaces/IC3.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

contract RetireC3C3TFacetTest is TestHelper, AssertionHelper {
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

    RetireC3C3TFacet retireC3C3TFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    uint defaultCarbonRetireAmount = 69 * 1e18;
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");

    // Addresses pulled from current diamond constants
    address UBO;
    address DEFAULT_PROJECT;

    function setUp() public {
        addConstantsGetter(diamond);
        constantsFacet = ConstantsGetter(diamond);
        retireC3C3TFacet = RetireC3C3TFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);

        UBO = constantsFacet.ubo();
        DEFAULT_PROJECT = IC3Pool(UBO).getFreeRedeemAddresses()[0];
    }

    function test_c3RetireExactC3T() public {
        address sourceToken = DEFAULT_PROJECT;
        address carbonToken = DEFAULT_PROJECT;
        swipeERC20Tokens(DEFAULT_PROJECT, defaultCarbonRetireAmount, UBO, address(this));
        IERC20(sourceToken).approve(diamond, defaultCarbonRetireAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            "KlimaDAO Retirement Aggregator",
            beneficiaryAddress,
            beneficiary,
            message,
            address(0),
            DEFAULT_PROJECT,
            defaultCarbonRetireAmount
        );

        uint retirementIndex = retireC3C3TFacet.c3RetireExactC3T(
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

    function test_c3RetireExactC3TWithEntity() public {
        address sourceToken = DEFAULT_PROJECT;
        address carbonToken = DEFAULT_PROJECT;
        swipeERC20Tokens(DEFAULT_PROJECT, defaultCarbonRetireAmount, UBO, address(this));
        IERC20(sourceToken).approve(diamond, defaultCarbonRetireAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            address(0),
            DEFAULT_PROJECT,
            defaultCarbonRetireAmount
        );

        uint retirementIndex = retireC3C3TFacet.c3RetireExactC3TWithEntity(
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
