pragma solidity ^0.8.16;

import {RedeemToucanPoolFacet} from "../../../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RedeemToucanPoolDefaultNCTTest is TestHelper, AssertionHelper {
    RedeemToucanPoolFacet redeemToucanPoolFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
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
    address DEFAULT_PROJECT;

    function setUp() public {
        addConstantsGetter(diamond);
        redeemToucanPoolFacet = RedeemToucanPoolFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        NCT = constantsFacet.nct();

        DEFAULT_PROJECT = IToucanPool(NCT).getScoredTCO2s()[0];

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_toucanRedeemPoolDefault_redeemNCT_usingNCT_fuzz(uint redeemAmount) public {
        redeemNCT(NCT, redeemAmount);
    }

    function test_toucanRedeemPoolDefault_redeemNCT_usingUSDC_fuzz(uint redeemAmount) public {
        redeemNCT(USDC, redeemAmount);
    }

    function test_toucanRedeemPoolDefault_redeemNCT_usingKLIMA_fuzz(uint redeemAmount) public {
        redeemNCT(KLIMA, redeemAmount);
    }

    function test_toucanRedeemPoolDefault_redeemNCT_usingSKLIMA_fuzz(uint redeemAmount) public {
        redeemNCT(SKLIMA, redeemAmount);
    }

    function test_toucanRedeemPoolDefault_redeemNCT_usingWSKLIMA_fuzz(uint redeemAmount) public {
        redeemNCT(WSKLIMA, redeemAmount);
    }

    function getSourceTokens(address sourceToken, uint redeemAmount) internal returns (uint sourceAmount) {
        /// @dev getting trade amount on zero output will revert
        if (redeemAmount == 0 && sourceToken != NCT) vm.expectRevert();
        sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, NCT, redeemAmount);

        address sourceTarget;

        if (sourceToken == NCT || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function redeemNCT(address sourceToken, uint redeemAmount) internal {
        vm.assume(redeemAmount < (IERC20(NCT).balanceOf(SUSHI_LP) * 10) / 100);
        uint sourceAmount = getSourceTokens(sourceToken, redeemAmount);

        if (redeemAmount == 0) {
            vm.expectRevert();

            redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(
                sourceToken,
                NCT,
                redeemAmount,
                sourceAmount,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );
        } else {
            (address[] memory projectTokens, uint[] memory amounts) = redeemToucanPoolFacet
                .toucanRedeemExactCarbonPoolDefault(
                    sourceToken,
                    NCT,
                    redeemAmount,
                    sourceAmount,
                    LibTransfer.From.EXTERNAL,
                    LibTransfer.To.EXTERNAL
                );

            // No tokens left in contract
            assertZeroTokenBalance(DEFAULT_PROJECT, diamond);
            assertZeroTokenBalance(NCT, diamond);

            // Caller has default project tokens
            assertEq(projectTokens[0], DEFAULT_PROJECT);
            assertEq(IERC20(DEFAULT_PROJECT).balanceOf(address(this)), amounts[0]);
        }
    }
}
