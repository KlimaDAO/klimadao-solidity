pragma solidity ^0.8.16;

import {RetireSourceFacet} from "../../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibMossCarbon} from "../../../src/infinity/libraries/Bridges/LibMossCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RetireExactSourceDefaultMoss is TestHelper, AssertionHelper {
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
    address QUICKSWAP_LP = vm.envAddress("MCO2_QUICKSWAP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address MCO2;

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
        MCO2 = constantsFacet.mco2();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_retireExactSourceDefault_MCO2_MCO2(uint256 retireAmount) public {
        retireExactSource(MCO2, MCO2, retireAmount);
    }

    function test_infinity_retireExactSourceDefault_MCO2_USDC(uint256 retireAmount) public {
        retireExactSource(USDC, MCO2, retireAmount);
    }

    function test_infinity_retireExactSourceDefault_MCO2_KLIMA(uint256 retireAmount) public {
        retireExactSource(KLIMA, MCO2, retireAmount);
    }

    function test_infinity_retireExactSourceDefault_MCO2_SKLIMA(uint256 retireAmount) public {
        retireExactSource(SKLIMA, MCO2, retireAmount);
    }

    function test_infinity_retireExactSourceDefault_MCO2_WSKLIMA(uint256 retireAmount) public {
        retireExactSource(WSKLIMA, MCO2, retireAmount);
    }

    function retireExactSource(address sourceToken, address poolToken, uint256 sourceAmount) public {
        vm.assume(sourceAmount < (IERC20(MCO2).balanceOf(QUICKSWAP_LP) * 90) / 100);

        getSourceTokens(TransactionType.EXACT_SOURCE, diamond, sourceToken, poolToken, sourceAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint256 unwrappedAmount = 1;

        if (sourceToken == WSKLIMA) {
            unwrappedAmount = IwsKLIMA(WSKLIMA).wKLIMATosKLIMA(sourceAmount);
        }

        if ((sourceAmount == 0 && sourceToken != poolToken) || unwrappedAmount == 0) vm.expectRevert();
        uint256 retireAmount = quoterFacet.getRetireAmountSourceDefault(sourceToken, poolToken, sourceAmount);

        if (sourceAmount == 0 || unwrappedAmount == 0) {
            vm.expectRevert();

            retireSourceFacet.retireExactSourceDefault(
                sourceToken,
                MCO2,
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
                MCO2,
                sourceAmount,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                LibTransfer.From.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(MCO2, diamond);

            // Return value matches
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);

            // Since the output from Trident isn't deterministic until the swap happens, check an approximation.
            assertApproxEqRel(
                LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount, 1e19
            );
        }
    }
}
