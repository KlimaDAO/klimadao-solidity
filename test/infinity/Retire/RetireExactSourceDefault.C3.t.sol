pragma solidity ^0.8.16;

import {RetireSourceFacet} from "../../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibKlima} from "../../../src/infinity/libraries/LibKlima.sol";
import {LibC3Carbon} from "../../../src/infinity/libraries/Bridges/LibC3Carbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IC3Pool} from "../../../src/infinity/interfaces/IC3.sol";
import {ITridentPool} from "../../../src/infinity/interfaces/ITrident.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract retireExactSourceDefaultC3 is TestHelper, AssertionHelper {
    RetireSourceFacet retireSourceFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

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
    address NBO;
    address DEFAULT_PROJECT_UBO;
    address DEFAULT_PROJECT_NBO;

    function setUp() public {
        addConstantsGetter(diamond);
        retireSourceFacet = RetireSourceFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        UBO = constantsFacet.ubo();
        NBO = constantsFacet.nbo();

        DEFAULT_PROJECT_UBO = IC3Pool(UBO).getFreeRedeemAddresses()[0];
        DEFAULT_PROJECT_NBO = IC3Pool(NBO).getFreeRedeemAddresses()[0];

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_retireExactSourceDefault_UBO_UBO(uint retireAmount) public {
        retireExactSource(UBO, UBO, retireAmount);
    }

    function test_retireExactSourceDefault_UBO_USDC(uint retireAmount) public {
        retireExactSource(USDC, UBO, retireAmount);
    }

    function test_retireExactSourceDefault_UBO_KLIMA(uint retireAmount) public {
        retireExactSource(KLIMA, UBO, retireAmount);
    }

    function test_retireExactSourceDefault_UBO_SKLIMA(uint retireAmount) public {
        retireExactSource(SKLIMA, UBO, retireAmount);
    }

    function test_retireExactSourceDefault_UBO_WSKLIMA(uint retireAmount) public {
        retireExactSource(WSKLIMA, UBO, retireAmount);
    }

    function test_retireExactSourceDefault_NBO_NBO(uint retireAmount) public {
        retireExactSource(NBO, NBO, retireAmount);
    }

    function test_retireExactSourceDefault_NBO_USDC(uint retireAmount) public {
        retireExactSource(USDC, NBO, retireAmount);
    }

    function test_retireExactSourceDefault_NBO_KLIMA(uint retireAmount) public {
        retireExactSource(KLIMA, NBO, retireAmount);
    }

    function test_retireExactSourceDefault_NBO_SKLIMA(uint retireAmount) public {
        retireExactSource(SKLIMA, NBO, retireAmount);
    }

    function test_retireExactSourceDefault_NBO_WSKLIMA(uint retireAmount) public {
        retireExactSource(WSKLIMA, NBO, retireAmount);
    }

    function getSourceTokens(address sourceToken, uint sourceAmount) internal {
        address sourceTarget;

        /// @dev Setting minimum amount assumptions due to issues with Trident performing swaps with zero output tokens.
        vm.assume(sourceAmount > 1e4);

        if (sourceToken == UBO || sourceToken == NBO || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) {
            vm.assume(sourceAmount > LibKlima.toWrappedAmount(1e6));
            sourceTarget = WSKLIMA_HOLDER;
        }

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function retireExactSource(address sourceToken, address poolToken, uint sourceAmount) public {
        getSourceTokens(sourceToken, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken = poolToken == UBO ? DEFAULT_PROJECT_UBO : DEFAULT_PROJECT_NBO;
        uint poolBalance = IERC20(projectToken).balanceOf(poolToken);

        uint retireAmount = quoterFacet.getRetireAmountSourceDefault(sourceToken, poolToken, sourceAmount);

        if (retireAmount > poolBalance || sourceAmount == 0) {
            vm.expectRevert();
            retireSourceFacet.retireExactSourceDefault(
                sourceToken,
                poolToken,
                sourceAmount,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                LibTransfer.From.EXTERNAL
            );
        } else {
            uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(
                sourceToken,
                poolToken,
                sourceAmount,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                LibTransfer.From.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(poolToken, diamond);
            assertZeroTokenBalance(projectToken, diamond);

            // Return value matches
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);

            // Since the output from Trident isn't deterministic until the swap happens, check an approximation.
            assertApproxEqRel(
                LibRetire.getTotalCarbonRetired(beneficiaryAddress),
                currentTotalCarbon + retireAmount,
                1e16
            );
        }
    }
}
