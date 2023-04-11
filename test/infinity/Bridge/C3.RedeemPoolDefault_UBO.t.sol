pragma solidity ^0.8.16;

import {RedeemC3PoolFacet} from "../../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IC3Pool} from "../../../src/infinity/interfaces/IC3.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RedeemC3PoolFacetTest is TestHelper, AssertionHelper {
    RedeemC3PoolFacet redeemC3PoolFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address WSKLIMA_HOLDER = vm.envAddress("WSKLIMA_HOLDER");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address UBO;
    address DEFAULT_PROJECT;

    uint defaultCarbonRetireAmount = 100 * 1e18;

    function setUp() public {
        addConstantsGetter(diamond);
        redeemC3PoolFacet = RedeemC3PoolFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        UBO = constantsFacet.ubo();

        DEFAULT_PROJECT = IC3Pool(UBO).getFreeRedeemAddresses()[0];
    }

    function test_c3RedeemPoolDefault_redeemUBO_usingUBO_fuzz(uint redeemAmount) public {
        vm.assume(redeemAmount <= IERC20(UBO).balanceOf(KLIMA_TREASURY));

        address sourceToken = UBO;
        redeemUBO(sourceToken, redeemAmount);
    }

    function test_c3RedeemPoolDefault_redeemUBO_usingUSDC_fuzz(uint redeemAmount) public {
        vm.assume(redeemAmount <= IERC20(USDC).balanceOf(KLIMA_TREASURY));

        address sourceToken = USDC;
        redeemUBO(sourceToken, redeemAmount);
    }

    function test_c3RedeemPoolDefault_redeemUBO_usingKLIMA_fuzz(uint redeemAmount) public {
        vm.assume(redeemAmount <= IERC20(KLIMA).balanceOf(KLIMA_TREASURY));

        address sourceToken = KLIMA;
        redeemUBO(sourceToken, redeemAmount);
    }

    function test_c3RedeemPoolDefault_redeemUBO_usingSKLIMA_fuzz(uint redeemAmount) public {
        vm.assume(redeemAmount <= IERC20(SKLIMA).balanceOf(KLIMA_TREASURY));

        address sourceToken = SKLIMA;
        redeemUBO(sourceToken, redeemAmount);
    }

    function test_c3RedeemPoolDefault_redeemUBO_usingWSKLIMA_fuzz(uint redeemAmount) public {
        vm.assume(redeemAmount <= IERC20(WSKLIMA).balanceOf(KLIMA_TREASURY));

        address sourceToken = WSKLIMA;
        redeemUBO(sourceToken, redeemAmount);
    }

    function getSourceTokens(address sourceToken, uint redeemAmount) internal returns (uint sourceAmount) {
        sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, UBO, redeemAmount);

        address sourceTarget;

        if (sourceToken == UBO || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function redeemUBO(address sourceToken, uint redeemAmount) internal {
        uint sourceAmount = getSourceTokens(sourceToken, redeemAmount);

        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);
        uint poolBalance = IERC20(DEFAULT_PROJECT).balanceOf(constantsFacet.ubo());

        if (redeemAmount > poolBalance) {
            console.log("Balance greater than pool");
            vm.expectRevert();

            redeemC3PoolFacet.c3RedeemPoolDefault(
                sourceToken,
                UBO,
                redeemAmount,
                sourceAmount,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );
        } else {
            (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(
                sourceToken,
                UBO,
                redeemAmount,
                sourceAmount,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );

            // Update redeemedAmount if source was not UBO, since you can't swap to an exact amount in Trident.
            if (sourceToken != UBO) redeemAmount = amounts[0];

            // No tokens left in contract
            assertZeroTokenBalance(DEFAULT_PROJECT, diamond);
            assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond));

            // Caller has default project tokens
            assertEq(projectTokens[0], DEFAULT_PROJECT);
            assertEq(redeemAmount, amounts[0]);
            assertEq(IERC20(DEFAULT_PROJECT).balanceOf(address(this)), amounts[0]);
        }
    }
}
