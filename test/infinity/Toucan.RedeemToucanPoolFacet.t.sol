pragma solidity ^0.8.16;

import "./HelperContract.sol";
import "../../src/infinity/interfaces/IToucan.sol";
import "../../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import "../../src/infinity/libraries/Bridges/LibToucanCarbon.sol";
import "../../src/infinity/libraries/LibRetire.sol";

import {console} from "../../lib/forge-std/src/console.sol";


interface IRetirementQuoter {
    function getSourceAmountDefaultRedeem(address sourceToken, address carbonToken, uint redeemAmount)
        external
        view
        returns (uint amountIn);

    function getSourceAmountSpecificRedeem(address sourceToken, address carbonToken, uint[] memory redeemAmounts)
        external
        view
        returns (uint amountIn);
}

interface IRedeemToucanPoolFacet {
    function toucanRedeemExactCarbonPoolSpecific(
        address sourceToken,
        address poolToken,
        uint maxAmountIn,
        address[] memory projectTokens,
        uint[] memory amounts,
        LibTransfer.From fromMode,
        LibTransfer.To toMode
    ) external returns (uint[] memory redeemedAmounts);

    function toucanRedeemExactCarbonPoolDefault(
        address sourceToken,
        address poolToken,
        uint amount,
        uint maxAmountIn,
        LibTransfer.From fromMode,
        LibTransfer.To toMode
    ) external returns (address[] memory projectTokens, uint[] memory amounts);
}

contract RedeemToucanPoolFacetTest is HelperContract {
    IRedeemToucanPoolFacet redeemToucanPoolFacet;
    IRetirementQuoter quoterFacet;

    address bctDefaultProjectAddress = 0xb139C4cC9D20A3618E9a2268D73Eff18C496B991;
    address nctDefaultProjectAddress = 0x6362364A37F34d39a1f4993fb595dAB4116dAf0d;
    address bctSpecificProjectAddress = 0x35B73A62Dd351030eCBd4252135e59bbb6345a60;
    address nctSpecificProjectAddress = 0x04943C19896c776c78770429eC02C5384ee78292;

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
    
    address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
    address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;


    function setUp() public {
        redeemToucanPoolFacet = IRedeemToucanPoolFacet(diamond);
        quoterFacet = IRetirementQuoter(diamond);
    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemBCT_usingBCT() public {
        address sourceToken = BCT;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, BCT, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemBCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, BCT, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(BCT).balanceOf(address(this)));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemBCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemBCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemBCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = BCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemNCT_usingNCT() public {
        address sourceToken = NCT;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemNCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemNCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemNCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolDefault_redeemNCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NCT;
        uint sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, carbonToken, defaultCarbonRetireAmount);
        
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault(sourceToken, carbonToken, defaultCarbonRetireAmount, sourceAmount, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctDefaultProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    // redeemExactCarbonPoolSpecific tests

    function test_toucanRedeemExactCarbonPoolSpecific_redeemBCT_usingBCT() public {
        address sourceToken = BCT;
        address carbonToken = BCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = bctSpecificProjectAddress;

        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolSpecific_redeemBCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = BCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = bctSpecificProjectAddress;

        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(BCT).balanceOf(address(this)));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolSpecific_redeemBCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = BCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = bctSpecificProjectAddress;
        
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolSpecific_redeemBCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = BCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = bctSpecificProjectAddress;
        
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolSpecific_redeemBCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = BCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = bctSpecificProjectAddress;
        
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(bctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolSpecific_redeemNCT_usingNCT() public {
        address sourceToken = NCT;
        address carbonToken = NCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = nctSpecificProjectAddress;
        
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolSpecific_redeemNCT_usingUSDC() public {
        address sourceToken = USDC;
        address carbonToken = NCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = nctSpecificProjectAddress;
        
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaTreasury, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);

        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolSpecific_redeemNCT_usingKLIMA() public {
        address sourceToken = KLIMA;
        address carbonToken = NCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = nctSpecificProjectAddress;
        
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);
        
        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolSpecific_redeemNCT_usingSKLIMA() public {
        address sourceToken = SKLIMA;
        address carbonToken = NCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = nctSpecificProjectAddress;
        
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, KlimaStaking, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);
        
        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }

    function test_toucanRedeemExactCarbonPoolSpecific_redeemNCT_usingWSKLIMA() public {
        address sourceToken = WSKLIMA;
        address carbonToken = NCT;
        uint[] memory redeemAmounts = new uint[](1);
        redeemAmounts[0] = defaultCarbonRetireAmount;
        address[] memory specificProjectAddresses = new address[](1);
        specificProjectAddresses[0] = nctSpecificProjectAddress;
        
        uint sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, carbonToken, redeemAmounts);
        swipeERC20Tokens(sourceToken, sourceAmount, wsKLIMA_holder, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(address(this));
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(address(this));

        redeemToucanPoolFacet.toucanRedeemExactCarbonPoolSpecific(sourceToken, carbonToken, sourceAmount, specificProjectAddresses, redeemAmounts, LibTransfer.From.EXTERNAL, LibTransfer.To.EXTERNAL);
        
        // No tokens left in contract
        assertEq(0, IERC20(sourceToken).balanceOf(diamond));
        assertEq(0, IERC20(SKLIMA).balanceOf(diamond));
        assertEq(0, IERC20(KLIMA).balanceOf(diamond));
        assertEq(0, IERC20(carbonToken).balanceOf(diamond));
        
        // Account state values updated
        assertEq(currentRetirements, LibRetire.getTotalRetirements(address(this)));
        assertEq(currentTotalCarbon, LibRetire.getTotalCarbonRetired(address(this)));

        // Caller has TCO2 tokens
        assertEq(IERC20(nctSpecificProjectAddress).balanceOf(address(this)), defaultCarbonRetireAmount);

    }


}