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

    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint256 tokenId,
        uint256 retiredAmount
    );

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
    address USDC_BRIDGED;
    address USDC_NATIVE;
    address KLIMA;
    address SKLIMA;
    address WSKLIMA;
    address BCT;
    address DEFAULT_PROJECT;
    address CARBONMARK;
    address PURO_PROJECT = 0x6960cE1d21f63C4971324B5b611c4De29aCF980C;
    uint256 PURO_TOKEN_ID = 1713;

    function setUp() public {
        addConstantsGetter(diamond);
        retireCarbonmarkFacet = RetireCarbonmarkFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        STAKING = constantsFacet.staking();

        USDC_BRIDGED = constantsFacet.usdc_bridged();
        USDC_NATIVE = constantsFacet.usdc();
        KLIMA = constantsFacet.klima();
        SKLIMA = constantsFacet.sKlima();
        WSKLIMA = constantsFacet.wsKlima();
        BCT = constantsFacet.bct();
        CARBONMARK = constantsFacet.carbonmark();

        DEFAULT_PROJECT = IToucanPool(BCT).getScoredTCO2s()[0];

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_infinity_retireCarbonmark_BCT_USDC_BRIDGED() public {
        address TCO2 = 0xb139C4cC9D20A3618E9a2268D73Eff18C496B991;
        uint256 listingAmount = 1_250_000_000_000_000_000;
        uint256 retireAmount = 5e17;
        // create listing
        deal(TCO2, address(this), listingAmount);

        IERC20(TCO2).approve(CARBONMARK, listingAmount);

        bytes32 listingId =
            ICarbonmark(CARBONMARK).createListing(TCO2, listingAmount, 5_000_000, 1e17, block.timestamp + 3600);

        ICarbonmark.CreditListing memory listing =
            ICarbonmark.CreditListing(listingId, address(this), TCO2, 0, listingAmount, 5_000_000);

        uint256 sourceAmount = ICarbonmark(CARBONMARK).getUnitPrice(listing.id) * retireAmount / 1e18;
        getSourceTokens(TransactionType.EXACT_SOURCE, diamond, USDC_BRIDGED, USDC_BRIDGED, sourceAmount);

        retireExactBCT(listing, retireAmount, sourceAmount);
        assertZeroTokenBalance(USDC_BRIDGED, diamond);
    }

    function test_infinity_retireCarbonmark_BCT_USDC_NATIVE() public {
        address TCO2 = 0xb139C4cC9D20A3618E9a2268D73Eff18C496B991;
        uint256 listingAmount = 1_250_000_000_000_000_000;
        uint256 retireAmount = 5e17;
        // create listing
        deal(TCO2, address(this), listingAmount);

        IERC20(TCO2).approve(CARBONMARK, listingAmount);

        bytes32 listingId =
            ICarbonmark(CARBONMARK).createListing(TCO2, listingAmount, 5_000_000, 1e17, block.timestamp + 3600);

        ICarbonmark.CreditListing memory listing =
            ICarbonmark.CreditListing(listingId, address(this), TCO2, 0, listingAmount, 5_000_000);

        uint256 sourceAmount = ICarbonmark(CARBONMARK).getUnitPrice(listing.id) * retireAmount / 1e18;
        getSourceTokens(TransactionType.EXACT_SOURCE, diamond, USDC_NATIVE, USDC_NATIVE, sourceAmount);

        retireExactBCT(listing, retireAmount, sourceAmount);
        assertZeroTokenBalance(USDC_NATIVE, diamond);
    }

    function test_infinity_retireCarbonmark_Puro_USDC_BRIDGED() public {
        uint256 defaultCarbonRetireAmount = 5e18;

        swipeERC20Tokens(PURO_PROJECT, 3e18, 0x89DCA1d490aa6e4e7404dC7a55408519858895FE, address(this));
        swipeERC20Tokens(PURO_PROJECT, 2e18, 0xE32bb999851587b53d170C0A130cCE7f542c754d, address(this));
        IERC20(PURO_PROJECT).approve(CARBONMARK, defaultCarbonRetireAmount);

        bytes32 listingId = ICarbonmark(CARBONMARK).createListing(
            PURO_PROJECT, defaultCarbonRetireAmount, 5_000_000, 5e17, block.timestamp + 3600
        );

        ICarbonmark.CreditListing memory listing = ICarbonmark.CreditListing(
            listingId, address(this), PURO_PROJECT, PURO_TOKEN_ID, defaultCarbonRetireAmount, 5_000_000
        );

        uint256 sourceAmount = ICarbonmark(CARBONMARK).getUnitPrice(listing.id) * defaultCarbonRetireAmount / 1e18;
        getSourceTokens(TransactionType.EXACT_SOURCE, diamond, USDC_BRIDGED, USDC_BRIDGED, sourceAmount);

        retireExactPuro(listing, defaultCarbonRetireAmount, sourceAmount);
        assertZeroTokenBalance(USDC_BRIDGED, diamond);
    }

    function test_infinity_retireCarbonmark_Puro_USDC_NATIVE() public {
        uint256 defaultCarbonRetireAmount = 5e18;

        swipeERC20Tokens(PURO_PROJECT, 3e18, 0x89DCA1d490aa6e4e7404dC7a55408519858895FE, address(this));
        swipeERC20Tokens(PURO_PROJECT, 2e18, 0xE32bb999851587b53d170C0A130cCE7f542c754d, address(this));
        IERC20(PURO_PROJECT).approve(CARBONMARK, defaultCarbonRetireAmount);

        bytes32 listingId = ICarbonmark(CARBONMARK).createListing(
            PURO_PROJECT, defaultCarbonRetireAmount, 5_000_000, 5e17, block.timestamp + 3600
        );

        ICarbonmark.CreditListing memory listing = ICarbonmark.CreditListing(
            listingId, address(this), PURO_PROJECT, PURO_TOKEN_ID, defaultCarbonRetireAmount, 5_000_000
        );

        uint256 sourceAmount = ICarbonmark(CARBONMARK).getUnitPrice(listing.id) * defaultCarbonRetireAmount / 1e18;
        getSourceTokens(TransactionType.EXACT_SOURCE, diamond, USDC_NATIVE, USDC_NATIVE, sourceAmount);

        retireExactPuro(listing, defaultCarbonRetireAmount, sourceAmount);
        assertZeroTokenBalance(USDC_NATIVE, diamond);
    }

    function retireExactPuro(ICarbonmark.CreditListing memory listing, uint256 retireAmount, uint256 sourceAmount)
        public
    {
        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint256 expectedRetirements = currentRetirements + 1;
        uint256 expectedCarbonRetired = currentTotalCarbon + retireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.TOUCAN,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            address(0),
            PURO_PROJECT,
            PURO_TOKEN_ID,
            retireAmount
        );

        LibRetire.RetireDetails memory details = LibRetire.RetireDetails({
            retiringAddress: address(this),
            retiringEntityString: entity,
            beneficiaryAddress: beneficiaryAddress,
            beneficiaryString: beneficiary,
            retirementMessage: message,
            beneficiaryLocation: "Germany",
            consumptionCountryCode: "DE",
            consumptionPeriodStart: 1_672_552_800,
            consumptionPeriodEnd: 1_704_088_799
        });

        uint256 retirementIndex = retireCarbonmarkFacet.retireCarbonmarkListing(
            listing, sourceAmount, retireAmount, details, LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        assertZeroTokenBalance(PURO_PROJECT, diamond);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(retirementIndex, expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function retireExactBCT(ICarbonmark.CreditListing memory listing, uint256 retireAmount, uint256 sourceAmount)
        public
    {
        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        LibRetire.RetireDetails memory details = LibRetire.RetireDetails({
            retiringAddress: address(this),
            retiringEntityString: entity,
            beneficiaryAddress: beneficiaryAddress,
            beneficiaryString: beneficiary,
            retirementMessage: message,
            beneficiaryLocation: "",
            consumptionCountryCode: "",
            consumptionPeriodStart: 0,
            consumptionPeriodEnd: 0
        });

        if (retireAmount == 0) {
            vm.expectRevert();

            retireCarbonmarkFacet.retireCarbonmarkListing(
                listing, sourceAmount, retireAmount, details, LibTransfer.From.EXTERNAL
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
                listing, sourceAmount, retireAmount, details, LibTransfer.From.EXTERNAL
            );

            // No tokens left in contract

            assertZeroTokenBalance(BCT, diamond);

            // Return value matches
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

            // Account state values updated
            assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
            assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        }
    }
}
