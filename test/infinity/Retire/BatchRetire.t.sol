pragma solidity ^0.8.16;

import {RetireSourceFacet} from "../../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibKlima} from "../../../src/infinity/libraries/LibKlima.sol";
import {LibToucanCarbon} from "../../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";
import { BatchRetireFacet } from "../../../src/infinity/facets/Retire/BatchRetireFacet.sol";
import { ICarbonmark } from "../../../src/infinity/interfaces/ICarbonmark.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract BatchRetireTest is TestHelper, AssertionHelper {
    RetireSourceFacet retireSourceFacet;
    BatchRetireFacet batchRetireFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");

    // Addresses pulled from current diamond constants
    // Addresses pulled from current diamond constants
    address CARBONMARK;
    address BCT;
    address USDC_BRIDGED;
    address USDC_NATIVE;

    function setUp() public {
        // Set constants variables
        // This must be done after forking the blockchain because it actually adds a new facet to the diamond
        addConstantsGetter(diamond);
        constantsFacet = ConstantsGetter(diamond);
        batchRetireFacet = BatchRetireFacet(diamond);

        CARBONMARK = constantsFacet.carbonmark();
        BCT = constantsFacet.bct();
        USDC_BRIDGED = constantsFacet.usdc_bridged();
        USDC_NATIVE = constantsFacet.usdc();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_retirement() public {
        // Build callData
        BatchRetireFacet.Call[] memory calls = new BatchRetireFacet.Call[](1);

        // Listing retirement call
        calls[0] = BatchRetireFacet.Call({
            callData: retireCarbonmarkListingCallData()
        });
        // Carbon default carbon retirement call
        /*
        calls[1] = BatchRetireFacet.Call({
            callData: retireExactCarbonDefaultCallData()
        });*/

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
        assertZeroTokenBalance(USDC_BRIDGED, diamond);
    }

    function retireExactCarbonDefaultCallData() public returns (bytes memory)
    {
        address TOKEN = 0xb139C4cC9D20A3618E9a2268D73Eff18C496B991;
        address POOL = 0xb139C4cC9D20A3618E9a2268D73Eff18C496B991;
        address DEFAULT_PROJECT_BCT = getDefaultToucanProject(BCT);
        uint256 retireAmount = 5e17;

        // Get USDC
        uint256 sourceAmount = getSourceTokens(TransactionType.DEFAULT_RETIRE, diamond, DEFAULT_PROJECT_BCT, BCT, retireAmount);

        return abi.encodeWithSignature("retireExactCarbonDefault(address,address,uint256,uint256,string,address,string,string,uint8)",TOKEN,POOL,sourceAmount,retireAmount,entity,beneficiaryAddress,beneficiary,message,LibTransfer.From.EXTERNAL);
    }

    function retireCarbonmarkListingCallData() public returns (bytes memory)
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
        getSourceTokens(TransactionType.EXACT_SOURCE, diamond, USDC_NATIVE, USDC_NATIVE, sourceAmount);

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
