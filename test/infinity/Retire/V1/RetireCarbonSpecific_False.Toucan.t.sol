pragma solidity ^0.8.16;

import {RetireSourceFacet} from "../../../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../../src/infinity/libraries/LibRetire.sol";
import {LibKlima} from "../../../../src/infinity/libraries/LibKlima.sol";
import {LibToucanCarbon} from "../../../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import {LibTransfer} from "../../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../../src/infinity/interfaces/IToucan.sol";
import {KlimaRetirementAggregator} from "../../../../src/retirement_v1/KlimaRetirementAggregator.sol";

import "../../TestHelper.sol";
import "../../../helpers/AssertionHelper.sol";

import {console2} from "../../../../lib/forge-std/src/console2.sol";

contract retireCarbonSpecificFalseToucan is TestHelper, AssertionHelper {
    RetireSourceFacet retireSourceFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;
    KlimaRetirementAggregator aggregatorV1;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "KlimaDAO Retirement Aggregator";

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address aggregatorV1Address = vm.envAddress("RETIREMENT_V1_ADDRESS");
    address WSKLIMA_HOLDER = vm.envAddress("WSKLIMA_HOLDER");
    address SUSHI_BENTO = vm.envAddress("SUSHI_BENTO");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address BCT;
    address NCT;
    address[] bctProjects;
    address[] nctProjects;

    function setUp() public {
        addConstantsGetter(diamond);
        retireSourceFacet = RetireSourceFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);
        aggregatorV1 = KlimaRetirementAggregator(aggregatorV1Address);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        BCT = constantsFacet.bct();
        NCT = constantsFacet.nct();

        bctProjects = IToucanPool(BCT).getScoredTCO2s();
        nctProjects = IToucanPool(NCT).getScoredTCO2s();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());
    }

    function test_infinity_v1_retireCarbonSpecific_False_BCT_BCT(uint256 retireAmount) public {
        retireExactSource(BCT, BCT, retireAmount);
        retireExactSourceWithEntity(BCT, BCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_False_BCT_USDC(uint256 retireAmount) public {
        retireExactSource(USDC, BCT, retireAmount);
        retireExactSourceWithEntity(USDC, BCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_False_BCT_KLIMA(uint256 retireAmount) public {
        retireExactSource(KLIMA, BCT, retireAmount);
        retireExactSourceWithEntity(KLIMA, BCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_False_BCT_SKLIMA(uint256 retireAmount) public {
        retireExactSource(SKLIMA, BCT, retireAmount);
        retireExactSourceWithEntity(SKLIMA, BCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_False_BCT_WSKLIMA(uint256 retireAmount) public {
        retireExactSource(WSKLIMA, BCT, retireAmount);
        retireExactSourceWithEntity(WSKLIMA, BCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_False_NCT_NCT(uint256 retireAmount) public {
        retireExactSource(NCT, NCT, retireAmount);
        retireExactSourceWithEntity(NCT, NCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_False_NCT_USDC(uint256 retireAmount) public {
        retireExactSource(USDC, NCT, retireAmount);
        retireExactSourceWithEntity(USDC, NCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_False_NCT_KLIMA(uint256 retireAmount) public {
        retireExactSource(KLIMA, NCT, retireAmount);
        retireExactSourceWithEntity(KLIMA, NCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_False_NCT_SKLIMA(uint256 retireAmount) public {
        retireExactSource(SKLIMA, NCT, retireAmount);
        retireExactSourceWithEntity(SKLIMA, NCT, retireAmount);
    }

    function test_infinity_v1_retireCarbonSpecific_False_NCT_WSKLIMA(uint256 retireAmount) public {
        retireExactSource(WSKLIMA, NCT, retireAmount);
        retireExactSourceWithEntity(WSKLIMA, NCT, retireAmount);
    }

    function getSourceTokens(address sourceToken, uint256 sourceAmount) internal {
        address sourceTarget;

        /// @dev Setting minimum amount assumptions due to issues with Trident performing swaps with zero output tokens.
        vm.assume(sourceAmount > 1e4);

        if (sourceToken == BCT || sourceToken == NCT || sourceToken == USDC) {
            sourceTarget = KLIMA_TREASURY;
        } else if (sourceToken == KLIMA || sourceToken == SKLIMA) {
            sourceTarget = STAKING;
        } else if (sourceToken == WSKLIMA) {
            vm.assume(sourceAmount > LibKlima.toWrappedAmount(1e6));
            sourceTarget = WSKLIMA_HOLDER;
        }

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(aggregatorV1Address, sourceAmount);
    }

    function retireExactSource(address sourceToken, address poolToken, uint256 sourceAmount) public {
        getSourceTokens(sourceToken, sourceAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken =
            poolToken == BCT ? bctProjects[randomish(bctProjects.length)] : nctProjects[randomish(nctProjects.length)];
        address[] memory projectTokens = new address[](1);
        projectTokens[0] = projectToken;

        uint256 retireAmount = quoterFacet.getRetireAmountSourceSpecific(sourceToken, poolToken, sourceAmount);
        uint256 poolAmount = IERC20(projectToken).balanceOf(poolToken);

        if (retireAmount > poolAmount || sourceAmount == 0) {
            vm.expectRevert();
            aggregatorV1.retireCarbonSpecific(
                sourceToken, poolToken, sourceAmount, false, beneficiaryAddress, beneficiary, message, projectTokens
            );
        } else {
            aggregatorV1.retireCarbonSpecific(
                sourceToken, poolToken, sourceAmount, false, beneficiaryAddress, beneficiary, message, projectTokens
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(sourceToken, aggregatorV1Address);
            assertZeroTokenBalance(poolToken, diamond);
            assertZeroTokenBalance(poolToken, aggregatorV1Address);
            assertZeroTokenBalance(projectToken, diamond);
            assertZeroTokenBalance(projectToken, aggregatorV1Address);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);

            // Since the output from Trident isn't deterministic until the swap happens, check an approximation.
            assertApproxEqRel(
                LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount, 1e17
            );
        }
    }

    function retireExactSourceWithEntity(address sourceToken, address poolToken, uint256 sourceAmount) public {
        getSourceTokens(sourceToken, sourceAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        address projectToken =
            poolToken == BCT ? bctProjects[randomish(bctProjects.length)] : nctProjects[randomish(nctProjects.length)];
        address[] memory projectTokens = new address[](1);
        projectTokens[0] = projectToken;

        (, uint256 retireAmount) = aggregatorV1.getSourceAmountSpecific(sourceToken, poolToken, sourceAmount, false);
        uint256 poolAmount = IERC20(projectToken).balanceOf(poolToken);

        if (retireAmount > poolAmount || sourceAmount == 0) {
            vm.expectRevert();
            aggregatorV1.retireCarbonSpecific(
                sourceToken, poolToken, sourceAmount, false, beneficiaryAddress, beneficiary, message, projectTokens
            );
        } else {
            aggregatorV1.retireCarbonSpecific(
                sourceToken,
                poolToken,
                sourceAmount,
                false,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                projectTokens
            );

            // No tokens left in contract
            assertZeroTokenBalance(sourceToken, diamond);
            assertZeroTokenBalance(sourceToken, aggregatorV1Address);
            assertZeroTokenBalance(poolToken, diamond);
            assertZeroTokenBalance(poolToken, aggregatorV1Address);
            assertZeroTokenBalance(projectToken, diamond);
            assertZeroTokenBalance(projectToken, aggregatorV1Address);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);

            // Since the output from Trident isn't deterministic until the swap happens, check an approximation.
            assertApproxEqRel(
                LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount, 1e17
            );
        }
    }
}
