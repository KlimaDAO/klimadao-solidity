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
    address CARBONMARK;
    address BCT;
    address USDC_BRIDGED;
    address USDC_NATIVE;
    address[] projectsBCT;

    struct BatchedRetirementEvent { 
        bool success;
        uint256 retirementIndex;
    }

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
        projectsBCT = IToucanPool(BCT).getScoredTCO2s();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_empty_calldata() public {
        BatchRetireFacet.Call[] memory calls = new BatchRetireFacet.Call[](0);

        vm.expectRevert("callData cannot be empty");
        uint256[] memory retirementIndexes = batchRetireFacet.batchRetire(calls);
    }

    function test_no_retirements_performed() public {
        BatchRetireFacet.Call[] memory calls = new BatchRetireFacet.Call[](1);

        vm.expectRevert("No successful retirements performed");
        uint256[] memory retirementIndexes = batchRetireFacet.batchRetire(calls);
    }

    /**
     * Performs 4 retirements. One of them fails
     */
    function test_retirement() public {
        // Build callData
        BatchRetireFacet.Call[] memory calls = new BatchRetireFacet.Call[](4);

        // Listing retirement call
        calls[0] = BatchRetireFacet.Call({
            callData: retireCarbonmarkListingCallData(5e17)
        });

        
        // Default carbon retirement call
        calls[1] = BatchRetireFacet.Call({
            callData: retireExactCarbonDefaultCallData(4e17)
        });

        // Failing retirement
        calls[2] = BatchRetireFacet.Call({
            callData: "0x"
        });

        // Specific carbon retirement call
        calls[3] = BatchRetireFacet.Call({
            callData: retireExactCarbonSpecificCallData(3e17)
        });

        uint nbSuccessfulRetirements = calls.length - 1;

        // Save state before doing the retirements
        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        // Perform the batch retirement
        vm.recordLogs();
        uint256[] memory retirementIndexes = batchRetireFacet.batchRetire(calls);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        // Check that ccoherence
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + nbSuccessfulRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + 12e17);

        // Check emitted logs
        BatchedRetirementEvent[] memory events = extractBatchedRetirementDoneLogs(logs);
        assertEq(events[0].success, true);
        assertEq(events[0].retirementIndex, currentRetirements + 1);

        assertEq(events[1].success, true);
        assertEq(events[1].retirementIndex, currentRetirements + 2);
        
        assertEq(events[2].success, false);
        assertEq(events[2].retirementIndex, type(uint256).max);
        
        assertEq(events[3].success, true);
        assertEq(events[3].retirementIndex, currentRetirements + 3);
        

    }

    function extractBatchedRetirementDoneLogs(Vm.Log[] memory logs) private returns (BatchedRetirementEvent[] memory events) {
        // Compute number of events
        bytes32 wantedKeccak = keccak256("BatchedRetirementDone(bool,uint256)");
        uint32 count = 0;
        for (uint32 i; i < logs.length; i++) {
            if (logs[i].topics[0] == wantedKeccak) count++;
        }

        // Allocate array
        BatchedRetirementEvent[] memory events = new BatchedRetirementEvent[](count);

        // Compute events
        count = 0;
        for (uint32 i; i < logs.length; i++) {
            bytes memory data = logs[i].data;
            if (logs[i].topics[0] == wantedKeccak) {
                (bool success, uint256 retirementIndex) = abi.decode(data, (bool, uint256));
                events[count] = BatchedRetirementEvent({success: success, retirementIndex: retirementIndex});
                count++;
            }
        }
        return events;
    }

    function retireExactCarbonSpecificCallData(uint256 retireAmount) private returns (bytes memory)
    {
        address POOL_TOKEN = BCT;
        address PROJECT_TOKEN = projectsBCT[randomish(projectsBCT.length)];
        address SOURCE_TOKEN = USDC_NATIVE;

        // Get USDC
        uint256 sourceAmount = getSourceTokensWithSlippage(TransactionType.SPECIFIC_RETIRE, diamond, SOURCE_TOKEN, POOL_TOKEN, retireAmount, 1);

        return abi.encodeWithSignature("retireExactCarbonSpecific(address,address,address,uint256,uint256,string,address,string,string,uint8)",SOURCE_TOKEN,POOL_TOKEN,PROJECT_TOKEN,sourceAmount,retireAmount,entity,beneficiaryAddress,beneficiary,message,LibTransfer.From.EXTERNAL);
    }

    function retireExactCarbonDefaultCallData(uint256 retireAmount) private returns (bytes memory)
    {
        address POOL_TOKEN = BCT;
        address SOURCE_TOKEN = USDC_NATIVE;

        // Get Source token
        uint256 sourceAmount = getSourceTokensWithSlippage(TransactionType.DEFAULT_RETIRE, diamond, SOURCE_TOKEN, POOL_TOKEN, retireAmount,1);

        return abi.encodeWithSignature("retireExactCarbonDefault(address,address,uint256,uint256,string,address,string,string,uint8)",SOURCE_TOKEN,POOL_TOKEN,sourceAmount,retireAmount,entity,beneficiaryAddress,beneficiary,message,LibTransfer.From.EXTERNAL);
    }

    function retireCarbonmarkListingCallData(uint256 retireAmount) private returns (bytes memory)
    {
        address TCO2 = 0xb139C4cC9D20A3618E9a2268D73Eff18C496B991;
        uint256 listingAmount = 1_250_000_000_000_000_000;

         // create listing
        deal(TCO2, address(this), listingAmount); 

        IERC20(TCO2).approve(CARBONMARK, listingAmount);

        bytes32 listingId =
            ICarbonmark(CARBONMARK).createListing(TCO2, listingAmount, 5_000_000, 1e17, block.timestamp + 3600);

        ICarbonmark.CreditListing memory listing =
            ICarbonmark.CreditListing(listingId, address(this), TCO2, 0, listingAmount, 5_000_000);

        // Get USDC
        uint256 sourceAmount = ICarbonmark(CARBONMARK).getUnitPrice(listing.id) * retireAmount / 1e18;
        getSourceTokensWithSlippage(TransactionType.EXACT_SOURCE, diamond, USDC_NATIVE, USDC_NATIVE, sourceAmount,1);

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
