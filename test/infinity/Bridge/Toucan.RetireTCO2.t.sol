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
        uint256 retiredAmount
    );

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

    RetireToucanTCO2Facet retireToucanTCO2Facet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    uint256 defaultCarbonRetireAmount = 69 * 1e18;
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");

    // Addresses pulled from current diamond constants
    address BCT;
    address DEFAULT_PROJECT;
    address PURO_PROJECT = 0x42F37CD772E3Dd2686a34f7BbbBaC710f497920a;
    uint256 PURO_TOKEN_ID = 1715;

    function setUp() public {
        addConstantsGetter(diamond);
        upgradeCurrentDiamond(diamond);
        constantsFacet = ConstantsGetter(diamond);
        retireToucanTCO2Facet = RetireToucanTCO2Facet(diamond);
        quoterFacet = RetirementQuoter(diamond);

        BCT = constantsFacet.bct();
        DEFAULT_PROJECT = IToucanPool(BCT).getScoredTCO2s()[0];
    }

    function test_infinity_toucanRetireExactTCO2() public {
        address sourceToken = DEFAULT_PROJECT;
        address carbonToken = DEFAULT_PROJECT;
        swipeERC20Tokens(DEFAULT_PROJECT, defaultCarbonRetireAmount, BCT, address(this));
        IERC20(sourceToken).approve(diamond, defaultCarbonRetireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint256 expectedRetirements = currentRetirements + 1;
        uint256 expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

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

        uint256 retirementIndex = retireToucanTCO2Facet.toucanRetireExactTCO2(
            carbonToken, defaultCarbonRetireAmount, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        assertZeroTokenBalance(carbonToken, diamond);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(retirementIndex, expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_infinity_toucanRetireExactTCO2WithEntity() public {
        address sourceToken = DEFAULT_PROJECT;
        address carbonToken = DEFAULT_PROJECT;
        swipeERC20Tokens(DEFAULT_PROJECT, defaultCarbonRetireAmount, BCT, address(this));
        IERC20(sourceToken).approve(diamond, defaultCarbonRetireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint256 expectedRetirements = currentRetirements + 1;
        uint256 expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

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

        uint256 retirementIndex = retireToucanTCO2Facet.toucanRetireExactTCO2WithEntity(
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

    function test_infinity_toucanRetirePuroTCO2() public {
        address sourceToken = PURO_PROJECT;
        address carbonToken = PURO_PROJECT;
        defaultCarbonRetireAmount = 5e18;

        swipeERC20Tokens(
            PURO_PROJECT, defaultCarbonRetireAmount, 0x46f1430f5B7224699F0A2E33584Be6517c7bc9A0, address(this)
        );
        IERC20(sourceToken).approve(diamond, defaultCarbonRetireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint256 expectedRetirements = currentRetirements + 1;
        uint256 expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

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
            PURO_PROJECT,
            PURO_TOKEN_ID,
            defaultCarbonRetireAmount
        );

        uint256 retirementIndex = retireToucanTCO2Facet.toucanRetireExactPuroTCO2(
            carbonToken,
            PURO_TOKEN_ID,
            defaultCarbonRetireAmount,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        assertZeroTokenBalance(carbonToken, diamond);
        assertZeroTokenBalance(PURO_PROJECT, diamond);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(retirementIndex, expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }
}
