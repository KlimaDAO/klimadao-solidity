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

contract retireExactSourceSpecificC3 is TestHelper, AssertionHelper {
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

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address UBO;
    address NBO;
    address[] projectsUBO;
    address[] projectsNBO;

    function setUp() public {
        addConstantsGetter(diamond);
        retireSourceFacet = RetireSourceFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc_bridged();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        UBO = constantsFacet.ubo();
        NBO = constantsFacet.nbo();

        projectsUBO = IC3Pool(UBO).getERC20Tokens();
        projectsNBO = IC3Pool(NBO).getERC20Tokens();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_retireExactSourceSpecific_UBO_UBO(uint256 retireAmount) public {
        retireExactSource(UBO, UBO, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_UBO_USDC(uint256 retireAmount) public {
        retireExactSource(USDC, UBO, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_UBO_KLIMA(uint256 retireAmount) public {
        retireExactSource(KLIMA, UBO, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_UBO_SKLIMA(uint256 retireAmount) public {
        retireExactSource(SKLIMA, UBO, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_UBO_WSKLIMA(uint256 retireAmount) public {
        retireExactSource(WSKLIMA, UBO, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NBO_NBO(uint256 retireAmount) public {
        retireExactSource(NBO, NBO, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NBO_USDC(uint256 retireAmount) public {
        retireExactSource(USDC, NBO, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NBO_KLIMA(uint256 retireAmount) public {
        retireExactSource(KLIMA, NBO, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NBO_SKLIMA(uint256 retireAmount) public {
        retireExactSource(SKLIMA, NBO, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NBO_WSKLIMA(uint256 retireAmount) public {
        retireExactSource(WSKLIMA, NBO, retireAmount);
    }

    function retireExactSource(address sourceToken, address poolToken, uint256 sourceAmount) public {
        getSourceTokens(TransactionType.EXACT_SOURCE, diamond, sourceToken, poolToken, sourceAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken =
            poolToken == UBO ? projectsUBO[randomish(projectsUBO.length)] : projectsNBO[randomish(projectsNBO.length)];
        uint256 poolBalance = IERC20(projectToken).balanceOf(poolToken);

        uint256 unwrappedAmount = 1;

        if (sourceToken == WSKLIMA) {
            unwrappedAmount = IwsKLIMA(WSKLIMA).wKLIMATosKLIMA(sourceAmount);
        }

        if ((sourceAmount == 0 && sourceToken != poolToken) || unwrappedAmount == 0) vm.expectRevert();
        uint256 retireAmount = quoterFacet.getRetireAmountSourceDefault(sourceToken, poolToken, sourceAmount);
        vm.assume(retireAmount <= poolBalance);

        if ((sourceAmount == 0 && sourceToken != poolToken) || sourceAmount == 0 || unwrappedAmount == 0) {
            vm.expectRevert();
            retireSourceFacet.retireExactSourceSpecific(
                sourceToken,
                poolToken,
                projectToken,
                sourceAmount,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                LibTransfer.From.EXTERNAL
            );
        } else {
            uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(
                sourceToken,
                poolToken,
                projectToken,
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
                LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount, 5e16
            );
        }
    }
}
