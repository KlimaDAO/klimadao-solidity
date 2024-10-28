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

contract RetireCarbonSpecificTrueToucanBCT is TestHelper, AssertionHelper {
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
    address[] projects;

    function setUp() public {
        addConstantsGetter(diamond);
        retireCarbonFacet = RetireCarbonFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);
        aggregatorV1 = KlimaRetirementAggregator(aggregatorV1Address);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc_bridged();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        BCT = constantsFacet.bct();

        projects = IToucanPool(BCT).getScoredTCO2s();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_v1_retireCarbonSpecific_True_BCT_BCT(uint256 retireAmount) public {
        retireExactBCT(BCT, retireAmount);
        retireExactBCTWithEntity(BCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_True_BCT_USDC(uint256 retireAmount) public {
        retireExactBCT(USDC, retireAmount);
        retireExactBCTWithEntity(USDC, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_True_BCT_KLIMA(uint256 retireAmount) public {
        retireExactBCT(KLIMA, retireAmount);
        retireExactBCTWithEntity(KLIMA, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_True_BCT_SKLIMA(uint256 retireAmount) public {
        retireExactBCT(SKLIMA, retireAmount);
        retireExactBCTWithEntity(SKLIMA, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_True_BCT_WSKLIMA(uint256 retireAmount) public {
        retireExactBCT(WSKLIMA, retireAmount);
        retireExactBCTWithEntity(WSKLIMA, retireAmount);
    }

    function getSourceTokens(address sourceToken, uint256 retireAmount) internal returns (uint256 sourceAmount) {
        /// @dev getting trade amount on zero output will revert
        if (retireAmount == 0 && sourceToken != BCT) vm.expectRevert();

        (sourceAmount,) = aggregatorV1.getSourceAmountSpecific(sourceToken, BCT, retireAmount, true);

        address sourceTarget;

        if (sourceToken == BCT || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(aggregatorV1Address, sourceAmount);
    }

    function retireExactBCT(address sourceToken, uint256 retireAmount) public {
        vm.assume(retireAmount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);

        uint256 sourceAmount = getSourceTokens(sourceToken, retireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken = projects[randomish(projects.length)];
        uint256 poolBalance = IERC20(projectToken).balanceOf(BCT);
        address[] memory projectTokens = new address[](1);
        projectTokens[0] = projectToken;

        if (retireAmount > poolBalance || retireAmount == 0) {
            vm.expectRevert();

            aggregatorV1.retireCarbonSpecific(
                sourceToken, BCT, retireAmount, true, beneficiaryAddress, beneficiary, message, projectTokens
            );
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
                projectToken,
                retireAmount
            );

            aggregatorV1.retireCarbonSpecific(
                sourceToken, BCT, retireAmount, true, beneficiaryAddress, beneficiary, message, projectTokens
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(sourceToken, aggregatorV1Address);
            assertZeroTokenBalance(BCT, diamond);
            assertZeroTokenBalance(BCT, aggregatorV1Address);
            assertZeroTokenBalance(projectToken, diamond);
            assertZeroTokenBalance(projectToken, aggregatorV1Address);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }

    function retireExactBCTWithEntity(address sourceToken, uint256 retireAmount) public {
        vm.assume(retireAmount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);

        uint256 sourceAmount = getSourceTokens(sourceToken, retireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken = projects[randomish(projects.length)];
        uint256 poolBalance = IERC20(projectToken).balanceOf(BCT);
        address[] memory projectTokens = new address[](1);
        projectTokens[0] = projectToken;

        if (retireAmount > poolBalance || retireAmount == 0) {
            vm.expectRevert();

            aggregatorV1.retireCarbonSpecific(
                sourceToken, BCT, retireAmount, true, beneficiaryAddress, beneficiary, message, projectTokens
            );
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
                projectToken,
                retireAmount
            );

            aggregatorV1.retireCarbonSpecific(
                sourceToken, BCT, retireAmount, true, entity, beneficiaryAddress, beneficiary, message, projectTokens
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(sourceToken, aggregatorV1Address);
            assertZeroTokenBalance(BCT, diamond);
            assertZeroTokenBalance(BCT, aggregatorV1Address);
            assertZeroTokenBalance(projectToken, diamond);
            assertZeroTokenBalance(projectToken, aggregatorV1Address);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }
}
