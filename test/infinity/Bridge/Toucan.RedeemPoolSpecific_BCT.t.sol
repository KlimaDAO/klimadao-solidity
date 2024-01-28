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
    address KLIMA_RETIREMENT_BOND;

    function setUp() public {
        addConstantsGetter(diamond);
        redeemToucanPoolFacet = RedeemToucanPoolFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc_bridged();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        BCT = constantsFacet.bct();

        projects = IToucanPool(BCT).getScoredTCO2s();
        KLIMA_RETIREMENT_BOND = constantsFacet.klimaRetirementBond();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_toucanRedeemPoolSpecific_redeemBCT_usingBCT_fuzz(uint256 redeemAmount) public {
        redeemBCT(BCT, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolSpecific_redeemBCT_usingUSDC_fuzz(uint256 redeemAmount) public {
        redeemBCT(USDC, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolSpecific_redeemBCT_usingKLIMA_fuzz(uint256 redeemAmount) public {
        redeemBCT(KLIMA, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolSpecific_redeemBCT_usingSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemBCT(SKLIMA, redeemAmount);
    }

    function test_infinity_toucanRedeemPoolSpecific_redeemBCT_usingWSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemBCT(WSKLIMA, redeemAmount);
    }

    function getSourceTokens(address sourceToken, uint256 redeemAmount) internal returns (uint256 sourceAmount) {
        /// @dev getting trade amount on zero output will revert
        if (redeemAmount == 0 && sourceToken != BCT) vm.expectRevert();

        uint256[] memory amounts = new uint[](1);
        amounts[0] = redeemAmount;

        sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, BCT, amounts);

        address sourceTarget;

        if (sourceToken == BCT || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function redeemBCT(address sourceToken, uint256 redeemAmount) internal {
        vm.assume(redeemAmount < (IERC20(BCT).balanceOf(SUSHI_LP) * 60) / 100);
        uint256 sourceAmount = getSourceTokens(sourceToken, redeemAmount);

        uint256 projectIndex = randomish(projects.length);
        address specificProject = projects[projectIndex];

        address[] memory projectRedeem = new address[](1);
        uint256[] memory amountRedeem = new uint[](1);

        projectRedeem[0] = specificProject;
        amountRedeem[0] = redeemAmount;

        uint256 poolBalance = IERC20(specificProject).balanceOf(BCT);
        uint256 bondBalance = IERC20(BCT).balanceOf(KLIMA_RETIREMENT_BOND);

        if (redeemAmount > poolBalance || redeemAmount == 0) {
            vm.expectRevert();

            redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(
                sourceToken,
                BCT,
                sourceAmount,
                projectRedeem,
                amountRedeem,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );
        } else {
            uint256[] memory amounts = redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(
                sourceToken,
                BCT,
                sourceAmount,
                projectRedeem,
                amountRedeem,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(specificProject, diamond);
            assertZeroTokenBalance(BCT, diamond);

            // Retirement bonds were not used
            assertEq(bondBalance, IERC20(BCT).balanceOf(KLIMA_RETIREMENT_BOND));

            // Caller has default project tokens
            assertEq(redeemAmount, amounts[0]);
            assertEq(IERC20(specificProject).balanceOf(address(this)), amounts[0]);
        }
    }
}
