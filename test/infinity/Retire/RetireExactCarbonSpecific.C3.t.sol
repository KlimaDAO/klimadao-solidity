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

contract RetireExactCarbonSpecificC3 is TestHelper, AssertionHelper {
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
    address[] projectsUBO;
    address[] projectsNBO;

    function setUp() public {
        addConstantsGetter(diamond);
        retireCarbonFacet = RetireCarbonFacet(diamond);
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

        projectsUBO = IC3Pool(UBO).getERC20Tokens();
        projectsNBO = IC3Pool(NBO).getERC20Tokens();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());
    }

    function test_retireExactCarbonSpecific_UBO_UBO(uint retireAmount) public {
        retireExactC3(UBO, UBO, retireAmount);
    }

    function test_retireExactCarbonSpecific_UBO_USDC(uint retireAmount) public {
        retireExactC3(USDC, UBO, retireAmount);
    }

    function test_retireExactCarbonSpecific_UBO_KLIMA(uint retireAmount) public {
        retireExactC3(KLIMA, UBO, retireAmount);
    }

    function test_retireExactCarbonSpecific_UBO_SKLIMA(uint retireAmount) public {
        retireExactC3(SKLIMA, UBO, retireAmount);
    }

    function test_retireExactCarbonSpecific_UBO_WSKLIMA(uint retireAmount) public {
        retireExactC3(WSKLIMA, UBO, retireAmount);
    }

    function test_retireExactCarbonSpecific_NBO_NBO(uint retireAmount) public {
        retireExactC3(NBO, NBO, retireAmount);
    }

    function test_retireExactCarbonSpecific_NBO_USDC(uint retireAmount) public {
        retireExactC3(USDC, NBO, retireAmount);
    }

    function test_retireExactCarbonSpecific_NBO_KLIMA(uint retireAmount) public {
        retireExactC3(KLIMA, NBO, retireAmount);
    }

    function test_retireExactCarbonSpecific_NBO_SKLIMA(uint retireAmount) public {
        retireExactC3(SKLIMA, NBO, retireAmount);
    }

    function test_retireExactCarbonSpecific_NBO_WSKLIMA(uint retireAmount) public {
        retireExactC3(WSKLIMA, NBO, retireAmount);
    }

    function getSourceTokens(
        address sourceToken,
        address poolToken,
        uint retireAmount
    ) internal returns (uint sourceAmount) {
        sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, poolToken, retireAmount);

        address sourceTarget;

        if (sourceToken == UBO || sourceToken == NBO || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function retireExactC3(address sourceToken, address poolToken, uint retireAmount) public {
        vm.assume(retireAmount < (IERC20(poolToken).balanceOf(SUSHI_BENTO) * 90) / 100);
        uint sourceAmount = getSourceTokens(sourceToken, poolToken, retireAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken = poolToken == UBO
            ? projectsUBO[randomish(projectsUBO.length)]
            : projectsNBO[randomish(projectsNBO.length)];
        uint poolBalance = IERC20(projectToken).balanceOf(poolToken);

        if (retireAmount > poolBalance || retireAmount == 0) {
            vm.expectRevert();

            retireCarbonFacet.retireExactCarbonSpecific(
                sourceToken,
                poolToken,
                projectToken,
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

            uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(
                sourceToken,
                poolToken,
                projectToken,
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
