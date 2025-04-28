pragma solidity ^0.8.16;

import { RetireSourceFacet } from "../../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import { RetirementQuoter } from "../../../src/infinity/facets/RetirementQuoter.sol";
import { LibRetire } from "../../../src/infinity/libraries/LibRetire.sol";
import { LibKlima } from "../../../src/infinity/libraries/LibKlima.sol";
import { LibToucanCarbon } from "../../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import { LibTransfer } from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import { IToucanPool } from "../../../src/infinity/interfaces/IToucan.sol";
import { BatchCallFacet } from "../../../src/infinity/facets/Retire/BatchCallFacet.sol";
import { ICarbonmark } from "../../../src/infinity/interfaces/ICarbonmark.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract BatchCallTest is TestHelper, AssertionHelper {
    RetireSourceFacet retireSourceFacet;
    BatchCallFacet batchCallFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    // Addresses defined in .env
    address beneficiaryAddress1 = vm.envAddress("BENEFICIARY_ADDRESS");
    address beneficiaryAddress2 = vm.envAddress("BENEFICIARY_ADDRESS2");
    address diamond = vm.envAddress("INFINITY_ADDRESS");

    // Addresses pulled from current diamond constants
    address CARBONMARK;
    address BCT;
    address USDC_BRIDGED;
    address USDC_NATIVE;
    address[] projectsBCT;

    function setUp() public {
        // Set constants variables
        // This must be done after forking the blockchain because it actually adds a new facet to the diamond
        addConstantsGetter(diamond);
        constantsFacet = ConstantsGetter(diamond);
        batchCallFacet = BatchCallFacet(diamond);

        CARBONMARK = constantsFacet.carbonmark();
        BCT = constantsFacet.bct();
        USDC_BRIDGED = constantsFacet.usdc_bridged();
        USDC_NATIVE = constantsFacet.usdc();
        projectsBCT = IToucanPool(BCT).getScoredTCO2s();

        upgradeCurrentDiamond(diamond);
        sendDustToTreasury(diamond);
    }

    function test_empty_calldata() public {
        BatchCallFacet.Call[] memory calls = new BatchCallFacet.Call[](0); // No calls

        vm.expectRevert("callData cannot be empty");
        batchCallFacet.batchCall(calls);
    }

    function test_no_calls_performed() public {
        BatchCallFacet.Call[] memory calls = new BatchCallFacet.Call[](1); // One call with invalid data
                calls[0] = BatchCallFacet.Call({
            callData: "0x28"
        });

        vm.expectRevert("No successful calls performed");
        batchCallFacet.batchCall(calls);
    }

    function test_underlying_retirement_actors() public {
        BatchCallFacet.Call[] memory calls = new BatchCallFacet.Call[](1);
        calls[0] = BatchCallFacet.Call({
            callData: retireCarbonmarkListingCallData(beneficiaryAddress1, 5e17)
        });

        vm.recordLogs();
        batchCallFacet.batchCall(calls);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        CarbonRetiredEvent[] memory events = extractCarbonRetiredLogs(logs);

        assertEq(events[0].retiringAddress, address(this));
        assertEq(events[0].retiringEntityString, entity);
        assertEq(events[0].beneficiaryAddress, beneficiaryAddress1);
        assertEq(events[0].beneficiaryString, beneficiary);
        assertEq(events[0].retirementMessage, message);
        assertEq(events[0].projectToken, 0xb139C4cC9D20A3618E9a2268D73Eff18C496B991);
        assertEq(events[0].poolToken, 0x0000000000000000000000000000000000000000);
        assertEq(events[0].amount, 5e17);
    }

    /**
     * Performs 4 calls by 2 different users. One of them fails
     * 1: listing retirement for  user 1
     * 2: default carbon retirement by user 2
     * 3: reverted retirement
     * 4: specific carbon retirement by user 1
     */
    function test_batch_retirement() public {
        // Build callData
        BatchCallFacet.Call[] memory calls = new BatchCallFacet.Call[](4);

        // Listing retirement call
        calls[0] = BatchCallFacet.Call({
            callData: retireCarbonmarkListingCallData(beneficiaryAddress1, 5e17)
        });

        
        // Default carbon retirement call
        calls[1] = BatchCallFacet.Call({
            callData: retireExactCarbonDefaultCallData(beneficiaryAddress2, 4e17)
        });

        // Failing retirement
        calls[2] = BatchCallFacet.Call({
            callData: "0x3888"
        });

        // Specific carbon retirement call
        calls[3] = BatchCallFacet.Call({
            callData: retireExactCarbonSpecificCallData(beneficiaryAddress1, 3e17)
        });

        uint nbSuccessfulRetirements = calls.length - 1;

        // Save state before doing the retirements
        uint256 currentRetirements1 = LibRetire.getTotalRetirements(beneficiaryAddress1);
        uint256 currentTotalCarbon1 = LibRetire.getTotalCarbonRetired(beneficiaryAddress1);

        uint256 currentRetirements2 = LibRetire.getTotalRetirements(beneficiaryAddress2);
        uint256 currentTotalCarbon2 = LibRetire.getTotalCarbonRetired(beneficiaryAddress2);

        // Perform the batch retirement
        vm.recordLogs();
        LibRetire.BatchedCallsData[] memory result = batchCallFacet.batchCall(calls);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        // Check return value
        assertEq(result.length, calls.length);
        assertEq(result[0].success, true);
        assertEq(abi.decode(result[0].data, (uint256)), currentRetirements1 + 1);

        assertEq(result[1].success, true);
        assertEq(abi.decode(result[1].data, (uint256)), currentRetirements2 + 1);

        assertEq(result[2].success, false);
        assertEq(result[2].data, "0x");

        assertEq(result[3].success, true);
        assertEq(abi.decode(result[3].data, (uint256)), currentRetirements1 + 2);

        // Check storage changes
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress1), currentRetirements1 + 2);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress1), currentTotalCarbon1 + 8e17);

        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress2), currentRetirements2 + 1);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress2), currentTotalCarbon2 + 4e17);

        // Check emitted logs
        LibRetire.BatchedCallsData[][] memory batchEvents = extractBatchedCallsDoneLogs(logs);
        assertEq(batchEvents.length, 1);

        LibRetire.BatchedCallsData[] memory batchData = batchEvents[0];

        assertEq(batchData.length, 4);
        
        assertEq(abi.decode(batchData[0].data, (uint256)), currentRetirements1 + 1);
        assertEq(batchData[0].success, true);

        assertEq(abi.decode(batchData[1].data, (uint256)), currentRetirements2 + 1);        
        assertEq(batchData[1].success, true);

        assertEq(batchData[2].data, "0x");
        assertEq(batchData[2].success, false);

        assertEq(abi.decode(batchData[3].data, (uint256)), currentRetirements1 + 2);
        assertEq(batchData[3].success, true);
        

    }

    function retireExactCarbonSpecificCallData(address beneficiaryAddress, uint256 retireAmount) private returns (bytes memory)
    {
        address POOL_TOKEN = BCT;
        address PROJECT_TOKEN = projectsBCT[randomish(projectsBCT.length)];
        address SOURCE_TOKEN = USDC_NATIVE;

        // Get USDC
        uint256 sourceAmount = getSourceTokensWithSlippage(TransactionType.SPECIFIC_RETIRE, diamond, SOURCE_TOKEN, POOL_TOKEN, retireAmount, 1);

        return abi.encodeWithSignature("retireExactCarbonSpecific(address,address,address,uint256,uint256,string,address,string,string,uint8)",SOURCE_TOKEN,POOL_TOKEN,PROJECT_TOKEN,sourceAmount,retireAmount,entity,beneficiaryAddress,beneficiary,message,LibTransfer.From.EXTERNAL);
    }

    function retireExactCarbonDefaultCallData(address beneficiaryAddress, uint256 retireAmount) private returns (bytes memory)
    {
        address POOL_TOKEN = BCT;
        address SOURCE_TOKEN = USDC_NATIVE;

        // Get Source token
        uint256 sourceAmount = getSourceTokensWithSlippage(TransactionType.DEFAULT_RETIRE, diamond, SOURCE_TOKEN, POOL_TOKEN, retireAmount,1);

        return abi.encodeWithSignature("retireExactCarbonDefault(address,address,uint256,uint256,string,address,string,string,uint8)",SOURCE_TOKEN,POOL_TOKEN,sourceAmount,retireAmount,entity,beneficiaryAddress,beneficiary,message,LibTransfer.From.EXTERNAL);
    }

    function retireCarbonmarkListingCallData(address beneficiaryAddress, uint256 retireAmount) private returns (bytes memory)
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
