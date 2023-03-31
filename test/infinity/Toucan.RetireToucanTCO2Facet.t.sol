pragma solidity ^0.8.16;

import "./HelperContract.sol";
import "../../src/infinity/facets/Bridges/Toucan/RetireToucanTCO2Facet.sol";

import {console} from "../../lib/forge-std/src/console.sol";


interface IRetireToucanTCO2Facet {
    function toucanRetireExactTCO2(
        address carbonToken,
        uint amount,
        address beneficiaryAddress,
        string calldata beneficiaryString,
        string calldata retirementMessage,
        LibTransfer.From fromMode
    ) external returns (uint retirementIndex);

    function toucanRetireExactTCO2WithEntity(
        address carbonToken,
        uint amount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external returns (uint retirementIndex);
}

contract RetireToucanTCO2FacetTest is HelperContract {
    IRetireToucanTCO2Facet retireToucanTCO2Facet;
    IERC20 carbonToken;
    uint256 amountToRetire = 100 * 1e18;
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    address carbonTokenHolder; // BCT pool
    address beneficiaryAddress;
    address diamond;
    address KlimaTreasury;

    address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
    address SKLIMA = 0xb0C22d8D350C67420f06F48936654f567C73E8C8;
    address WSKLIMA = 0x6f370dba99E32A3cAD959b341120DB3C9E280bA6;
    
    address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
    address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;


    function setUp() public {
        retireToucanTCO2Facet = IRetireToucanTCO2Facet(0x8cE54d9625371fb2a068986d32C85De8E6e995f8);


        // Set up the carbonToken address and a carbonTokenHolder with a balance
        carbonToken = IERC20(0xC645b80Fd8a23A1459D59626bA3f872e8A59D4cb); // TCO2-VCS-191-2010
        carbonTokenHolder = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F; // BCT Pool
        KlimaTreasury = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;

        beneficiaryAddress = 0x000000000000000000000000000000000000dEaD;

        uint256 initialBalance = carbonToken.balanceOf(address(this));
        uint256 amountToTransfer = 100 * 1e18; // Assuming TCO2 token has 18 decimals

        uint newBalance = swipeERC20Tokens(address(carbonToken), amountToTransfer, carbonTokenHolder, address(this));

        carbonToken.approve(0x8cE54d9625371fb2a068986d32C85De8E6e995f8, newBalance);
    }

    function test_toucanRetireExactTCO2() public {
        uint initialBalance = carbonToken.balanceOf(address(this));
        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + amountToRetire;
        uint expectedBalance = initialBalance - amountToRetire;

        // Start recording logs
        vm.recordLogs();


        // Call the toucanRetireExactTCO2 function and verify the retirement index
        uint256 retirementIndex = retireToucanTCO2Facet.toucanRetireExactTCO2(
            address(carbonToken),
            amountToRetire,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[6].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(expectedBalance, carbonToken.balanceOf(address(this)));

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);


        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[6].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[6].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[6].topics[3]))); 

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[6].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq("KlimaDAO Retirement Aggregator", retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(address(0),emitted_carbonPool); // no pool for direct TCO2 retirement
        assertEq(address(carbonToken), carbonTokenRetired);
        assertEq(amountToRetire, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_toucanRetireExactTCO2WithEntity() public {

        uint initialBalance = carbonToken.balanceOf(address(this));
        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + amountToRetire;
        uint expectedBalance = initialBalance - amountToRetire;

        // Start recording logs
        vm.recordLogs();

        // Call the toucanRetireExactTCO2WithEntity function
        uint256 retirementIndex = retireToucanTCO2Facet.toucanRetireExactTCO2WithEntity(
            address(carbonToken),
            amountToRetire,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[6].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(expectedBalance, carbonToken.balanceOf(address(this)));

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[6].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[6].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[6].topics[3]))); 

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[6].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(address(0),emitted_carbonPool); // no pool for direct TCO2 retirement
        assertEq(address(carbonToken), carbonTokenRetired);
        assertEq(amountToRetire, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
        
    }


}