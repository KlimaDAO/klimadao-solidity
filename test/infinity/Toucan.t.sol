pragma solidity ^0.8.16;

import "./HelperContract.sol";
import "../../src/infinity/facets/Retire/RetireCarbonFacet.sol";


import {console} from "../../lib/forge-std/src/console.sol";

interface IRetirementQuoter {
    function getSourceAmountSwapOnly(address sourceToken, address carbonToken, uint amountOut)
        external
        view
        returns (uint amountIn);

    function getSourceAmountDefaultRetirement(address sourceToken, address carbonToken, uint retireAmount)
        external
        view
        returns (uint amountIn);

    function getSourceAmountSpecificRetirement(address sourceToken, address carbonToken, uint retireAmount)
        external
        view
        returns (uint amountIn);

    function getSourceAmountDefaultRedeem(address sourceToken, address carbonToken, uint redeemAmount)
        external
        view
        returns (uint amountIn);

    function getSourceAmountSpecificRedeem(address sourceToken, address carbonToken, uint[] memory redeemAmounts)
        external
        view
        returns (uint amountIn);
}

interface IRetireCarbonFacet  {

    function retireExactCarbonDefault(
        address sourceToken,
        address poolToken,
        uint maxAmountIn,
        uint retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external payable returns (uint retirementIndex);

    function retireExactCarbonSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint maxAmountIn,
        uint retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external payable returns (uint retirementIndex);


}

interface IRetireSourceFacet {
    function retireExactSourceDefault(
        address sourceToken,
        address poolToken,
        uint maxAmountIn,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external payable returns (uint retirementIndex);

    function retireExactSourceSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint maxAmountIn,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external payable returns (uint retirementIndex);
}

contract RetireCarbonFacetTest is HelperContract {
    IRetireCarbonFacet retireCarbonFacet;
    IRetirementQuoter quoterFacet;
    IRetireSourceFacet retireSourceFacet;

    address bctDefaultProjectAddress = 0xb139C4cC9D20A3618E9a2268D73Eff18C496B991;
    address nctDefaultProjectAddress = 0x6362364A37F34d39a1f4993fb595dAB4116dAf0d;
    address bctSpecificProjectAddress = 0x35B73A62Dd351030eCBd4252135e59bbb6345a60;
    address nctSpecificProjectAddress = 0x04943C19896c776c78770429eC02C5384ee78292;

    uint defaultCarbonRetireAmount = 100 * 1e18;

    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    address beneficiaryAddress = 0x000000000000000000000000000000000000dEaD;
    address diamond = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;
    address KlimaTreasury = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
    address KlimaStaking = 0x25d28a24Ceb6F81015bB0b2007D795ACAc411b4d;
    address wsKLIMA_holder = 0xe02efadA566Af74c92b6659d03BAaCb4c06Cc856; // C3 wsKLIMA gauge

    address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
    address SKLIMA = 0xb0C22d8D350C67420f06F48936654f567C73E8C8;
    address WSKLIMA = 0x6f370dba99E32A3cAD959b341120DB3C9E280bA6;
    
    address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
    address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;


    function setUp() public {
        retireCarbonFacet = IRetireCarbonFacet(diamond);
        quoterFacet = IRetirementQuoter(diamond);
        retireSourceFacet = IRetireSourceFacet(diamond);
    }

    function test_retireExactCarbonDefault_retireBCT_usingBCT() public {
        address sourceToken = BCT;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[9].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[9].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[9].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[9].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[9].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonDefault_retireBCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[18].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[18].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[18].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[18].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[18].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonDefault_retireBCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[15].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[15].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[15].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[15].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[15].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonDefault_retireBCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[18].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[18].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[18].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[18].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[18].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactCarbonDefault_retireBCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[20].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[20].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[20].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[20].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[20].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonDefault_retireNCT_usingNCT() public {
        address sourceToken = NCT;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[9].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[9].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[9].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[9].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[9].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);


    }

    function test_retireExactCarbonDefault_retireNCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[15].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[15].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[15].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[15].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[15].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonDefault_retireNCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[15].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[15].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[15].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[15].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[15].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonDefault_retireNCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[18].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[18].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[18].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[18].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[18].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonDefault_retireNCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[20].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[20].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[20].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[20].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[20].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);


    }

    // retireExactCarbonSpecific tests

    function test_retireExactCarbonSpecific_retireBCT_usingBCT() public {
        address sourceToken = BCT;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[13].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[13].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[13].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[13].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[13].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactCarbonSpecific_retireBCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[22].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[22].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[22].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[22].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[22].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonSpecific_retireBCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[19].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[19].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[19].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[19].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[19].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonSpecific_retireBCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[22].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[22].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[22].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[22].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[22].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactCarbonSpecific_retireBCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[24].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[24].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[24].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[24].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[24].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonSpecific_retireNCT_usingNCT() public {
        address sourceToken = NCT;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[13].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[13].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[13].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[13].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[13].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactCarbonSpecific_retireNCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[19].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[19].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[19].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[19].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[19].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonSpecific_retireNCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[19].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[19].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[19].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[19].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[19].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonSpecific_retireNCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[22].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[22].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[22].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[22].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[22].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactCarbonSpecific_retireNCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[24].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[24].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[24].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[24].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[24].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    // External Exact Source Retirements
    // retireExactSourceDefault tests

    function test_retireExactSourceDefault_retireBCT_usingBCT() public {
        address sourceToken = BCT;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;

        // Start recording logs
        vm.recordLogs();

        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[9].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[9].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[9].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[9].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[9].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress), "Incorrect retirement index");
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactSourceDefault_retireBCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[18].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[18].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[18].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[18].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[18].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceDefault_retireBCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[15].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[15].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[15].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[15].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[15].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceDefault_retireBCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[18].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[18].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[18].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[18].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[18].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactSourceDefault_retireBCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[20].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[20].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[20].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[20].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[20].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceDefault_retireNCT_usingNCT() public {
        address sourceToken = NCT;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;

        // Start recording logs
        vm.recordLogs();

        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[9].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[9].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[9].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[9].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[9].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress), "Incorrect retirement index");
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactSourceDefault_retireNCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[15].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[15].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[15].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[15].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[15].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceDefault_retireNCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[15].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[15].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[15].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[15].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[15].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceDefault_retireNCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[18].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[18].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[18].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[18].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[18].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactSourceDefault_retireNCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[20].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[20].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[20].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[20].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[20].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctDefaultProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    // retireExactSourceSpecific tests

    function test_retireExactSourceSpecific_retireBCT_usingBCT() public {
        address sourceToken = BCT;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;

        // Start recording logs
        vm.recordLogs();

        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[13].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[13].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[13].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[13].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[13].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress), "Incorrect retirement index");
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactSourceSpecific_retireBCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[22].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[22].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[22].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[22].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[22].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceSpecific_retireBCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[19].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[19].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[19].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[19].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[19].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceSpecific_retireBCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[22].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[22].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[22].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[22].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[22].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactSourceSpecific_retireBCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[24].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[24].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[24].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[24].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[24].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(BCT, emitted_carbonPool);
        assertEq(bctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceSpecific_retireNCT_usingNCT() public {
        address sourceToken = NCT;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;

        // Start recording logs
        vm.recordLogs();

        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[13].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[13].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[13].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[13].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[13].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress), "Incorrect retirement index");
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactSourceSpecific_retireNCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[19].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[19].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[19].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[19].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[19].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceSpecific_retireNCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[19].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[19].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[19].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[19].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[19].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_retireExactSourceSpecific_retireNCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[22].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[22].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[22].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[22].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[22].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);
    }

    function test_retireExactSourceSpecific_retireNCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        

        // Start recording logs
        vm.recordLogs();

       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[24].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[24].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[24].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[24].topics[3])));

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[24].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(0, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(NCT, emitted_carbonPool);
        assertEq(nctSpecificProjectAddress, carbonTokenRetired);
        
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }






}