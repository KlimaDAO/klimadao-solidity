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

contract RetireCarbonSpecificTrueToucanNCT is TestHelper, AssertionHelper {
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
    address SUSHI_LP = vm.envAddress("SUSHI_NCT_LP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address NCT;
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
        NCT = constantsFacet.nct();

        projects = IToucanPool(NCT).getScoredTCO2s();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());
    }

    function test_infinity_v1_retireCarbonSpecific_True_NCT_NCT(uint256 retireAmount) public {
        retireExactNCT(NCT, retireAmount);
        retireExactNCTWithEntity(NCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_True_NCT_USDC(uint256 retireAmount) public {
        retireExactNCT(USDC, retireAmount);
        retireExactNCTWithEntity(USDC, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_True_NCT_KLIMA(uint256 retireAmount) public {
        retireExactNCT(KLIMA, retireAmount);
        retireExactNCTWithEntity(KLIMA, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_True_NCT_SKLIMA(uint256 retireAmount) public {
        retireExactNCT(SKLIMA, retireAmount);
        retireExactNCTWithEntity(SKLIMA, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_True_NCT_WSKLIMA(uint256 retireAmount) public {
        retireExactNCT(WSKLIMA, retireAmount);
        retireExactNCTWithEntity(WSKLIMA, retireAmount);
    }

    function getSourceTokens(address sourceToken, uint256 retireAmount) internal returns (uint256 sourceAmount) {
        /// @dev getting trade amount on zero output will revert
        if (retireAmount == 0 && sourceToken != NCT) vm.expectRevert();

        (sourceAmount,) = aggregatorV1.getSourceAmountSpecific(sourceToken, NCT, retireAmount, true);

        address sourceTarget;

        if (sourceToken == NCT || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(aggregatorV1Address, sourceAmount);
    }

    function retireExactNCT(address sourceToken, uint256 retireAmount) public {
        vm.assume(retireAmount < (IERC20(NCT).balanceOf(SUSHI_LP) * 50) / 100);

        uint256 sourceAmount = getSourceTokens(sourceToken, retireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken = projects[randomish(projects.length)];
        uint256 poolBalance = IERC20(projectToken).balanceOf(NCT);
        address[] memory projectTokens = new address[](1);
        projectTokens[0] = projectToken;

        if (retireAmount > poolBalance || retireAmount == 0) {
            vm.expectRevert();

            aggregatorV1.retireCarbonSpecific(
                sourceToken, NCT, retireAmount, true, beneficiaryAddress, beneficiary, message, projectTokens
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
                NCT,
                projectToken,
                retireAmount
            );

            aggregatorV1.retireCarbonSpecific(
                sourceToken, NCT, retireAmount, true, beneficiaryAddress, beneficiary, message, projectTokens
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(sourceToken, aggregatorV1Address);
            assertZeroTokenBalance(NCT, diamond);
            assertZeroTokenBalance(NCT, aggregatorV1Address);
            assertZeroTokenBalance(projectToken, diamond);
            assertZeroTokenBalance(projectToken, aggregatorV1Address);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }

    function retireExactNCTWithEntity(address sourceToken, uint256 retireAmount) public {
        vm.assume(retireAmount < (IERC20(NCT).balanceOf(SUSHI_LP) * 50) / 100);

        uint256 sourceAmount = getSourceTokens(sourceToken, retireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken = projects[randomish(projects.length)];
        uint256 poolBalance = IERC20(projectToken).balanceOf(NCT);
        address[] memory projectTokens = new address[](1);
        projectTokens[0] = projectToken;

        if (retireAmount > poolBalance || retireAmount == 0) {
            vm.expectRevert();

            aggregatorV1.retireCarbonSpecific(
                sourceToken, NCT, retireAmount, true, beneficiaryAddress, beneficiary, message, projectTokens
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
                NCT,
                projectToken,
                retireAmount
            );

            aggregatorV1.retireCarbonSpecific(
                sourceToken, NCT, retireAmount, true, entity, beneficiaryAddress, beneficiary, message, projectTokens
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(sourceToken, aggregatorV1Address);
            assertZeroTokenBalance(NCT, diamond);
            assertZeroTokenBalance(NCT, aggregatorV1Address);
            assertZeroTokenBalance(projectToken, diamond);
            assertZeroTokenBalance(projectToken, aggregatorV1Address);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }
}
