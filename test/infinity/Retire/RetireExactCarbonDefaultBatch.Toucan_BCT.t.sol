pragma solidity ^0.8.16;

import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibToucanCarbon} from "../../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RetireExactCarbonDefaultBatchToucanBCT is TestHelper, AssertionHelper {
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
    address SUSHI_LP = vm.envAddress("SUSHI_BCT_LP");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address BCT;
    address DEFAULT_PROJECT;

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
        BCT = constantsFacet.bct();

        DEFAULT_PROJECT = IToucanPool(BCT).getScoredTCO2s()[0];

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());
    }

    function test_infinity_retireExactCarbonDefaultBatch_BCT_BCT(uint256 retireAmount, uint256 retireAmount2) public {
        retireExactBCT(BCT, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonDefaultBatch_BCT_USDC(uint256 retireAmount, uint256 retireAmount2) public {
        retireExactBCT(USDC, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonDefaultBatch_BCT_KLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactBCT(KLIMA, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonDefaultBatch_BCT_SKLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactBCT(SKLIMA, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonDefaultBatch_BCT_WSKLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactBCT(WSKLIMA, retireAmount, retireAmount2);
    }

    function getSourceTokens(address sourceToken, uint256 retireAmount) internal returns (uint256 sourceAmount) {
        /// @dev getting trade amount on zero output will revert
        if (retireAmount == 0 && sourceToken != BCT) vm.expectRevert();

        sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, BCT, retireAmount);

        address sourceTarget;

        if (sourceToken == BCT || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function retireExactBCT(address sourceToken, uint256 retireAmount, uint256 retireAmount2) public {
        vm.assume(retireAmount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);
        vm.assume(retireAmount2 < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);
        vm.assume(retireAmount + retireAmount2 <= IERC20(DEFAULT_PROJECT).balanceOf(BCT));

        uint256 sourceAmount = getSourceTokens(sourceToken, retireAmount + retireAmount2);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        RetireCarbonFacet.RetirementDetails[] memory batch = new RetireCarbonFacet.RetirementDetails[](2);

        batch[0].poolToken = BCT;
        batch[0].retireAmount = retireAmount;
        batch[0].retiringEntityString = entity;
        batch[0].beneficiaryAddress = beneficiaryAddress;
        batch[0].beneficiaryString = beneficiary;
        batch[0].retirementMessage = message;

        batch[1].poolToken = BCT;
        batch[1].retireAmount = retireAmount2;
        batch[1].retiringEntityString = entity;
        batch[1].beneficiaryAddress = beneficiaryAddress;
        batch[1].beneficiaryString = beneficiary;
        batch[1].retirementMessage = message;

        if (retireAmount == 0 || retireAmount2 == 0) {
            vm.expectRevert();

            retireCarbonFacet.retireExactCarbonDefaultBatch(
                batch, sourceToken, BCT, sourceAmount, LibTransfer.From.EXTERNAL
            );
        } else {
            // Set up expectEmit
            vm.expectEmit(true, true, true, true);

            // Emit expected CarbonRetired event
            emit LibToucanCarbon.CarbonRetired(
                LibRetire.CarbonBridge.TOUCAN,
                address(this),
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                BCT,
                DEFAULT_PROJECT,
                retireAmount
            );

            vm.expectEmit(true, true, true, true);
            emit LibToucanCarbon.CarbonRetired(
                LibRetire.CarbonBridge.TOUCAN,
                address(this),
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                BCT,
                DEFAULT_PROJECT,
                retireAmount2
            );

            retireCarbonFacet.retireExactCarbonDefaultBatch(
                batch, sourceToken, BCT, sourceAmount, LibTransfer.From.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(BCT, diamond);
            assertZeroTokenBalance(DEFAULT_PROJECT, diamond);

            // Return value matches
            // assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 2);
            assertEq(
                LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount + retireAmount2
            );
        }
    }
}
