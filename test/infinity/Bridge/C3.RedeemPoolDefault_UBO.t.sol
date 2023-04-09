pragma solidity ^0.8.16;

// import "./HelperContract.sol";
import {RedeemC3PoolFacet} from "../../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
// import {ConstantsGetter} from "../../src/infinity/mocks/ConstantsGetter.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RedeemC3PoolFacetTest is TestHelper, AssertionHelper {
    RedeemC3PoolFacet redeemC3PoolFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    address uboDefaultProjectAddress = 0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA;
    address nboDefaultProjectAddress = 0xb6eA7a53FC048D6d3B80b968D696E39482B7e578;
    address uboSpecificProjectAddress = 0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA;
    address nboSpecificProjectAddress = 0xD28DFEBa8fB9e44B715156162C8b6076d7a95Ad1;

    uint defaultCarbonRetireAmount = 100 * 1e18;

    address beneficiaryAddress = 0x000000000000000000000000000000000000dEaD;
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address KLIMA_TREASURY;
    address KLIMA_STAKING;
    address wsKLIMA_holder = 0xe02efadA566Af74c92b6659d03BAaCb4c06Cc856; // C3 wsKLIMA gauge

    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;

    address UBO;

    function setUp() public {
        addConstantsGetter(diamond);
        redeemC3PoolFacet = RedeemC3PoolFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        KLIMA_STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        UBO = constantsFacet.ubo();
    }

    function test_c3RedeemPoolDefault_redeemUBO_usingUBO_fuzz(uint redeemAmount) public {
        address sourceToken = UBO;
        address carbonToken = UBO;

        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, redeemAmount);

        vm.assume(redeemAmount <= IERC20(sourceToken).balanceOf(KLIMA_TREASURY));

        swipeERC20Tokens(sourceToken, sourceAmount, KLIMA_TREASURY, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);
        uint poolBalance = IERC20(uboDefaultProjectAddress).balanceOf(constantsFacet.ubo());

        if (redeemAmount > poolBalance) {
            console.log("Balance greater than pool");
            vm.expectRevert();

            (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(
                sourceToken,
                carbonToken,
                redeemAmount,
                sourceAmount,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );
        } else {
            (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(
                sourceToken,
                carbonToken,
                redeemAmount,
                sourceAmount,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );

            // No tokens left in contract
            // assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(uboDefaultProjectAddress, diamond);
            assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond));
            // assertEq(0, IERC20(uboDefaultProjectAddress).balanceOf(diamond));

            // Caller has default project tokens
            assertEq(projectTokens[0], uboDefaultProjectAddress);
            assertEq(IERC20(uboDefaultProjectAddress).balanceOf(address(this)), redeemAmount);
            assertEq(IERC20(uboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);
        }
    }
}
