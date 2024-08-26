pragma solidity ^0.8.16;

import {RetireSourceFacet} from "../../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibKlima} from "../../../src/infinity/libraries/LibKlima.sol";
import {LibToucanCarbon} from "../../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract retireExactSourceSpecificToucan is TestHelper, AssertionHelper {
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
    address BCT;
    address NCT;
    address[] projectsBCT;
    address[] projectsNCT;

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
        BCT = constantsFacet.bct();
        NCT = constantsFacet.nct();

        projectsBCT = IToucanPool(BCT).getScoredTCO2s();
        projectsNCT = IToucanPool(NCT).getScoredTCO2s();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_retireExactSourceSpecific_BCT_BCT(uint256 retireAmount) public {
        retireExactSource(BCT, BCT, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_BCT_USDC(uint256 retireAmount) public {
        retireExactSource(USDC, BCT, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_BCT_KLIMA(uint256 retireAmount) public {
        retireExactSource(KLIMA, BCT, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_BCT_SKLIMA(uint256 retireAmount) public {
        retireExactSource(SKLIMA, BCT, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_BCT_WSKLIMA(uint256 retireAmount) public {
        retireExactSource(WSKLIMA, BCT, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NCT_NCT(uint256 retireAmount) public {
        retireExactSource(NCT, NCT, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NCT_USDC(uint256 retireAmount) public {
        retireExactSource(USDC, NCT, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NCT_KLIMA(uint256 retireAmount) public {
        retireExactSource(KLIMA, NCT, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NCT_SKLIMA(uint256 retireAmount) public {
        retireExactSource(SKLIMA, NCT, retireAmount);
    }

    function test_infinity_retireExactSourceSpecific_NCT_WSKLIMA(uint256 retireAmount) public {
        retireExactSource(WSKLIMA, NCT, retireAmount);
    }

    function retireExactSource(address sourceToken, address poolToken, uint256 sourceAmount) public {
        getSourceTokens(TransactionType.EXACT_SOURCE, diamond, sourceToken, poolToken, sourceAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken =
            poolToken == BCT ? projectsBCT[randomish(projectsBCT.length)] : projectsNCT[randomish(projectsNCT.length)];
        uint256 poolBalance = IERC20(projectToken).balanceOf(poolToken);

        uint256 unwrappedAmount = 1;

        if (sourceToken == WSKLIMA) {
            unwrappedAmount = IwsKLIMA(WSKLIMA).wKLIMATosKLIMA(sourceAmount);
        }

        if ((sourceAmount == 0 && sourceToken != poolToken) || unwrappedAmount == 0) vm.expectRevert();
        uint256 retireAmount = quoterFacet.getRetireAmountSourceSpecific(sourceToken, poolToken, sourceAmount);

        if (
            (sourceAmount == 0 && sourceToken != poolToken) || retireAmount > poolBalance || sourceAmount == 0
                || unwrappedAmount == 0
        ) {
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
                LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount, 1e16
            );
        }
    }
}
