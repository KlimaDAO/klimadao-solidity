pragma solidity ^0.8.16;

import {RedeemC3PoolFacet} from "../../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IC3Pool} from "../../../src/infinity/interfaces/IC3.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RedeemNBOSpecificTest is TestHelper, AssertionHelper {
    RedeemC3PoolFacet redeemC3PoolFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address SUSHI_LP = vm.envAddress("SUSHI_NBO_LP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address NBO;
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

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        NBO = constantsFacet.nbo();
        KLIMA_RETIREMENT_BOND = constantsFacet.klimaRetirementBond();

        projects = IC3Pool(NBO).getERC20Tokens();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemNBO_usingNBO_fuzz(uint256 redeemAmount) public {
        redeemNBO(NBO, redeemAmount);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemNBO_usingUSDC_fuzz(uint256 redeemAmount) public {
        redeemNBO(USDC, redeemAmount);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemNBO_usingKLIMA_fuzz(uint256 redeemAmount) public {
        redeemNBO(KLIMA, redeemAmount);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemNBO_usingSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemNBO(SKLIMA, redeemAmount);
    }

    function test_infinity_c3RedeemPoolSpecific_redeemNBO_usingWSKLIMA_fuzz(uint256 redeemAmount) public {
        redeemNBO(WSKLIMA, redeemAmount);
    }

    // function getSourceTokens(address sourceToken, uint redeemAmount) internal returns (uint sourceAmount) {
    //     uint[] memory amounts = new uint[](1);
    //     amounts[0] = redeemAmount;
    //     sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, NBO, amounts);

    //     address sourceTarget;

    //     if (sourceToken == NBO || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
    //     else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
    //     else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

    //     vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

    //     swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
    //     IERC20(sourceToken).approve(diamond, sourceAmount);
    // }

    function redeemNBO(address sourceToken, uint256 redeemAmount) internal {
        vm.assume(redeemAmount < (IERC20(NBO).balanceOf(SUSHI_LP) * 90) / 100);
        vm.assume(redeemAmount > 0);

        uint256 projectIndex = randomish(projects.length);
        address specificProject = projects[projectIndex];

        address[] memory projectRedeem = new address[](1);
        uint256[] memory amountRedeem = new uint256[](1);

        projectRedeem[0] = specificProject;
        amountRedeem[0] = redeemAmount;

        if (redeemAmount == 0 && sourceToken != NBO) vm.expectRevert();
        uint256 sourceAmount =
            getSourceTokens(TransactionType.SPECIFIC_REDEEM, address(redeemC3PoolFacet), sourceToken, NBO, redeemAmount);

        uint256 poolBalance = IERC20(specificProject).balanceOf(constantsFacet.nbo());
        uint256 bondBalance = IERC20(NBO).balanceOf(KLIMA_RETIREMENT_BOND);

        if (redeemAmount > poolBalance || redeemAmount == 0) {
            console.log("Balance greater than pool");
            vm.expectRevert();

            redeemC3PoolFacet.c3RedeemPoolSpecific(
                sourceToken,
                NBO,
                sourceAmount,
                projectRedeem,
                amountRedeem,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );
        } else {
            uint256[] memory amounts = redeemC3PoolFacet.c3RedeemPoolSpecific(
                sourceToken,
                NBO,
                sourceAmount,
                projectRedeem,
                amountRedeem,
                LibTransfer.From.EXTERNAL,
                LibTransfer.To.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(specificProject, diamond);
            assertZeroTokenBalance(NBO, diamond);

            // Retirement bonds were not used
            assertEq(bondBalance, IERC20(NBO).balanceOf(KLIMA_RETIREMENT_BOND));

            // Caller has default project tokens
            assertEq(redeemAmount, amounts[0]);
            assertEq(IERC20(specificProject).balanceOf(address(this)), amounts[0]);
        }
    }
}
