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
    address WSKLIMA_HOLDER = vm.envAddress("WSKLIMA_HOLDER");
    address SUSHI_BENTO = vm.envAddress("SUSHI_BENTO");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
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

        USDC = constantsFacet.usdc_bridged();
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

    function test_infinity_c3RedeemPoolSpecific_redeemUBO_usingUSDC_fuzz(uint256 redeemAmount) public {
        redeemUBO(USDC, redeemAmount);
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

    function getSourceTokens(address sourceToken, uint256 redeemAmount) internal returns (uint256 sourceAmount) {
        uint256[] memory amounts = new uint[](1);
        amounts[0] = redeemAmount;
        sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, UBO, amounts);

        address sourceTarget;

        if (sourceToken == UBO || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function redeemUBO(address sourceToken, uint256 redeemAmount) internal {
        vm.assume(redeemAmount < (IERC20(UBO).balanceOf(SUSHI_BENTO) * 90) / 100);

        uint256 projectIndex = randomish(projects.length);
        address specificProject = projects[projectIndex];

        address[] memory projectRedeem = new address[](1);
        uint256[] memory amountRedeem = new uint[](1);

        projectRedeem[0] = specificProject;
        amountRedeem[0] = redeemAmount;

        uint256 sourceAmount = getSourceTokens(sourceToken, redeemAmount);

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

            // Update redeemedAmount if source was not UBO, since you can't swap to an exact amount in Trident.
            if (sourceToken != UBO) redeemAmount = amounts[0];

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
