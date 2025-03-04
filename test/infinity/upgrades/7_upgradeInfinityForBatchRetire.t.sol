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
import { BatchRetireFacet } from "../../../src/infinity/facets/Retire/BatchRetireFacet.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

contract UpgradeInfinityForBatchRetireTest is TestHelper, AssertionHelper, ListingsHelper {
    UpgradeInfinityForBatchRetire upgradeScript;
    RetireCarbonmarkFacet retireCarbonmarkFacet;
    BatchRetireFacet batchRetireFacet;
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
        // Start fork
        string memory RPC_URL = vm.envString("POLYGON_URL");
        uint256 forkId = vm.createFork(RPC_URL);
        vm.selectFork(forkId);

        // Set constants variables
        // This must be done after forking the blockchain because it actually adds a new facet to the diamond
        addConstantsGetter(DIAMOND_ADDRESS);
        constantsFacet = ConstantsGetter(DIAMOND_ADDRESS);
        retireCarbonmarkFacet = RetireCarbonmarkFacet(DIAMOND_ADDRESS);
        batchRetireFacet = BatchRetireFacet(DIAMOND_ADDRESS);

        CARBONMARK = constantsFacet.carbonmark();
        BCT = constantsFacet.bct();
        USDC_BRIDGED = constantsFacet.usdc_bridged();
        USDC_NATIVE = constantsFacet.usdc();

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
        doUpgrade();

        // Build callData
        BatchRetireFacet.Call[] memory calls = new BatchRetireFacet.Call[](1);

        calls[0] = BatchRetireFacet.Call({
            callData: retireCarbonmarkListingCall()
        });

        // Save state before doing the retirements
        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);


        // Perform the batch retirement
        uint256[] memory retirementIndexes = batchRetireFacet.batchRetire(calls);

        for (uint256 i = 0; i < retirementIndexes.length; ++i) {
            console.logUint(retirementIndexes[i]);
        } 

        // Return value matches
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndexes[retirementIndexes.length-1]);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
        
        // Retire listing
        assertZeroTokenBalance(USDC_BRIDGED, DIAMOND_ADDRESS);
    }

    function retireCarbonmarkListingCall() public returns (bytes memory)
    {
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
        getSourceTokens(TransactionType.EXACT_SOURCE, DIAMOND_ADDRESS, USDC_NATIVE, USDC_NATIVE, sourceAmount);

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

        return abi.encodeWithSignature("retireCarbonmarkListing((bytes32,address,address,uint256,uint256,uint256),uint256,uint256,(address,string,address,string,string,string,string,uint256,uint256),uint8)",listing,sourceAmount,retireAmount,details,LibTransfer.From.EXTERNAL);
    }
}
