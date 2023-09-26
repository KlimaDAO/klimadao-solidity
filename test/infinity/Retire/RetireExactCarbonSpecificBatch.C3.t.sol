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

    function test_infinity_retireExactCarbonSpecificBatch_UBO_UBO(uint256 retireAmount, uint256 retireAmount2) public {
        retireExactC3(UBO, UBO, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonSpecificBatchBatch_UBO_USDC(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactC3(USDC, UBO, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonSpecificBatch_UBO_KLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactC3(KLIMA, UBO, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonSpecificBatch_UBO_SKLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactC3(SKLIMA, UBO, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonSpecificBatch_UBO_WSKLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactC3(WSKLIMA, UBO, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonSpecificBatch_NBO_NBO(uint256 retireAmount, uint256 retireAmount2) public {
        retireExactC3(NBO, NBO, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonSpecificBatch_NBO_USDC(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactC3(USDC, NBO, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonSpecificBatch_NBO_KLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactC3(KLIMA, NBO, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonSpecificBatch_NBO_SKLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactC3(SKLIMA, NBO, retireAmount, retireAmount2);
    }

    function test_infinity_retireExactCarbonSpecificBatch_NBO_WSKLIMA(uint256 retireAmount, uint256 retireAmount2)
        public
    {
        retireExactC3(WSKLIMA, NBO, retireAmount, retireAmount2);
    }

    function getSourceTokens(address sourceToken, address poolToken, uint256 retireAmount)
        internal
        returns (uint256 sourceAmount)
    {
        sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, poolToken, retireAmount);

        address sourceTarget;

        if (sourceToken == UBO || sourceToken == NBO || sourceToken == USDC) sourceTarget = KLIMA_TREASURY;
        else if (sourceToken == KLIMA || sourceToken == SKLIMA) sourceTarget = STAKING;
        else if (sourceToken == WSKLIMA) sourceTarget = WSKLIMA_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function retireExactC3(address sourceToken, address poolToken, uint256 retireAmount, uint256 retireAmount2)
        public
    {
        vm.assume(retireAmount < (IERC20(poolToken).balanceOf(SUSHI_BENTO) * 40) / 100);
        vm.assume(retireAmount2 < (IERC20(poolToken).balanceOf(SUSHI_BENTO) * 40) / 100);

        uint256 sourceAmount = getSourceTokens(sourceToken, poolToken, retireAmount + retireAmount2);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken1 =
            poolToken == UBO ? projectsUBO[randomish(projectsUBO.length)] : projectsNBO[randomish(projectsNBO.length)];
        address projectToken2 = poolToken == UBO
            ? projectsUBO[randomish(projectsUBO.length, 69_420)]
            : projectsNBO[randomish(projectsNBO.length, 69_420)];
        uint256 poolBalance1 = IERC20(projectToken1).balanceOf(poolToken);
        uint256 poolBalance2 = IERC20(projectToken2).balanceOf(poolToken);

        RetireCarbonFacet.RetirementDetails[] memory batch = new RetireCarbonFacet.RetirementDetails[](2);

        batch[0].poolToken = poolToken;
        batch[0].projectToken = projectToken1;
        batch[0].retireAmount = retireAmount;
        batch[0].retiringEntityString = entity;
        batch[0].beneficiaryAddress = beneficiaryAddress;
        batch[0].beneficiaryString = beneficiary;
        batch[0].retirementMessage = message;

        batch[1].poolToken = poolToken;
        batch[1].projectToken = projectToken2;
        batch[1].retireAmount = retireAmount2;
        batch[1].retiringEntityString = entity;
        batch[1].beneficiaryAddress = beneficiaryAddress;
        batch[1].beneficiaryString = beneficiary;
        batch[1].retirementMessage = message;

        if (retireAmount > poolBalance1 || retireAmount2 > poolBalance2 || retireAmount == 0 || retireAmount2 == 0) {
            vm.expectRevert();

            retireCarbonFacet.retireExactCarbonSpecificBatch(
                batch, sourceToken, poolToken, sourceAmount, LibTransfer.From.EXTERNAL
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
                batch[0].projectToken,
                batch[0].retireAmount
            );

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
                batch[1].projectToken,
                batch[1].retireAmount
            );

            retireCarbonFacet.retireExactCarbonSpecificBatch(
                batch, sourceToken, poolToken, sourceAmount, LibTransfer.From.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(poolToken, diamond);
            assertZeroTokenBalance(batch[0].projectToken, diamond);
            assertZeroTokenBalance(batch[1].projectToken, diamond);

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
