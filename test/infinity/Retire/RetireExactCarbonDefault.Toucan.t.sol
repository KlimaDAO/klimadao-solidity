pragma solidity ^0.8.16;

import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibToucanCarbon} from "../../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RetireExactCarbonDefaultToucan is TestHelper, AssertionHelper {
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
    address SUSHI_BCT_LP = vm.envAddress("SUSHI_BCT_LP");
    address SUSHI_NCT_LP = vm.envAddress("SUSHI_NCT_LP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC_BRIDGED;
    address USDC_NATIVE;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address BCT;
    address NCT;
    address DEFAULT_PROJECT_BCT;
    address DEFAULT_PROJECT_NCT;

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
        BCT = constantsFacet.bct();
        NCT = constantsFacet.nct();

        DEFAULT_PROJECT_BCT = getDefaultToucanProject(BCT);
        DEFAULT_PROJECT_NCT = getDefaultToucanProject(NCT);

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_retireExactCarbonDefault_BCT_BCT(uint256 retireAmount) public {
        retireExactToucan(BCT, BCT, retireAmount, SUSHI_BCT_LP);
    }


    function test_infinity_retireExactCarbonDefault_BCT_USDC_BRIDGED(uint256 retireAmount) public {
        retireExactToucan(USDC_BRIDGED, BCT, retireAmount, SUSHI_BCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_BCT_USDC_NATIVE(uint256 retireAmount) public {
        retireExactToucan(USDC_NATIVE, BCT, retireAmount, SUSHI_BCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_BCT_KLIMA(uint256 retireAmount) public {
        retireExactToucan(KLIMA, BCT, retireAmount, SUSHI_BCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_BCT_SKLIMA(uint256 retireAmount) public {
        retireExactToucan(SKLIMA, BCT, retireAmount, SUSHI_BCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_BCT_WSKLIMA(uint256 retireAmount) public {
        retireExactToucan(WSKLIMA, BCT, retireAmount, SUSHI_BCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_NCT_NCT(uint256 retireAmount) public {
        retireExactToucan(NCT, NCT, retireAmount, SUSHI_NCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_NCT_USDC_BRIDGED(uint256 retireAmount) public {
        retireExactToucan(USDC_BRIDGED, NCT, retireAmount, SUSHI_NCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_NCT_USDC_NATIVE(uint256 retireAmount) public {
        retireExactToucan(USDC_NATIVE, NCT, retireAmount, SUSHI_NCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_NCT_KLIMA(uint256 retireAmount) public {
        retireExactToucan(KLIMA, NCT, retireAmount, SUSHI_NCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_NCT_SKLIMA(uint256 retireAmount) public {
        retireExactToucan(SKLIMA, NCT, retireAmount, SUSHI_NCT_LP);
    }

    function test_infinity_retireExactCarbonDefault_NCT_WSKLIMA(uint256 retireAmount) public {
        retireExactToucan(WSKLIMA, NCT, retireAmount, SUSHI_NCT_LP);
    }

    function retireExactToucan(address sourceToken, address poolToken, uint256 retireAmount, address lpPool) public {
        vm.assume(retireAmount < (IERC20(poolToken).balanceOf(lpPool) * 50) / 100);

        if (retireAmount == 0 && sourceToken != poolToken) vm.expectRevert();
        uint256 sourceAmount =
            getSourceTokens(TransactionType.DEFAULT_RETIRE, diamond, sourceToken, poolToken, retireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken = poolToken == BCT ? DEFAULT_PROJECT_BCT : DEFAULT_PROJECT_NCT;
        uint256 poolBalance = IERC20(projectToken).balanceOf(poolToken);

        vm.assume(retireAmount <= poolBalance);

        if (retireAmount == 0) {
            vm.expectRevert();

            retireCarbonFacet.retireExactCarbonDefault(
                sourceToken,
                poolToken,
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
            emit LibToucanCarbon.CarbonRetired(
                LibRetire.CarbonBridge.TOUCAN,
                address(this),
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                poolToken,
                projectToken,
                retireAmount
            );

            uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(
                sourceToken,
                poolToken,
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
            assertZeroTokenBalance(poolToken, diamond);
            assertZeroTokenBalance(projectToken, diamond);

            // Return value matches
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }
}
