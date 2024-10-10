pragma solidity ^0.8.16;

import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibC3Carbon} from "../../../src/infinity/libraries/Bridges/LibC3Carbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IC3Pool} from "../../../src/infinity/interfaces/IC3.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RetireExactCarbonDefaultC3 is TestHelper, AssertionHelper {
    RetireCarbonFacet retireCarbonFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address SUSHI_UBO_LP = vm.envAddress("SUSHI_UBO_LP");
    address SUSHI_NBO_LP = vm.envAddress("SUSHI_NBO_LP");

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
        retireCarbonFacet = RetireCarbonFacet(diamond);
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

        DEFAULT_PROJECT_UBO = getDefaultC3Project(UBO);
        DEFAULT_PROJECT_NBO = getDefaultC3Project(NBO);

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_retireExactCarbonDefault_UBO_UBO(uint256 retireAmount) public {
        retireExactC3(UBO, UBO, retireAmount, SUSHI_UBO_LP);
    }

    function test_infinity_retireExactCarbonDefault_UBO_USDC(uint256 retireAmount) public {
        retireExactC3(USDC, UBO, retireAmount, SUSHI_UBO_LP);
    }

    function test_infinity_retireExactCarbonDefault_UBO_KLIMA(uint256 retireAmount) public {
        retireExactC3(KLIMA, UBO, retireAmount, SUSHI_UBO_LP);
    }

    function test_infinity_retireExactCarbonDefault_UBO_SKLIMA(uint256 retireAmount) public {
        retireExactC3(SKLIMA, UBO, retireAmount, SUSHI_UBO_LP);
    }

    function test_infinity_retireExactCarbonDefault_UBO_WSKLIMA(uint256 retireAmount) public {
        retireExactC3(WSKLIMA, UBO, retireAmount, SUSHI_UBO_LP);
    }

    function test_infinity_retireExactCarbonDefault_NBO_NBO(uint256 retireAmount) public {
        retireExactC3(NBO, NBO, retireAmount, SUSHI_NBO_LP);
    }

    function test_infinity_retireExactCarbonDefault_NBO_USDC(uint256 retireAmount) public {
        retireExactC3(USDC, NBO, retireAmount, SUSHI_NBO_LP);
    }

    function test_infinity_retireExactCarbonDefault_NBO_KLIMA(uint256 retireAmount) public {
        retireExactC3(KLIMA, NBO, retireAmount, SUSHI_NBO_LP);
    }

    function test_infinity_retireExactCarbonDefault_NBO_SKLIMA(uint256 retireAmount) public {
        retireExactC3(SKLIMA, NBO, retireAmount, SUSHI_NBO_LP);
    }

    function test_infinity_retireExactCarbonDefault_NBO_WSKLIMA(uint256 retireAmount) public {
        retireExactC3(WSKLIMA, NBO, retireAmount, SUSHI_NBO_LP);
    }

    function retireExactC3(address sourceToken, address poolToken, uint256 retireAmount, address lpPool) public {
        vm.assume(retireAmount < (IERC20(poolToken).balanceOf(lpPool) * 90) / 100);

        if (retireAmount == 0 && sourceToken != poolToken) vm.expectRevert();
        uint256 sourceAmount =
            getSourceTokens(TransactionType.DEFAULT_RETIRE, diamond, sourceToken, poolToken, retireAmount);
        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken = poolToken == UBO ? DEFAULT_PROJECT_UBO : DEFAULT_PROJECT_NBO;
        uint256 poolBalance = IERC20(projectToken).balanceOf(poolToken);

        console.log("Trident router to use %s", constantsFacet.sushiTridentRouter());

        if (retireAmount > poolBalance || retireAmount == 0) {
            vm.expectRevert();

            retireCarbonFacet.retireExactCarbonDefault(
                sourceToken,
                poolToken,
                sourceAmount,
                retireAmount,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                LibTransfer.From.EXTERNAL
            );
        } else {
            // Set up expectEmit
            vm.expectEmit(true, true, true, true);

            // Emit expected CarbonRetired event
            emit LibC3Carbon.CarbonRetired(
                LibRetire.CarbonBridge.C3,
                address(this),
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                poolToken,
                projectToken,
                retireAmount
            );

            uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(
                sourceToken,
                poolToken,
                sourceAmount,
                retireAmount,
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
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }
}
