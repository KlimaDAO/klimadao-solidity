pragma solidity ^0.8.16;

import {RetireSourceFacet} from "../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../src/infinity/libraries/LibRetire.sol";
import {LibKlima} from "../../src/infinity/libraries/LibKlima.sol";
import {LibToucanCarbon} from "../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import {LibTransfer} from "../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../src/infinity/interfaces/IToucan.sol";

import "./TestHelper.sol";
import "../helpers/AssertionHelper.sol";

import {console2} from "../../lib/forge-std/src/console2.sol";

contract retireExactSourceSpecificToucan is TestHelper, AssertionHelper {
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address SUSHI_LP = vm.envAddress("SUSHI_BCT_LP");

    // Addresses pulled from current diamond constants
    address USDC;
    address KLIMA;
    address BCT;

    // Other static values for fee calcs
    uint256 feeDivider = 10_000;
    uint256 bctRedeemFee = 2500;
    uint256 infinityFee = 100;

    function setUp() public {
        addConstantsGetter(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        BCT = constantsFacet.bct();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
        closeRetirementBonds(constantsFacet.klimaRetirementBond());
        // fundRetirementBonds(constantsFacet.klimaRetirementBond());
    }

    function test_infinity_retirementQuoter_defaultRetire_noBonds_USDC(uint256 amount) public {
        vm.assume(amount > 0 && amount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);

        // Account for fees
        uint256 totalCarbon = amount + ((amount * infinityFee) / feeDivider);

        uint256 swapResult = quoterFacet.getSourceAmountSwapOnly(USDC, BCT, totalCarbon);
        uint256 retireResult = quoterFacet.getSourceAmountDefaultRetirement(USDC, BCT, amount);

        assertEq(swapResult, retireResult);
    }

    function test_infinity_retirementQuoter_defaultRetire_noBonds_KLIMA(uint256 amount) public {
        vm.assume(amount > 0 && amount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);

        // Account for fees
        uint256 totalCarbon = amount + ((amount * infinityFee) / feeDivider);

        uint256 swapResult = quoterFacet.getSourceAmountSwapOnly(KLIMA, BCT, totalCarbon);
        uint256 retireResult = quoterFacet.getSourceAmountDefaultRetirement(KLIMA, BCT, amount);

        assertEq(swapResult, retireResult);
    }

    function test_infinity_retirementQuoter_defaultRetire_withBonds_USDC(uint256 amount) public {
        vm.assume(amount > 0 && amount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());

        // Account for fees
        uint256 totalCarbon = amount + ((amount * infinityFee) / feeDivider);

        uint256 swapResult = quoterFacet.getSourceAmountSwapOnly(USDC, BCT, totalCarbon);
        uint256 retireResult = quoterFacet.getSourceAmountDefaultRetirement(USDC, BCT, amount);

        assert(swapResult >= retireResult);
    }

    function test_infinity_retirementQuoter_defaultRetire_withBonds_KLIMA(uint256 amount) public {
        vm.assume(amount > 0 && amount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());

        // Account for fees
        uint256 totalCarbon = amount + ((amount * infinityFee) / feeDivider);

        uint256 swapResult = quoterFacet.getSourceAmountSwapOnly(KLIMA, BCT, totalCarbon);
        uint256 retireResult = quoterFacet.getSourceAmountDefaultRetirement(KLIMA, BCT, amount);

        assert(swapResult >= retireResult);
    }

    function test_infinity_retirementQuoter_specificRetire_noBonds_USDC(uint256 amount) public {
        vm.assume(amount > 0 && amount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);

        // Account for fees
        uint256 totalCarbon = amount + ((amount * infinityFee) / feeDivider)
            + (((amount * feeDivider) / (feeDivider - bctRedeemFee)) - amount);

        uint256 swapResult = quoterFacet.getSourceAmountSwapOnly(USDC, BCT, totalCarbon);
        uint256 retireResult = quoterFacet.getSourceAmountSpecificRetirement(USDC, BCT, amount);

        assertEq(swapResult, retireResult);
    }

    function test_infinity_retirementQuoter_specificRetire_noBonds_KLIMA(uint256 amount) public {
        vm.assume(amount > 0 && amount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);

        // Account for fees
        uint256 totalCarbon = amount + ((amount * infinityFee) / feeDivider)
            + (((amount * feeDivider) / (feeDivider - bctRedeemFee)) - amount);

        uint256 swapResult = quoterFacet.getSourceAmountSwapOnly(KLIMA, BCT, totalCarbon);
        uint256 retireResult = quoterFacet.getSourceAmountSpecificRetirement(KLIMA, BCT, amount);

        assertEq(swapResult, retireResult);
    }

    function test_infinity_retirementQuoter_specificRetire_withBonds_USDC(uint256 amount) public {
        vm.assume(amount > 0 && amount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());

        // Account for fees
        uint256 totalCarbon = amount + ((amount * infinityFee) / feeDivider)
            + (((amount * feeDivider) / (feeDivider - bctRedeemFee)) - amount);

        uint256 swapResult = quoterFacet.getSourceAmountSwapOnly(USDC, BCT, totalCarbon);
        uint256 retireResult = quoterFacet.getSourceAmountSpecificRetirement(USDC, BCT, amount);

        assert(swapResult >= retireResult);
    }

    function test_infinity_retirementQuoter_specificRetire_withBonds_KLIMA(uint256 amount) public {
        vm.assume(amount > 0 && amount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());

        // Account for fees
        uint256 totalCarbon = amount + ((amount * infinityFee) / feeDivider)
            + (((amount * feeDivider) / (feeDivider - bctRedeemFee)) - amount);

        uint256 swapResult = quoterFacet.getSourceAmountSwapOnly(KLIMA, BCT, totalCarbon);
        uint256 retireResult = quoterFacet.getSourceAmountSpecificRetirement(KLIMA, BCT, amount);

        assert(swapResult >= retireResult);
    }
}
