pragma solidity ^0.8.16;

import {RedeemC3PoolFacet} from "../../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IC3Pool} from "../../../src/infinity/interfaces/IC3.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RedeemUBOSpecificTest is TestHelper, AssertionHelper {
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
    address USDC_BRIDGED;
    address USDC_NATIVE;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address UBO;
    address[] projects;
    address KLIMA_RETIREMENT_BOND;

    uint256 defaultCarbonRetireAmount = 100 * 1e18;

    function setUp() public {
        addConstantsGetter(diamond);
        redeemC3PoolFacet = RedeemC3PoolFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC_BRIDGED = constantsFacet.usdc_bridged();
        USDC_NATIVE = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        UBO = constantsFacet.ubo();
        KLIMA_RETIREMENT_BOND = constantsFacet.klimaRetirementBond();

        projects = IC3Pool(UBO).getERC20Tokens();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemUBO_usingUBO_fuzz(uint256 redeemAmount) public {
        redeemUBO(UBO, redeemAmount);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemUBO_usingUSDC_NATIVE_fuzz(uint256 redeemAmount) public {
        redeemUBO(USDC_NATIVE, redeemAmount);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemUBO_usingUSDC_BRIDGED_fuzz(uint256 redeemAmount) public {
        redeemUBO(USDC_BRIDGED, redeemAmount);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemUBO_usingKLIMA_fuzz(uint256 redeemAmount) public {
        redeemUBO(KLIMA, redeemAmount);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemUBO_usingSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemUBO(SKLIMA, redeemAmount);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemUBO_usingWSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemUBO(WSKLIMA, redeemAmount);
    }

    function redeemUBO(address sourceToken, uint256 redeemAmount) internal {
        vm.assume(redeemAmount < (IERC20(UBO).balanceOf(SUSHI_LP) * 90) / 100);

        uint256 projectIndex = randomish(projects.length);
        address specificProject = projects[projectIndex];

        address[] memory projectRedeem = new address[](1);
        uint256[] memory amountRedeem = new uint256[](1);

        projectRedeem[0] = specificProject;
        amountRedeem[0] = redeemAmount;

        if (redeemAmount == 0 && sourceToken != UBO) vm.expectRevert();
        uint256 sourceAmount = getSourceTokens(TransactionType.SPECIFIC_REDEEM, diamond, sourceToken, UBO, redeemAmount);

        uint256 poolBalance = IERC20(specificProject).balanceOf(constantsFacet.ubo());
        uint256 bondBalance = IERC20(UBO).balanceOf(KLIMA_RETIREMENT_BOND);

        if (redeemAmount > poolBalance || redeemAmount == 0) {
            console.log("Balance greater than pool");
            vm.expectRevert();

            redeemC3PoolFacet.c3RedeemPoolSpecific(
                sourceToken,
                UBO,
                sourceAmount,
                projectRedeem,
                amountRedeem,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );
        } else {
            uint256[] memory amounts = redeemC3PoolFacet.c3RedeemPoolSpecific(
                sourceToken,
                UBO,
                sourceAmount,
                projectRedeem,
                amountRedeem,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(specificProject, diamond);
            assertZeroTokenBalance(UBO, diamond);

            // Retirement bonds were not used
            assertEq(bondBalance, IERC20(UBO).balanceOf(KLIMA_RETIREMENT_BOND));

            // Caller has default project tokens
            assertEq(redeemAmount, amounts[0]);
            assertEq(IERC20(specificProject).balanceOf(address(this)), amounts[0]);
        }
    }
}
