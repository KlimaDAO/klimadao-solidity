pragma solidity ^0.8.16;

import {RetireCarbonFacet} from "../../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetirementQuoter} from "../../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../../src/infinity/libraries/LibRetire.sol";
import {LibToucanCarbon} from "../../../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import {LibTransfer} from "../../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../../src/infinity/interfaces/IToucan.sol";
import {KlimaRetirementAggregator} from "../../../../src/retirement_v1/KlimaRetirementAggregator.sol";

import "../../TestHelper.sol";
import "../../../helpers/AssertionHelper.sol";

import {console2} from "../../../../lib/forge-std/src/console2.sol";

contract RetireCarbonTrueToucanBCT is TestHelper, AssertionHelper {
    RetireCarbonFacet retireCarbonFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;
    KlimaRetirementAggregator aggregatorV1;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "KlimaDAO Retirement Aggregator";

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address aggregatorV1Address = vm.envAddress("RETIREMENT_V1_ADDRESS");
    address WSKLIMA_HOLDER = vm.envAddress("WSKLIMA_HOLDER");
    address SUSHI_LP = vm.envAddress("SUSHI_BCT_LP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address BCT;
    address DEFAULT_PROJECT;

    function setUp() public {
        addConstantsGetter(diamond);
        retireCarbonFacet = RetireCarbonFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);
        aggregatorV1 = KlimaRetirementAggregator(aggregatorV1Address);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        BCT = constantsFacet.bct();

        DEFAULT_PROJECT = IToucanPool(BCT).getScoredTCO2s()[0];

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());
    }

    function test_infinity_v1_retireCarbon_True_BCT_BCT(uint retireAmount) public {
        retireExactBCT(BCT, retireAmount);
    }

    function test_infinity_v1_retireCarbon_True_BCT_USDC(uint retireAmount) public {
        retireExactBCT(USDC, retireAmount);
    }

    function test_infinity_v1_retireCarbon_True_BCT_KLIMA(uint retireAmount) public {
        retireExactBCT(KLIMA, retireAmount);
    }

    function test_infinity_v1_retireCarbon_True_BCT_SKLIMA(uint retireAmount) public {
        retireExactBCT(SKLIMA, retireAmount);
    }

    function test_infinity_v1_retireCarbon_True_BCT_WSKLIMA(uint retireAmount) public {
        retireExactBCT(WSKLIMA, retireAmount);
    }

    function getSourceTokens(address sourceToken, uint retireAmount) internal returns (uint sourceAmount) {
        /// @dev getting trade amount on zero output will revert
        if (retireAmount == 0 && sourceToken != BCT) vm.expectRevert();

        sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, BCT, retireAmount);

        address sourceTarget;

        if (sourceToken == BCT || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(aggregatorV1Address, sourceAmount);
    }

    function retireExactBCT(address sourceToken, uint retireAmount) public {
        vm.assume(retireAmount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);
        vm.assume(retireAmount <= IERC20(DEFAULT_PROJECT).balanceOf(BCT));

        uint sourceAmount = getSourceTokens(sourceToken, retireAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        if (retireAmount == 0) {
            vm.expectRevert();

            aggregatorV1.retireCarbon(sourceToken, BCT, retireAmount, true, beneficiaryAddress, beneficiary, message);
        } else {
            // Set up expectEmit
            vm.expectEmit(true, true, true, true);

            // Emit expected CarbonRetired event
            emit LibToucanCarbon.CarbonRetired(
                LibRetire.CarbonBridge.TOUCAN,
                aggregatorV1Address,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                BCT,
                DEFAULT_PROJECT,
                retireAmount
            );

            aggregatorV1.retireCarbon(sourceToken, BCT, retireAmount, true, beneficiaryAddress, beneficiary, message);

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(sourceToken, aggregatorV1Address);
            assertZeroTokenBalance(BCT, diamond);
            assertZeroTokenBalance(BCT, aggregatorV1Address);
            assertZeroTokenBalance(DEFAULT_PROJECT, diamond);
            assertZeroTokenBalance(DEFAULT_PROJECT, aggregatorV1Address);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }
}
