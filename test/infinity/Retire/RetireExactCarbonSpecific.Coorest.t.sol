pragma solidity ^0.8.16;

import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibCoorestCarbon} from "../../../src/infinity/libraries/Bridges/LibCoorestCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {OwnershipFacet} from "../../../src/infinity/facets/OwnershipFacet.sol";
import {DiamondInitCoorest} from "../../../src/infinity/init/DiamondInitCoorest.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";
import {IERC721} from "../../../lib/forge-std/src/interfaces/IERC721.sol";
import {StdUtils} from "../../../lib/forge-std/src/StdUtils.sol";

contract RetireExactCarbonSpecificCoorest is TestHelper, AssertionHelper {
    RetireCarbonFacet retireCarbonFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address SUSHI_LP = vm.envAddress("SUSHI_CCO2_LP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address USDC;
    address KLIMA_TOKEN;
    address CCO2;

    function setUp() public {
        addConstantsGetter(diamond);
        upgradeCurrentDiamond(diamond);

        retireCarbonFacet = RetireCarbonFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        KLIMA_TOKEN = constantsFacet.klima();
        USDC = constantsFacet.usdc();
        CCO2 = constantsFacet.coorestCCO2Token();

        // Mock Balance from StdUtils
        deal(constantsFacet.usdc(), beneficiaryAddress, 100_000e6);
        deal(constantsFacet.klima(), beneficiaryAddress, 100_000e9);

        // Uncomment if there's dust sitting in the treasury.
        sendDustToTreasury(diamond);
    }

    function test_infinity_retireExactCarbonSpecific_CCO2_USDC() public {
        uint preTxBalance = IERC20(KLIMA_TOKEN).balanceOf(beneficiaryAddress);
        uint preTxPoCCBalance = IERC721(constantsFacet.coorestPoCCToken()).balanceOf(beneficiaryAddress);

        uint sourceAmount = retireExactCCO2(KLIMA_TOKEN, 100e18);
        uint postTxBalance = IERC20(KLIMA_TOKEN).balanceOf(beneficiaryAddress);
        uint postTxPoCCBalance = IERC721(constantsFacet.coorestPoCCToken()).balanceOf(beneficiaryAddress);

        assertEq(preTxBalance - postTxBalance, sourceAmount);
        assertEq(postTxPoCCBalance - preTxPoCCBalance, 1);
    }

    function test_infinity_retireExactCarbonSpecific_CCO2_Klima() public {
        uint preTxBalance = IERC20(KLIMA_TOKEN).balanceOf(beneficiaryAddress);
        uint preTxPoCCBalance = IERC721(constantsFacet.coorestPoCCToken()).balanceOf(beneficiaryAddress);

        uint sourceAmount = retireExactCCO2(KLIMA_TOKEN, 100e18); // CCO2 1M

        uint postTxBalance = IERC20(KLIMA_TOKEN).balanceOf(beneficiaryAddress);
        uint postTxPoCCBalance = IERC721(constantsFacet.coorestPoCCToken()).balanceOf(beneficiaryAddress);

        assertEq(preTxBalance - postTxBalance, sourceAmount);
        assertEq(postTxPoCCBalance - preTxPoCCBalance, 1);
    }

    function getSourceTokens(address sourceToken, uint retireAmount) internal returns (uint sourceAmount) {
        sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, CCO2, retireAmount); // retireAmount => Amount of CCO2 to retire.

        address sourceTarget;

        if (sourceToken == USDC || sourceToken == KLIMA_TOKEN) sourceTarget = beneficiaryAddress;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function retireExactCCO2Base(
        address sourceToken,
        uint retireAmount
    ) public returns (uint sourceAmount, uint retirementIndex) {
        sourceAmount = getSourceTokens(sourceToken, retireAmount);

        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit LibCoorestCarbon.CarbonRetired(
            LibRetire.CarbonBridge.COOREST,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            CCO2,
            address(0),
            retireAmount
        );

        retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(
            sourceToken,
            CCO2,
            CCO2,
            sourceAmount,
            retireAmount,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );
    }

    function retireExactCCO2(address sourceToken, uint retireAmount) public returns (uint) {
        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        (uint sourceAmount, uint retirementIndex) = retireExactCCO2Base(sourceToken, retireAmount);
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

        // No tokens left in contract
        assertZeroTokenBalance(sourceToken, diamond);
        assertZeroTokenBalance(CCO2, diamond);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);

        return sourceAmount;
    }
}
