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
    address KLIMA_RETIREMENT_BOND;

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

        DEFAULT_PROJECT = getDefaultToucanProject(NCT);
        KLIMA_RETIREMENT_BOND = constantsFacet.klimaRetirementBond();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemNCT_usingNCT_fuzz(uint256 redeemAmount) public {
        redeemNCT(NCT, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemNCT_usingUSDC_fuzz(uint256 redeemAmount) public {
        redeemNCT(USDC, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemNCT_usingKLIMA_fuzz(uint256 redeemAmount) public {
        redeemNCT(KLIMA, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemNCT_usingSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemNCT(SKLIMA, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemNCT_usingWSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemNCT(WSKLIMA, redeemAmount);
    }

    function redeemNCT(address sourceToken, uint256 redeemAmount) internal {
        vm.assume(redeemAmount < (IERC20(NCT).balanceOf(SUSHI_LP) * 10) / 100);

        if (redeemAmount == 0 && sourceToken != NCT) vm.expectRevert();
        uint256 sourceAmount = getSourceTokens(TransactionType.DEFAULT_REDEEM, diamond, sourceToken, NCT, redeemAmount);

        uint256 bondBalance = IERC20(NCT).balanceOf(KLIMA_RETIREMENT_BOND);

        if (redeemAmount == 0) {
            vm.expectRevert();

            redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(
                sourceToken, NCT, redeemAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL
            );
        } else {
            (address[] memory projectTokens, uint256[] memory amounts) = redeemToucanPoolFacet
                .toucanRedeemExactCarbonPoolDefault(
                sourceToken, NCT, redeemAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(DEFAULT_PROJECT, diamond);
            assertZeroTokenBalance(NCT, diamond);

            // Retirement bonds were not used
            assertEq(bondBalance, IERC20(NCT).balanceOf(KLIMA_RETIREMENT_BOND));

            // Caller has default project tokens
            assertEq(projectTokens[0], DEFAULT_PROJECT);
            assertEq(IERC20(DEFAULT_PROJECT).balanceOf(address(this)), amounts[0]);
        }
    }
}
