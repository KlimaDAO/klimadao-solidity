pragma solidity ^0.8.16;

import "./HelperContract.sol";
import "../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import "../../src/infinity/facets/RetirementQuoter.sol";
import "../../src/infinity/facets/Retire/RetireSourceFacet.sol";

import {console} from "../../lib/forge-std/src/console.sol";

contract RetireCarbonFacetTest is HelperContract {
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

    RetireCarbonFacet retireCarbonFacet;
    RetirementQuoter quoterFacet;
    RetireSourceFacet retireSourceFacet;

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
        retireCarbonFacet = RetireCarbonFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        retireSourceFacet = RetireSourceFacet(diamond);
    }

    function test_retireExactCarbonDefault_retireBCT_usingBCT() public {
        address sourceToken = BCT;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

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
            BCT,
            bctDefaultProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(
            sourceToken,
            carbonToken,
            sourceAmount,
            defaultCarbonRetireAmount,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // Verify account state values are updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            BCT,
            bctDefaultProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            BCT,
            bctDefaultProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            BCT,
            bctDefaultProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            BCT,
            bctDefaultProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            NCT,
            nctDefaultProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            NCT,
            nctDefaultProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            NCT,
            nctDefaultProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

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
            NCT,
            nctDefaultProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

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

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);


        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            BCT,
            bctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            BCT,
            bctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

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
            BCT,
            bctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

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
            BCT,
            bctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            BCT,
            bctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

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
            NCT,
            nctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            NCT,
            nctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            NCT,
            nctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            NCT,
            nctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
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
            NCT,
            nctSpecificProjectAddress,
            defaultCarbonRetireAmount
        );

        //perform retirement
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);    }

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

        //perform retirement 
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
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
        

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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
        

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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
        

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
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
        

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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

        //perform retirement 
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
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

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
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

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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

        //perform retirement 
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
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
        

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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
        

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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
        

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
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
        

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, bctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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

        //perform retirement 
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
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

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

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

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
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

        //perform retirement
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nctSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

    }






}