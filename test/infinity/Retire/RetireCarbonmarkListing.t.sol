pragma solidity ^0.8.16;

import {RetireCarbonmarkFacet} from "../../../src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibToucanCarbon} from "../../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";
import {ICarbonmark} from "../../../src/infinity/interfaces/ICarbonmark.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RetireCarbonmarkListing is TestHelper, AssertionHelper {
    RetireCarbonmarkFacet retireCarbonmarkFacet;
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
    address PUBLIC_KEY = vm.envAddress("PUBLIC_KEY");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address STAKING;
    address USDC;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address BCT;
    address DEFAULT_PROJECT;
    address CARBONMARK;

    function setUp() public {
        addConstantsGetter(diamond);
        retireCarbonmarkFacet = RetireCarbonmarkFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC = constantsFacet.usdc_bridged();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        BCT = constantsFacet.bct();
        CARBONMARK = constantsFacet.carbonmark();

        DEFAULT_PROJECT = IToucanPool(BCT).getScoredTCO2s()[0];

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
        fundRetirementBonds(constantsFacet.klimaRetirementBond());
    }

    function test_infinity_retireCarbonmark_BCT() public {
        address TCO2 = 0xb139C4cC9D20A3618E9a2268D73Eff18C496B991;
        uint256 listingAmount = 1_250_000_000_000_000_000;
        // create listing
        swipeERC20Tokens(TCO2, listingAmount, PUBLIC_KEY, address(this));

        IERC20(TCO2).approve(CARBONMARK, listingAmount);

        bytes32 listingId =
            ICarbonmark(CARBONMARK).createListing(TCO2, listingAmount, 5_000_000, 1e17, block.timestamp + 3600);

        ICarbonmark.CreditListing memory listing =
            ICarbonmark.CreditListing(listingId, address(this), TCO2, 0, listingAmount, 5_000_000);

        retireExactBCT(listing, 5e17);
    }

    function getSourceTokens(bytes32 listingId, uint256 retireAmount) internal returns (uint256 sourceAmount) {
        vm.assume(retireAmount <= ICarbonmark(CARBONMARK).getRemainingAmount(listingId));

        sourceAmount = ICarbonmark(CARBONMARK).getUnitPrice(listingId) * retireAmount / 1e18;

        vm.assume(sourceAmount <= IERC20(USDC).balanceOf(KLIMA_TREASURY));

        swipeERC20Tokens(USDC, sourceAmount, KLIMA_TREASURY, address(this));
        IERC20(USDC).approve(diamond, sourceAmount);
    }

    function retireExactBCT(ICarbonmark.CreditListing memory listing, uint256 retireAmount) public {
        uint256 sourceAmount = getSourceTokens(listing.id, retireAmount);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        if (retireAmount == 0) {
            vm.expectRevert();

            retireCarbonmarkFacet.retireCarbonmarkListing(
                listing,
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
            emit LibToucanCarbon.CarbonRetired(
                LibRetire.CarbonBridge.TOUCAN,
                address(this),
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                address(0),
                DEFAULT_PROJECT,
                retireAmount
            );

            uint256 retirementIndex = retireCarbonmarkFacet.retireCarbonmarkListing(
                listing,
                sourceAmount,
                retireAmount,
                entity,
                beneficiaryAddress,
                beneficiary,
                message,
                LibTransfer.From.EXTERNAL
            );

            // No tokens left in contract
            assertZeroTokenBalance(USDC, diamond);
            assertZeroTokenBalance(BCT, diamond);
            assertZeroTokenBalance(DEFAULT_PROJECT, diamond);

            // Return value matches
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }
}
