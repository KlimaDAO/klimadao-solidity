pragma solidity ^0.8.16;

import {RedeemToucanPoolFacet} from "../../../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RedeemToucanPoolDefaultBCTTest is TestHelper, AssertionHelper {
    RedeemToucanPoolFacet redeemToucanPoolFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address SUSHI_LP = vm.envAddress("SUSHI_BCT_LP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address USDC_NATIVE;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address BCT;
    address DEFAULT_PROJECT;
    address KLIMA_RETIREMENT_BOND;

    function setUp() public {
        addConstantsGetter(diamond);
        redeemToucanPoolFacet = RedeemToucanPoolFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc_bridged();
        USDC_NATIVE = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        BCT = constantsFacet.bct();

        DEFAULT_PROJECT = getDefaultToucanProject(BCT);
        KLIMA_RETIREMENT_BOND = constantsFacet.klimaRetirementBond();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemBCT_usingBCT_fuzz(uint256 redeemAmount) public {
        redeemBCT(BCT, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemBCT_usingUSDC_fuzz(uint256 redeemAmount) public {
        redeemBCT(USDC, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemBCT_usingUSDC_NATIVE_fuzz(uint256 redeemAmount) public {
        redeemBCT(USDC_NATIVE, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemBCT_usingKLIMA_fuzz(uint256 redeemAmount) public {
        redeemBCT(KLIMA, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemBCT_usingSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemBCT(SKLIMA, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolDefault_redeemBCT_usingWSKLIMA_fuzz() public {
        // hardcode to circumvent larger funding refactor
        uint256 redeemAmount = 1e18;

        redeemBCT(WSKLIMA, redeemAmount);
    }

    function redeemBCT(address sourceToken, uint256 redeemAmount) internal {
        // set upper limit to 60% of pool balance
        vm.assume(redeemAmount < (IERC20(BCT).balanceOf(SUSHI_LP) * 60) / 100);

        if (redeemAmount == 0 && sourceToken != BCT) vm.expectRevert();
        uint256 sourceAmount = getSourceTokens(TransactionType.DEFAULT_REDEEM, diamond, sourceToken, BCT, redeemAmount);

        uint256 poolBalance = IERC20(DEFAULT_PROJECT).balanceOf(constantsFacet.bct());
        uint256 bondBalance = IERC20(BCT).balanceOf(KLIMA_RETIREMENT_BOND);


        if (redeemAmount == 0) {
            vm.expectRevert();

            redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(
                sourceToken, BCT, redeemAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL
            );
        } else {
            (address[] memory projectTokens, uint256[] memory amounts) = redeemToucanPoolFacet
                .toucanRedeemExactCarbonPoolDefault(
                sourceToken, BCT, redeemAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(DEFAULT_PROJECT, diamond);
            assertZeroTokenBalance(BCT, diamond);

            // Retirement bonds were not used
            assertEq(bondBalance, IERC20(BCT).balanceOf(KLIMA_RETIREMENT_BOND));

            // Caller has default project tokens
            assertEq(projectTokens[0], DEFAULT_PROJECT);
            assertEq(IERC20(DEFAULT_PROJECT).balanceOf(address(this)), amounts[0]);
        }
    }
}
