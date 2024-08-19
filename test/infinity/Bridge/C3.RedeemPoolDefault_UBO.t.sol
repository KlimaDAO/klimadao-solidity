pragma solidity ^0.8.16;

import {RedeemC3PoolFacet} from "../../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IC3Pool} from "../../../src/infinity/interfaces/IC3.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RedeemUBODefaultTest is TestHelper, AssertionHelper {
    RedeemC3PoolFacet redeemC3PoolFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address SUSHI_LP = vm.envAddress("SUSHI_UBO_LP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address UBO;
    address DEFAULT_PROJECT;
    address KLIMA_RETIREMENT_BOND;

    uint256 defaultCarbonRetireAmount = 100 * 1e18;

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
        KLIMA_RETIREMENT_BOND = constantsFacet.klimaRetirementBond();

        DEFAULT_PROJECT = getDefaultC3Project(UBO);

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_c3RedeemPoolDefault_redeemUBO_usingUBO_fuzz(uint256 redeemAmount) public {
        redeemUBO(UBO, redeemAmount);
    }

    function test_infinity_c3RedeemPoolDefault_redeemUBO_usingUSDC_fuzz(uint256 redeemAmount) public {
        redeemUBO(USDC, redeemAmount);
    }

    function test_infinity_c3RedeemPoolDefault_redeemUBO_usingKLIMA_fuzz(uint256 redeemAmount) public {
        redeemUBO(KLIMA, redeemAmount);
    }

    function test_infinity_c3RedeemPoolDefault_redeemUBO_usingSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemUBO(SKLIMA, redeemAmount);
    }

    function test_infinity_c3RedeemPoolDefault_redeemUBO_usingWSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemUBO(WSKLIMA, redeemAmount);
    }

    function redeemUBO(address sourceToken, uint256 redeemAmount) internal {
        vm.assume(redeemAmount < (IERC20(UBO).balanceOf(SUSHI_LP) * 90) / 100);
        if (redeemAmount == 0 && sourceToken != UBO) vm.expectRevert();

        uint256 sourceAmount =
            getSourceTokens(TransactionType.DEFAULT_REDEEM, address(redeemC3PoolFacet), sourceToken, UBO, redeemAmount);

        uint256 poolBalance = IERC20(DEFAULT_PROJECT).balanceOf(constantsFacet.ubo());
        uint256 bondBalance = IERC20(UBO).balanceOf(KLIMA_RETIREMENT_BOND);

        if (redeemAmount > poolBalance || redeemAmount == 0) {
            console.log("Balance greater than pool");
            vm.expectRevert();

            redeemC3PoolFacet.c3RedeemPoolDefault(
                sourceToken, UBO, redeemAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL
            );
        } else {
            (address[] memory projectTokens, uint256[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(
                sourceToken, UBO, redeemAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL
            );

            address redeemedProject;
            uint256 redeemedAmount;
            for (uint256 i; i < projectTokens.length; ++i) {
                if (amounts[i] > 0) {
                    redeemedProject = projectTokens[i];
                    redeemedAmount = amounts[i];
                    break;
                }
            }

            // No tokens left in contract
            assertZeroTokenBalance(DEFAULT_PROJECT, diamond);
            assertZeroTokenBalance(UBO, diamond);

            // Retirement bonds were not used
            assertEq(bondBalance, IERC20(UBO).balanceOf(KLIMA_RETIREMENT_BOND));

            // Caller has default project tokens
            assertEq(redeemedProject, DEFAULT_PROJECT);
            assertEq(redeemAmount, redeemedAmount);
            assertEq(IERC20(DEFAULT_PROJECT).balanceOf(address(this)), redeemedAmount);
        }
    }
}
