pragma solidity ^0.8.16;

import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibMossCarbon} from "../../../src/infinity/libraries/Bridges/LibMossCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RetireExactCarbonDefaultBatchMoss is TestHelper, AssertionHelper {
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
        retireCarbonFacet = RetireCarbonFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        MCO2 = constantsFacet.mco2();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());
    }

    function test_infinity_retireExactCarbonDefaultBatch_MCO2_MCO2(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactMoss(MCO2, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonDefaultBatch_MCO2_USDC(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactMoss(USDC, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonDefaultBatch_MCO2_KLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactMoss(KLIMA, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonDefaultBatch_MCO2_SKLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactMoss(SKLIMA, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonDefaultBatch_MCO2_WSKLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactMoss(WSKLIMA, retireAmount, retireAmount2);
    }

    function getSourceTokens(address sourceToken, uint256 retireAmount) internal returns (uint256 sourceAmount) {
        /// @dev getting trade amount on zero output will revert
        if (retireAmount == 0 && sourceToken != MCO2) vm.expectRevert();
        sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, MCO2, retireAmount);

        address sourceTarget;

        if (sourceToken == MCO2 || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function retireExactMoss(address sourceToken, uint256 retireAmount, uint256 retireAmount2) public {
        vm.assume(retireAmount < (IERC20(MCO2).balanceOf(QUICKSWAP_LP) * 40) / 100);
        vm.assume(retireAmount2 < (IERC20(MCO2).balanceOf(QUICKSWAP_LP) * 40) / 100);
        uint256 sourceAmount = getSourceTokens(sourceToken, retireAmount + retireAmount2);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        RetireCarbonFacet.RetirementDetails[] memory batch = new RetireCarbonFacet.RetirementDetails[](2);

        batch[0].poolToken = MCO2;
        batch[0].retireAmount = retireAmount;
        batch[0].retiringEntityString = entity;
        batch[0].beneficiaryAddress = beneficiaryAddress;
        batch[0].beneficiaryString = beneficiary;
        batch[0].retirementMessage = message;

        batch[1].poolToken = MCO2;
        batch[1].retireAmount = retireAmount2;
        batch[1].retiringEntityString = entity;
        batch[1].beneficiaryAddress = beneficiaryAddress;
        batch[1].beneficiaryString = beneficiary;
        batch[1].retirementMessage = message;

        if (retireAmount == 0 || retireAmount2 == 0) {
            vm.expectRevert();

            retireCarbonFacet.retireExactCarbonDefaultBatch(
                batch, sourceToken, MCO2, sourceAmount, LibTransfer.From.EXTERNAL
            );
        } else {
            // Set up expectEmit
            vm.expectEmit(true, true, true, true);

            // Emit expected CarbonRetired event
            emit LibMossCarbon.CarbonRetired(
                LibRetire.CarbonBridge.MOSS,
                address(this),
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                MCO2,
                address(0),
                batch[0].retireAmount
            );

            // Set up expectEmit
            vm.expectEmit(true, true, true, true);

            // Emit expected CarbonRetired event
            emit LibMossCarbon.CarbonRetired(
                LibRetire.CarbonBridge.MOSS,
                address(this),
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                MCO2,
                address(0),
                batch[1].retireAmount
            );

            retireCarbonFacet.retireExactCarbonDefaultBatch(
                batch, sourceToken, MCO2, sourceAmount, LibTransfer.From.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(MCO2, diamond);

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
