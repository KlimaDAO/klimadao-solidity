pragma solidity ^0.8.16;

import "./HelperContract.sol";
import "../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import "../../src/infinity/facets/RetirementQuoter.sol";

import {console} from "../../lib/forge-std/src/console.sol";


contract RedeemC3PoolFacetTest is HelperContract {
    RedeemC3PoolFacet redeemC3PoolFacet;
    RetirementQuoter quoterFacet;

    address uboDefaultProjectAddress = 0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA;
    address nboDefaultProjectAddress = 0xb6eA7a53FC048D6d3B80b968D696E39482B7e578;
    address uboSpecificProjectAddress = 0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA;
    address nboSpecificProjectAddress = 0xD28DFEBa8fB9e44B715156162C8b6076d7a95Ad1;

    uint defaultCarbonRetireAmount = 100 * 1e18;

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
        redeemC3PoolFacet = RedeemC3PoolFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
    }

    function test_c3RedeemPoolDefault_redeemUBO_usingUBO() public {
        address sourceToken = UBO;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(uboDefaultProjectAddress).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], uboDefaultProjectAddress);
        assertEq(IERC20(uboDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);
        assertEq(IERC20(uboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolDefault_redeemUBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(uboDefaultProjectAddress).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], uboDefaultProjectAddress);
        assertEq(IERC20(uboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolDefault_redeemUBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(uboDefaultProjectAddress).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], uboDefaultProjectAddress);
        assertEq(IERC20(uboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolDefault_redeemUBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(uboDefaultProjectAddress).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], uboDefaultProjectAddress);
        assertEq(IERC20(uboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolDefault_redeemUBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = UBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(uboDefaultProjectAddress).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], uboDefaultProjectAddress);
        assertEq(IERC20(uboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolDefault_redeemNBO_usingNBO() public {
        address sourceToken = NBO;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(nboDefaultProjectAddress).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], nboDefaultProjectAddress);
        assertEq(IERC20(nboDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);
        assertEq(IERC20(nboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolDefault_redeemNBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(nboDefaultProjectAddress).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], nboDefaultProjectAddress);
        assertEq(IERC20(nboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolDefault_redeemNBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(nboDefaultProjectAddress).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], nboDefaultProjectAddress);
        assertEq(IERC20(nboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolDefault_redeemNBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(nboDefaultProjectAddress).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], nboDefaultProjectAddress);
        assertEq(IERC20(nboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolDefault_redeemNBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NBO;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        (address[] memory projectTokens, uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(nboDefaultProjectAddress).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(projectTokens[0], nboDefaultProjectAddress);
        assertEq(IERC20(nboDefaultProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    // External Specific Redemptions

    function test_c3RedeemPoolSpecific_redeemUBO_usingUBO() public {
        address sourceToken = UBO;
        address carbonToken = UBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = uboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(uboSpecificProjectAddress).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens
        assertEq(IERC20(uboSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);
        assertEq(IERC20(uboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolSpecific_redeemUBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = UBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = uboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(uboSpecificProjectAddress).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens

        assertEq(IERC20(uboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolSpecific_redeemUBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = UBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = uboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(uboSpecificProjectAddress).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens

        assertEq(IERC20(uboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolSpecific_redeemUBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = UBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = uboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(uboSpecificProjectAddress).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens

        assertEq(IERC20(uboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolSpecific_redeemUBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = UBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = uboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(uboSpecificProjectAddress).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens

        assertEq(IERC20(uboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolSpecific_redeemNBO_usingNBO() public {
        address sourceToken = NBO;
        address carbonToken = NBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = nboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(nboSpecificProjectAddress).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens

        assertEq(IERC20(nboSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);
        assertEq(IERC20(nboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolSpecific_redeemNBO_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = nboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(nboSpecificProjectAddress).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens

        assertEq(IERC20(nboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolSpecific_redeemNBO_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = nboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(nboSpecificProjectAddress).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens

        assertEq(IERC20(nboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolSpecific_redeemNBO_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = nboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(nboSpecificProjectAddress).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens

        assertEq(IERC20(nboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

    function test_c3RedeemPoolSpecific_redeemNBO_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NBO;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));
        uint initialBalance = IERC20(sourceToken).balanceOf(diamond);

        address[] memory desiredProjectTokens = new address[](1);
        desiredProjectTokens[0] = nboSpecificProjectAddress;

        uint[] memory desiredAmounts = new uint[](1);
        desiredAmounts[0] = defaultCarbonRetireAmount;

        (uint[] memory amounts) = redeemC3PoolFacet.c3RedeemPoolSpecific(sourceToken, carbonToken, sourceAmount, desiredProjectTokens, desiredAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(initialBalance, IERC20(sourceToken).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(nboSpecificProjectAddress).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(KLIMA).balanceOf(diamond), "tokens left in contract");
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond), "tokens left in contract");
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has default project tokens

        assertEq(IERC20(nboSpecificProjectAddress).balanceOf(address(this)), amounts[0]);

    }

}
