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
    address QUICKSWAP_LP = vm.envAddress("MCO2_QUICKSWAP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC_BRIDGED;
    address USDC_NATIVE;
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

        USDC_BRIDGED = constantsFacet.usdc_bridged();
        USDC_NATIVE = constantsFacet.usdc();

        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        MCO2 = constantsFacet.mco2();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_retireExactCarbonDefault_MCO2_MCO2(uint256 retireAmount) public {
        retireExactMoss(MCO2, retireAmount);
    }

    function test_infinity_retireExactCarbonDefault_MCO2_USDC_BRIDGED(uint256 retireAmount) public {
        retireExactMoss(USDC_BRIDGED, retireAmount);
    }

    function test_infinity_retireExactCarbonDefault_MCO2_USDC_NATIVE(uint256 retireAmount) public {
        retireExactMoss(USDC_NATIVE, retireAmount);
    }

    function test_infinity_retireExactCarbonDefault_MCO2_KLIMA(uint256 retireAmount) public {
        retireExactMoss(KLIMA, retireAmount);
    }

    function test_infinity_retireExactCarbonDefault_MCO2_SKLIMA(uint256 retireAmount) public {
        retireExactMoss(SKLIMA, retireAmount);
    }

    function test_infinity_retireExactCarbonDefault_MCO2_WSKLIMA(uint256 retireAmount) public {
        retireExactMoss(WSKLIMA, retireAmount);
    }

    function retireExactMoss(address sourceToken, uint256 retireAmount) public {
        vm.assume(retireAmount < (IERC20(MCO2).balanceOf(QUICKSWAP_LP) * 80) / 100);
        if (retireAmount == 0 && sourceToken != MCO2) vm.expectRevert();
        uint256 sourceAmount = getSourceTokens(TransactionType.DEFAULT_RETIRE, diamond, sourceToken, MCO2, retireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

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
            // if source token was native, we need to also confirm bridged dust has been returned
            if (sourceToken == USDC_NATIVE) {
                assertZeroTokenBalance(USDC_BRIDGED, diamond);
            }
            assertZeroTokenBalance(MCO2, diamond);

            // Return value matches
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }
}
