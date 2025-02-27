// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeInfinityForBatchRetire } from "../../../script/7_upgradeInfinityForBatchRetire.s.sol";
import { TestHelper } from "../../infinity/TestHelper.sol";
import { C } from "../../../src/infinity/C.sol";
import { AssertionHelper } from "../../helpers/AssertionHelper.sol";
import { ListingsHelper } from "../../helpers/Listings.sol";
import { Test } from "forge-std/Test.sol";
import { IERC20 } from "../../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { ICarbonmark } from "../../../src/infinity/interfaces/ICarbonmark.sol";
import { ICMARKCreditTokenFactory } from "../../../src/infinity/interfaces/ICMARKCredit.sol";
import { LibRetire } from "../../../src/infinity/libraries/LibRetire.sol";
import { LibTransfer } from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import { RetireCarbonmarkFacet } from "../../../src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

contract UpgradeInfinityForBatchRetireTest is TestHelper, AssertionHelper, ListingsHelper {
    UpgradeInfinityForBatchRetire upgradeScript;
    RetireCarbonmarkFacet retireCarbonmarkFacet;
    ConstantsGetter constantsFacet;


    bytes data;

    // Addresses pulled from current diamond constants
    address CARBONMARK;
    address BCT;
    address USDC_BRIDGED;
    address USDC_NATIVE;



    // Pulled from env
    address DIAMOND_OWNER = vm.envAddress("INFINITY_OWNER"); // multisig
    address DIAMOND_ADDRESS = vm.envAddress("INFINITY_ADDRESS");


    // Retirement details
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";
    
    function setUp() public {
        // Set constants variables
        addConstantsGetter(DIAMOND_ADDRESS);
        constantsFacet = ConstantsGetter(DIAMOND_ADDRESS);
        retireCarbonmarkFacet = RetireCarbonmarkFacet(DIAMOND_ADDRESS);
        
        CARBONMARK = constantsFacet.carbonmark();
        BCT = constantsFacet.bct();
        USDC_BRIDGED = constantsFacet.usdc_bridged();
        USDC_NATIVE = constantsFacet.usdc();

        // Start fork
        string memory RPC_URL = vm.envString("POLYGON_URL");
        uint256 forkId = vm.createFork(RPC_URL);
        vm.selectFork(forkId);
    }

    function doUpgrade() public {
        // Set the calldata
        upgradeScript = new UpgradeInfinityForBatchRetire();
        data = upgradeScript.run();

        // Prank the owner of the Diamond
        vm.startPrank(DIAMOND_OWNER);
        (bool success,) = DIAMOND_ADDRESS.call(data);
        require(success, "Diamond upgrade failed");
        vm.stopPrank();
    }

    function test_upgrade() public {
        doUpgrade();
    }

    function test_retirement() public {
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

        // Get USDC
        uint256 sourceAmount = ICarbonmark(CARBONMARK).getUnitPrice(listing.id) * retireAmount / 1e18;
        //getSourceTokens(TransactionType.EXACT_SOURCE, DIAMOND_ADDRESS, USDC_BRIDGED, USDC_BRIDGED, sourceAmount);

        // Retire listing
        //retireExactBCT(listing, retireAmount, sourceAmount);
        //assertZeroTokenBalance(USDC_BRIDGED, DIAMOND_ADDRESS);
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

        uint256 retirementIndex = retireCarbonmarkFacet.retireCarbonmarkListing(
            listing, sourceAmount, retireAmount, details, LibTransfer.From.EXTERNAL
        );

        // Return value matches
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
    }

}
