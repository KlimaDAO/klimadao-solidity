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

    address uboDefaultProjectAddress = 0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA;
    address nboDefaultProjectAddress = 0xb6eA7a53FC048D6d3B80b968D696E39482B7e578;
    address uboSpecificProjectAddress = 0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA;
    address nboSpecificProjectAddress = 0xD28DFEBa8fB9e44B715156162C8b6076d7a95Ad1;

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
    
    address UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
    address NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;


    function setUp() public {
        retireCarbonFacet = RetireCarbonFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        retireSourceFacet = RetireSourceFacet(diamond);
    }

    function test_retireExactCarbonDefault_retireUBO_usingUBO() public {
        address sourceToken = UBO;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );
       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_retireExactCarbonDefault_retireUBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }
    
    function test_retireExactCarbonDefault_retireUBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_retireExactCarbonDefault_retireUBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);    }

    function test_retireExactCarbonDefault_retireUBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_retireExactCarbonDefault_retireNBO_usingNBO() public {
        address sourceToken = NBO;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

    }

    function test_retireExactCarbonDefault_retireNBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_retireExactCarbonDefault_retireNBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_retireExactCarbonDefault_retireNBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_retireExactCarbonDefault_retireNBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboDefaultProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonDefault(sourceToken, carbonToken, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

    }

    // retireExactCarbonSpecific tests

    function test_retireExactCarbonSpecific_retireUBO_usingUBO() public {
        address sourceToken = UBO;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_retireExactCarbonSpecific_retireUBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

    }

    function test_retireExactCarbonSpecific_retireUBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

    }

    function test_retireExactCarbonSpecific_retireUBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_retireExactCarbonSpecific_retireUBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            UBO,
            uboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

    }

    function test_retireExactCarbonSpecific_retireNBO_usingNBO() public {
        address sourceToken = NBO;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    function test_retireExactCarbonSpecific_retireNBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

    }

    function test_retireExactCarbonSpecific_retireNBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements + 1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

    }

    function test_retireExactCarbonSpecific_retireNBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);

    }

    function test_retireExactCarbonSpecific_retireNBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            NBO,
            nboSpecificProjectAddress,
            defaultCarbonRetireAmount
        );


       
        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }

    // External Exact Source Retirements
    // retireExactSourceDefault tests

    function test_retireExactSourceDefault_retireUBO_usingUBO() public {
        address sourceToken = UBO;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;

        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceDefault_retireUBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceDefault_retireUBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements + 1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

    }

    function test_retireExactSourceDefault_retireUBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;

        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceDefault_retireUBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;

        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceDefault_retireNBO_usingNBO() public {
        address sourceToken = NBO;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;

        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);
                
        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceDefault_retireNBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;

        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

    }

    function test_retireExactSourceDefault_retireNBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements + 1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

    }

    function test_retireExactSourceDefault_retireNBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
        
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceDefault_retireNBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceDefault(sourceToken, carbonToken, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    // retireExactSourceSpecific tests

    function test_retireExactSourceSpecific_retireUBO_usingUBO() public {
        address sourceToken = UBO;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;

        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceSpecific_retireUBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceSpecific_retireUBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements + 1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceSpecific_retireUBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceSpecific_retireUBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, uboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceSpecific_retireNBO_usingNBO() public {
        address sourceToken = NBO;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;


        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements, "Not the expected retirements");
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceSpecific_retireNBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceSpecific_retireNBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements + 1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceSpecific_retireNBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;
       
        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");
    }

    function test_retireExactSourceSpecific_retireNBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);
        uint initialSourceBalance = IERC20(sourceToken).balanceOf(diamond);
        uint initialCarbonBalance = IERC20(carbonToken).balanceOf(diamond);

        uint expectedRetirements = currentRetirements +1;

        uint256 retirementIndex = retireSourceFacet.retireExactSourceSpecific(sourceToken, carbonToken, nboSpecificProjectAddress, sourceAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // No tokens left in contract
        assertEq(initialSourceBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(initialCarbonBalance, IERC20(carbonToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertGt(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon, "Not the expected carbon retired");

    }






}