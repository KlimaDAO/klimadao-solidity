pragma solidity ^0.8.16;

import {RetireSourceFacet} from "../../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibKlima} from "../../../src/infinity/libraries/LibKlima.sol";
import {LibToucanCarbon} from "../../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract retireExactSourceDefaultToucan is TestHelper, AssertionHelper {
    RetireSourceFacet retireSourceFacet;
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
    address SUSHI_BENTO = vm.envAddress("SUSHI_BENTO");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address BCT;
    address NCT;
    address DEFAULT_PROJECT_BCT;
    address DEFAULT_PROJECT_NCT;

    function setUp() public {
        addConstantsGetter(diamond);
        retireSourceFacet = RetireSourceFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        BCT = constantsFacet.bct();
        NCT = constantsFacet.nct();

        DEFAULT_PROJECT_BCT = IToucanPool(BCT).getScoredTCO2s()[0];
        DEFAULT_PROJECT_NCT = IToucanPool(NCT).getScoredTCO2s()[0];

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_retireExactSourceDefault_BCT_BCT(uint retireAmount) public {
        retireExactSource(BCT, BCT, retireAmount);
    }

    function test_retireExactSourceDefault_BCT_USDC(uint retireAmount) public {
        retireExactSource(USDC, BCT, retireAmount);
    }

    function test_retireExactSourceDefault_BCT_KLIMA(uint retireAmount) public {
        retireExactSource(KLIMA, BCT, retireAmount);
    }

    function test_retireExactSourceDefault_BCT_SKLIMA(uint retireAmount) public {
        retireExactSource(SKLIMA, BCT, retireAmount);
    }

    function test_retireExactSourceDefault_BCT_WSKLIMA(uint retireAmount) public {
        retireExactSource(WSKLIMA, BCT, retireAmount);
    }

    function test_retireExactSourceDefault_NCT_NCT(uint retireAmount) public {
        retireExactSource(NCT, NCT, retireAmount);
    }

    function test_retireExactSourceDefault_NCT_USDC(uint retireAmount) public {
        retireExactSource(USDC, NCT, retireAmount);
    }

    function test_retireExactSourceDefault_NCT_KLIMA(uint retireAmount) public {
        retireExactSource(KLIMA, NCT, retireAmount);
    }

    function test_retireExactSourceDefault_NCT_SKLIMA(uint retireAmount) public {
        retireExactSource(SKLIMA, NCT, retireAmount);
    }

    function test_retireExactSourceDefault_NCT_WSKLIMA(uint retireAmount) public {
        retireExactSource(WSKLIMA, NCT, retireAmount);
    }

    function getSourceTokens(address sourceToken, uint sourceAmount) internal {
        address sourceTarget;

        /// @dev Setting minimum amount assumptions due to issues with Trident performing swaps with zero output tokens.
        vm.assume(sourceAmount > 1e4);

        if (sourceToken == BCT || sourceToken == NCT || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) {
            vm.assume(sourceAmount > LibKlima.toWrappedAmount(1e6));
            sourceTarget = WSKLIMA_HOLDER;
        }

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function retireExactSource(address sourceToken, address poolToken, uint sourceAmount) public {
        // vm.assume(sourceAmount < (IERC20(poolToken).balanceOf(SUSHI_BENTO) * 90) / 100);

        getSourceTokens(sourceToken, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken = poolToken == BCT ? DEFAULT_PROJECT_BCT : DEFAULT_PROJECT_NCT;
        // uint poolBalance = IERC20(projectToken).balanceOf(poolToken);

        uint retireAmount = quoterFacet.getRetireAmountSourceDefault(sourceToken, poolToken, sourceAmount);
        uint poolAmount = poolToken == BCT
            ? IERC20(DEFAULT_PROJECT_BCT).balanceOf(poolToken)
            : IERC20(DEFAULT_PROJECT_NCT).balanceOf(poolToken);
        vm.assume(retireAmount <= poolAmount);

        if (sourceAmount == 0) {
            vm.expectRevert();
            retireSourceFacet.retireExactSourceDefault(
                sourceToken,
                poolToken,
                sourceAmount,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                LibTransfer.From.EXTERNAL
            );
        } else {
            uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(
                sourceToken,
                poolToken,
                sourceAmount,
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

            // Since the output from Trident isn't deterministic until the swap happens, check an approximation.
            assertApproxEqRel(
                LibRetire.getTotalCarbonRetired(beneficiaryAddress),
                currentTotalCarbon + retireAmount,
                1e16
            );
        }
    }
}
