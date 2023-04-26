pragma solidity ^0.8.16;

import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibMossCarbon} from "../../../src/infinity/libraries/Bridges/LibMossCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RetireExactCarbonDefaultMoss is TestHelper, AssertionHelper {
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
    address WSKLIMA_HOLDER = vm.envAddress("WSKLIMA_HOLDER");
    address QUICKSWAP_LP = vm.envAddress("MCO2_QUICKSWAP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address MCO2;

    function setUp() public {
        addConstantsGetter(diamond);
        retireCarbonFacet = RetireCarbonFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        MCO2 = constantsFacet.mco2();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());
    }

    function test_retireExactCarbonDefault_MCO2_MCO2(uint retireAmount) public {
        retireExactMoss(MCO2, retireAmount);
    }

    function test_retireExactCarbonDefault_MCO2_USDC(uint retireAmount) public {
        retireExactMoss(USDC, retireAmount);
    }

    function test_retireExactCarbonDefault_MCO2_KLIMA(uint retireAmount) public {
        retireExactMoss(KLIMA, retireAmount);
    }

    function test_retireExactCarbonDefault_MCO2_SKLIMA(uint retireAmount) public {
        retireExactMoss(SKLIMA, retireAmount);
    }

    function test_retireExactCarbonDefault_MCO2_WSKLIMA(uint retireAmount) public {
        retireExactMoss(WSKLIMA, retireAmount);
    }

    function getSourceTokens(address sourceToken, uint retireAmount) internal returns (uint sourceAmount) {
        /// @dev getting trade amount on zero output will revert
        if (retireAmount == 0 && sourceToken != MCO2) vm.expectRevert();
        sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, MCO2, retireAmount);

        address sourceTarget;

        if (sourceToken == MCO2 || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function retireExactMoss(address sourceToken, uint retireAmount) public {
        vm.assume(retireAmount < (IERC20(MCO2).balanceOf(QUICKSWAP_LP) * 90) / 100);
        uint sourceAmount = getSourceTokens(sourceToken, retireAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        if (retireAmount == 0) {
            vm.expectRevert();

            retireCarbonFacet.retireExactCarbonDefault(
                sourceToken,
                MCO2,
                sourceAmount,
                retireAmount,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                LibTransfer.From.EXTERNAL
            );
        } else {
            // Set up expectEmit
            vm.expectEmit(true, true, true, true);

            // Emit expected CarbonRetired event
            emit LibMossCarbon.CarbonRetired(
                LibRetire.CarbonBridge.MOSS,
                address(this),
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                MCO2,
                address(0),
                retireAmount
            );

            uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(
                sourceToken,
                MCO2,
                sourceAmount,
                retireAmount,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                LibTransfer.From.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(MCO2, diamond);

            // Return value matches
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }
}
