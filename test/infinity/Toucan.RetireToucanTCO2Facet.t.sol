pragma solidity ^0.8.16;

import "./HelperContract.sol";
import "../../src/infinity/facets/Bridges/Toucan/RetireToucanTCO2Facet.sol";

import {console} from "../../lib/forge-std/src/console.sol";

contract RetireToucanTCO2FacetTest is HelperContract {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address poolToken,
        uint retiredAmount
    );

    RetireToucanTCO2Facet retireToucanTCO2Facet;
    IERC20 carbonToken;
    uint256 defaultCarbonRetireAmount = 100 * 1e18;
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
        retireToucanTCO2Facet = RetireToucanTCO2Facet(0x8cE54d9625371fb2a068986d32C85De8E6e995f8);

        // Set up the carbonToken address and a carbonTokenHolder with a balance
        carbonToken = IERC20(0xC645b80Fd8a23A1459D59626bA3f872e8A59D4cb); // TCO2-VCS-191-2010
        carbonTokenHolder = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F; // BCT Pool
        KlimaTreasury = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;

        beneficiaryAddress = 0x000000000000000000000000000000000000dEaD;
        
        uint256 amountToTransfer = 100 * 1e18; // Assuming TCO2 token has 18 decimals

        uint newBalance = swipeERC20Tokens(address(carbonToken), amountToTransfer, carbonTokenHolder, address(this));

        carbonToken.approve(0x8cE54d9625371fb2a068986d32C85De8E6e995f8, newBalance);
    }

    function test_toucanRetireExactTCO2() public {
        uint initialBalance = carbonToken.balanceOf(address(this));
        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;
        uint expectedBalance = initialBalance - defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.TOUCAN,
            address(this),
            "KlimaDAO Retirement Aggregator",
            beneficiaryAddress,
            beneficiary,
            message,
            address(0),
            address(carbonToken),
            defaultCarbonRetireAmount
        );


        // Call the toucanRetireExactTCO2 function and verify the retirement index
        uint256 retirementIndex = retireToucanTCO2Facet.toucanRetireExactTCO2(
            address(carbonToken),
            defaultCarbonRetireAmount,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        assertEq(expectedBalance, carbonToken.balanceOf(address(this)));

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

    }

    function test_toucanRetireExactTCO2WithEntity() public {

        uint initialBalance = carbonToken.balanceOf(address(this));
        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;
        uint expectedBalance = initialBalance - defaultCarbonRetireAmount;

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
            address(carbonToken),
            defaultCarbonRetireAmount
        );

        // Call the toucanRetireExactTCO2WithEntity function
        uint256 retirementIndex = retireToucanTCO2Facet.toucanRetireExactTCO2WithEntity(
            address(carbonToken),
            defaultCarbonRetireAmount,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        assertEq(expectedBalance, carbonToken.balanceOf(address(this)));

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
        
    }


}