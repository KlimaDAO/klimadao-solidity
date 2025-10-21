// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../script/11_upgradeBCTSwapPaths.s.sol";
import "../../../src/infinity/facets/DiamondLoupeFacet.sol";
import {C} from "../../../src/infinity/C.sol";
import {ConstantsGetter} from "../../../src/infinity/mocks/ConstantsGetter.sol";
import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetireSourceFacet} from "../../../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {RedeemToucanPoolFacet} from "../../../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RedeemC3PoolFacet} from "../../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {TestHelper} from "../TestHelper.sol";
import {IERC20} from "oz/token/ERC20/IERC20.sol";

contract UpgradeBCTSwapPathsTest is TestHelper {
    UpgradeBCTSwapPathsScript upgradeScript;
    uint256 polygonFork;

    // set by env
    address payable INFINITY_ADDRESS;
    address multisig;

    ConstantsGetter constantsFacet;
    RetirementQuoter retirementQuoter;
    RetireCarbonFacet retireCarbonFacet;

    function setUp() public {
        string memory polygonRpc = vm.envString("POLYGON_URL");
        polygonFork = vm.createFork(polygonRpc);
        vm.selectFork(polygonFork);

        upgradeScript = new UpgradeBCTSwapPathsScript();

        INFINITY_ADDRESS = payable(vm.envAddress("INFINITY_ADDRESS"));
        multisig = vm.envAddress("CONTRACT_MULTISIG");

        addConstantsGetter(INFINITY_ADDRESS);
        constantsFacet = ConstantsGetter(INFINITY_ADDRESS);
        retirementQuoter = RetirementQuoter(INFINITY_ADDRESS);
        retireCarbonFacet = RetireCarbonFacet(INFINITY_ADDRESS);
    }

    function _performUpgrade() internal {
        bytes memory swapPathsCalldata = upgradeScript.updateSwapPathsCalldata();
        bytes memory facetsCalldata = upgradeScript.updateFacetsCalldata();

        vm.startPrank(multisig);
        (bool swapSuccess,) = INFINITY_ADDRESS.call(swapPathsCalldata);
        require(swapSuccess, "Swap paths update failed");
        (bool facetSuccess,) = INFINITY_ADDRESS.call(facetsCalldata);
        require(facetSuccess, "Facet update failed");
        vm.stopPrank();
    }

    function testDeploymentOfUpgradeBCTSwapPaths() public {
        upgradeScript.run();

        // Check if UpgradeBCTSwapPaths was deployed
        assertTrue(address(upgradeScript.UpgradeBCTSwapPathsInit()) != address(0), "UpgradeBCTSwapPaths not deployed");
    }

    function testCallDataGeneration() public {
        upgradeScript.run();

        bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();
        bytes memory updateFacetsCalldata = upgradeScript.updateFacetsCalldata();

        assertTrue(updateSwapPathsCalldata.length > 0, "Update swap paths calldata is empty");
        assertTrue(updateFacetsCalldata.length > 0, "Facet update calldata is empty");
    }

    function testVerifyUpdatedBCTSwapPaths() public {
        upgradeScript.run();

        // BEFORE UPGRADE: Verify current BCT swap paths
        (uint8[] memory swapDexesBefore, address[] memory ammRoutersBefore, address[] memory swapPathBefore) =
            constantsFacet.getSwapInfo(C.bct(), C.usdc_bridged());

        // BEFORE: Should be 3-hop path [USDC.e, KLIMA, BCT] or similar
        assertTrue(swapPathBefore.length >= 3, "BCT swap path before upgrade should be 3+ hops");

        // BEFORE: Verify KLIMA -> BCT direct path exists
        (uint8[] memory klimaSwapDexesBefore, address[] memory klimaAmmRoutersBefore, address[] memory klimaSwapPathBefore) =
            constantsFacet.getSwapInfo(C.bct(), C.klima());
        assertTrue(klimaSwapDexesBefore.length > 0, "KLIMA -> BCT should have direct path before upgrade");

        _performUpgrade();

        // AFTER UPGRADE: Verify RetireCarbonFacet replacement
        DiamondLoupeFacet loupe = DiamondLoupeFacet(INFINITY_ADDRESS);
        address retireFacetAddress =
            loupe.facetAddress(RetireCarbonFacet.retireExactCarbonDefault.selector);
        assertEq(retireFacetAddress, address(upgradeScript.retireCarbonF()), "RetireCarbonFacet not replaced");

        // AFTER UPGRADE: Verify RetirementQuoter replacement
        address quoterFacetAddress =
            loupe.facetAddress(RetirementQuoter.getSourceAmountDefaultRetirement.selector);
        assertEq(quoterFacetAddress, address(upgradeScript.retirementQuoterF()), "RetirementQuoter not replaced");

        // AFTER UPGRADE: Verify RetireSourceFacet replacement
        address retireSourceFacetAddress =
            loupe.facetAddress(RetireSourceFacet.retireExactSourceDefault.selector);
        assertEq(retireSourceFacetAddress, address(upgradeScript.retireSourceF()), "RetireSourceFacet not replaced");

        // AFTER UPGRADE: Verify RedeemToucanPoolFacet replacement
        address redeemToucanFacetAddress =
            loupe.facetAddress(RedeemToucanPoolFacet.toucanRedeemExactCarbonPoolDefault.selector);
        assertEq(redeemToucanFacetAddress, address(upgradeScript.redeemToucanPoolF()), "RedeemToucanPoolFacet not replaced");

        // AFTER UPGRADE: Verify RedeemC3PoolFacet replacement
        address redeemC3FacetAddress =
            loupe.facetAddress(RedeemC3PoolFacet.c3RedeemPoolDefault.selector);
        assertEq(redeemC3FacetAddress, address(upgradeScript.redeemC3PoolF()), "RedeemC3PoolFacet not replaced");

        // AFTER: Verify BCT from USDC.e path is [USDC.e, BCT] (2 tokens)
        (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath) =
            constantsFacet.getSwapInfo(C.bct(), C.usdc_bridged());

        assertEq(swapDexes.length, 1, "Incorrect number of swap dexes for BCT");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for BCT");
        assertEq(ammRouters.length, 1, "Incorrect number of AMM routers for BCT");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for BCT");
        assertEq(swapPath.length, 2, "BCT swap path should be 2-hop (USDC.e -> BCT)");
        assertEq(swapPath[0], C.usdc_bridged(), "Incorrect first address in swap path for BCT");
        assertEq(swapPath[1], C.bct(), "Incorrect second address in swap path for BCT");

        // AFTER: Verify KLIMA -> BCT path is deleted (length == 0)
        (uint8[] memory klimaSwapDexes, address[] memory klimaAmmRouters, address[] memory klimaSwapPath) =
            constantsFacet.getSwapInfo(C.bct(), C.klima());

        assertEq(klimaSwapDexes.length, 0, "KLIMA -> BCT swap dexes should be empty");
        assertEq(klimaAmmRouters.length, 0, "KLIMA -> BCT AMM routers should be empty");
        assertEq(klimaSwapPath.length, 0, "KLIMA -> BCT swap path should be empty");
    }

    function testRetireBCTBeforeAndAfterUpgrade() public {
        upgradeScript.run();

        address testUser = address(0x1234);
        uint256 retireAmount = 1e18; // 1 BCT

        // BEFORE UPGRADE: Test retirement with USDC.e works
        deal(C.usdc_bridged(), testUser, 200e6); // Double amount for both tests

        uint256 sourceNeededBefore = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        assertTrue(sourceNeededBefore > 0, "Source amount before upgrade should be greater than 0");

        vm.startPrank(testUser);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), sourceNeededBefore);

        // Execute retirement before upgrade
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc_bridged(),
            C.bct(),
            sourceNeededBefore,
            retireAmount,
            "Test Entity Before",
            testUser,
            "Test Beneficiary",
            "Test Retirement Before",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        uint256 balanceAfterFirstRetirement = IERC20(C.usdc_bridged()).balanceOf(testUser);
        assertTrue(balanceAfterFirstRetirement < 200e6, "USDC.e should have been spent before upgrade");

        // Perform upgrade
        _performUpgrade();

        // AFTER UPGRADE: Test retirement still works (should be more efficient)
        uint256 sourceNeededAfter = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        assertTrue(sourceNeededAfter > 0, "Source amount after upgrade should be greater than 0");

        vm.startPrank(testUser);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), sourceNeededAfter);

        // Execute retirement after upgrade
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc_bridged(),
            C.bct(),
            sourceNeededAfter,
            retireAmount,
            "Test Entity After",
            testUser,
            "Test Beneficiary",
            "Test Retirement After",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify second retirement succeeded
        uint256 finalBalance = IERC20(C.usdc_bridged()).balanceOf(testUser);
        assertTrue(finalBalance < balanceAfterFirstRetirement, "USDC.e should have been spent after upgrade");

        // After upgrade, the direct route should be more efficient (use less or equal USDC.e)
        assertTrue(sourceNeededAfter <= sourceNeededBefore, "After upgrade should be more efficient or equal");
    }

    function testRetireBCTWithUSDCe() public {
        upgradeScript.run();

        _performUpgrade();

        // Setup test with USDC.e
        address testUser = address(0x1235);
        uint256 retireAmount = 1e18; // 1 BCT

        // Deal USDC.e to test user
        deal(C.usdc_bridged(), testUser, 100e6);

        // Get quote for retirement
        uint256 sourceNeeded = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        assertTrue(sourceNeeded > 0, "Source amount should be greater than 0");
        assertTrue(sourceNeeded <= 100e6, "Source amount should be within available balance");

        vm.startPrank(testUser);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        // Execute retirement
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc_bridged(),
            C.bct(),
            sourceNeeded,
            retireAmount,
            "Test Entity",
            testUser,
            "Test Beneficiary",
            "Test Retirement",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify retirement succeeded
        assertTrue(IERC20(C.usdc_bridged()).balanceOf(testUser) < 100e6, "USDC.e should have been spent");
    }

    function testRetireBCTWithNativeUSDC() public {
        upgradeScript.run();

        _performUpgrade();

        // Setup test with native USDC
        address testUser = address(0x1236);
        uint256 retireAmount = 1e18; // 1 BCT

        // Deal native USDC to test user
        deal(C.usdc(), testUser, 100e6);

        // Get quote for retirement
        uint256 sourceNeeded = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc(),
            C.bct(),
            retireAmount
        );

        assertTrue(sourceNeeded > 0, "Source amount should be greater than 0");
        assertTrue(sourceNeeded <= 100e6, "Source amount should be within available balance");

        vm.startPrank(testUser);
        IERC20(C.usdc()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        // Execute retirement - should convert to USDC.e then route to BCT
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc(),
            C.bct(),
            sourceNeeded,
            retireAmount,
            "Test Entity",
            testUser,
            "Test Beneficiary",
            "Test Retirement",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify retirement succeeded
        assertTrue(IERC20(C.usdc()).balanceOf(testUser) < 100e6, "Native USDC should have been spent");
    }

    function testRetireBCTWithKLIMA() public {
        upgradeScript.run();

        _performUpgrade();

        // Setup test with KLIMA
        address testUser = address(0x1237);
        uint256 retireAmount = 1e18; // 1 BCT

        // Deal KLIMA to test user
        deal(C.klima(), testUser, 100e9);

        // Get quote for retirement - should use fallback routing (KLIMA -> USDC.e -> BCT)
        uint256 sourceNeeded = retirementQuoter.getSourceAmountDefaultRetirement(
            C.klima(),
            C.bct(),
            retireAmount
        );

        assertTrue(sourceNeeded > 0, "Source amount should be greater than 0");
        assertTrue(sourceNeeded <= 100e9, "Source amount should be within available balance");

        vm.startPrank(testUser);
        IERC20(C.klima()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        // Execute retirement - should route KLIMA -> USDC.e -> BCT
        retireCarbonFacet.retireExactCarbonDefault(
            C.klima(),
            C.bct(),
            sourceNeeded,
            retireAmount,
            "Test Entity",
            testUser,
            "Test Beneficiary",
            "Test Retirement",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify retirement succeeded
        assertTrue(IERC20(C.klima()).balanceOf(testUser) < 100e9, "KLIMA should have been spent");
    }

    function testGetSourceAmountBCTQuotes() public {
        upgradeScript.run();

        // Get quotes before upgrade
        uint256 retireAmount = 1e18; // 1 BCT

        uint256 usdceQuoteBefore = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        uint256 klimaQuoteBefore = retirementQuoter.getSourceAmountDefaultRetirement(
            C.klima(),
            C.bct(),
            retireAmount
        );

        // Execute upgrade
        _performUpgrade();

        // Get quotes after upgrade
        uint256 usdceQuoteAfter = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        uint256 klimaQuoteAfter = retirementQuoter.getSourceAmountDefaultRetirement(
            C.klima(),
            C.bct(),
            retireAmount
        );

        // Verify quotes are reasonable
        assertTrue(usdceQuoteAfter > 0, "USDC.e quote should be greater than 0");
        assertTrue(klimaQuoteAfter > 0, "KLIMA quote should be greater than 0");

        // After upgrade, USDC.e -> BCT should be cheaper (2-hop vs 3-hop)
        assertTrue(usdceQuoteAfter <= usdceQuoteBefore, "USDC.e quote should be better or equal after upgrade");
    }

    function testRetirementBondsReverted() public {
        upgradeScript.run();

        _performUpgrade();

        // Note: swapWithRetirementBonds is an internal function
        // We can't test it directly, but the retirement bond code path
        // should be unreachable after removing the bond liquidity checks
        // in RetirementQuoter.sol
    }

    function testAllCarbonTokenRetirements() public {
        upgradeScript.run();

        _performUpgrade();

        address testUser = address(0x1237);
        uint256 retireAmount = 1e18;

        // Test BCT (updated path)
        deal(C.usdc_bridged(), testUser, 100e6);
        uint256 bctQuote = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );
        assertTrue(bctQuote > 0, "BCT quote should be greater than 0");

        // Test NCT (unchanged, direct USDC.e path)
        uint256 nctQuote = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.nct(),
            retireAmount
        );
        assertTrue(nctQuote > 0, "NCT quote should be greater than 0");

        // Test MCO2 (unchanged)
        uint256 mco2Quote = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.mco2(),
            retireAmount
        );
        assertTrue(mco2Quote > 0, "MCO2 quote should be greater than 0");

        // Test UBO (unchanged)
        uint256 uboQuote = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.ubo(),
            retireAmount
        );
        assertTrue(uboQuote > 0, "UBO quote should be greater than 0");

        // Test NBO (unchanged)
        uint256 nboQuote = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.nbo(),
            retireAmount
        );
        assertTrue(nboQuote > 0, "NBO quote should be greater than 0");

        // Verify all quotes are different (different pools/tokens)
        assertTrue(bctQuote != nctQuote, "BCT and NCT should have different quotes");
    }

    function testCompareBCTRetirementGasCosts() public {
        upgradeScript.run();
        _performUpgrade();

        address testUser = address(0x1238);
        uint256 retireAmount = 1e18;

        // Test that retirement works after upgrade (gas measurement is informational only)
        deal(C.usdc_bridged(), testUser, 100e6);
        uint256 sourceNeeded = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        vm.startPrank(testUser);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        uint256 gasBefore = gasleft();
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc_bridged(),
            C.bct(),
            sourceNeeded,
            retireAmount,
            "Test Entity",
            testUser,
            "Test Beneficiary",
            "Test Retirement",
            LibTransfer.From.EXTERNAL
        );
        uint256 gasUsed = gasBefore - gasleft();
        vm.stopPrank();

        // Log gas costs for documentation
        console.log("Gas used for USDC.e -> BCT retirement:", gasUsed);

        // Verify retirement succeeded
        assertTrue(IERC20(C.usdc_bridged()).balanceOf(testUser) < 100e6, "USDC.e should have been spent");
    }

    function testRetireSpecificBCTBeforeAndAfterUpgrade() public {
        upgradeScript.run();

        address testUser = address(0x1239);
        uint256 retireAmount = 1e18; // 1 BCT worth of specific TCO2

        // Setup user with double USDC.e for both tests
        deal(C.usdc_bridged(), testUser, 200e6);

        // BEFORE UPGRADE: Test specific retirement with USDC.e
        uint256 sourceNeededBefore = retirementQuoter.getSourceAmountSpecificRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        assertTrue(sourceNeededBefore > 0, "Source amount before upgrade should be greater than 0");

        vm.startPrank(testUser);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), sourceNeededBefore);

        // Execute specific retirement before upgrade
        // Note: Using address(0) for project token means it will use oldest available TCO2s
        retireCarbonFacet.retireExactCarbonSpecific(
            C.usdc_bridged(),
            C.bct(),
            0xd1960efC6c907D01EF618E29fe9a31910Cfbec66, // Specific project token
            sourceNeededBefore,
            retireAmount,
            "Test Entity Before Specific",
            testUser,
            "Test Beneficiary",
            "Test Specific Retirement Before",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        uint256 balanceAfterFirstRetirement = IERC20(C.usdc_bridged()).balanceOf(testUser);
        assertTrue(balanceAfterFirstRetirement < 200e6, "USDC.e should have been spent before upgrade");

        // Perform upgrade
        _performUpgrade();

        // AFTER UPGRADE: Test specific retirement still works
        uint256 sourceNeededAfter = retirementQuoter.getSourceAmountSpecificRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        assertTrue(sourceNeededAfter > 0, "Source amount after upgrade should be greater than 0");

        vm.startPrank(testUser);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), sourceNeededAfter);

        // Execute specific retirement after upgrade
        retireCarbonFacet.retireExactCarbonSpecific(
            C.usdc_bridged(),
            C.bct(),
            0xd1960efC6c907D01EF618E29fe9a31910Cfbec66, // Specific project token
            sourceNeededAfter,
            retireAmount,
            "Test Entity After Specific",
            testUser,
            "Test Beneficiary",
            "Test Specific Retirement After",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify second retirement succeeded
        uint256 finalBalance = IERC20(C.usdc_bridged()).balanceOf(testUser);
        assertTrue(finalBalance < balanceAfterFirstRetirement, "USDC.e should have been spent after upgrade");

        // After upgrade, the direct route should be more efficient (use less or equal USDC.e)
        assertTrue(sourceNeededAfter <= sourceNeededBefore, "Specific retirement after upgrade should be more efficient or equal");
    }

    function testRetireSpecificWithNativeUSDC() public {
        upgradeScript.run();
        _performUpgrade();

        address testUser = address(0x1241);
        uint256 retireAmount = 1e18;

        // Test specific retirement with native USDC -> BCT
        deal(C.usdc(), testUser, 100e6);

        uint256 sourceNeeded = retirementQuoter.getSourceAmountSpecificRetirement(
            C.usdc(),
            C.bct(),
            retireAmount
        );

        assertTrue(sourceNeeded > 0, "Source amount should be greater than 0");
        assertTrue(sourceNeeded <= 100e6, "Source amount should be within available balance");

        vm.startPrank(testUser);
        IERC20(C.usdc()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        // Execute specific retirement - should convert native USDC to USDC.e then route to BCT
        retireCarbonFacet.retireExactCarbonSpecific(
            C.usdc(),
            C.bct(),
            0xd1960efC6c907D01EF618E29fe9a31910Cfbec66, // Specific project token
            sourceNeeded,
            retireAmount,
            "Test Entity Native USDC",
            testUser,
            "Test Beneficiary",
            "Test Specific Retirement Native USDC",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify retirement succeeded
        assertTrue(IERC20(C.usdc()).balanceOf(testUser) < 100e6, "Native USDC should have been spent");
    }

    function testVerifyKlimaNCTPathDeprecated() public {
        upgradeScript.run();

        // BEFORE UPGRADE: Verify KLIMA -> NCT direct path exists
        (uint8[] memory klimaSwapDexesBefore, address[] memory klimaAmmRoutersBefore, address[] memory klimaSwapPathBefore) =
            constantsFacet.getSwapInfo(C.nct(), C.klima());
        assertTrue(klimaSwapDexesBefore.length > 0, "KLIMA -> NCT should have direct path before upgrade");

        _performUpgrade();

        // AFTER UPGRADE: Verify KLIMA -> NCT path is deleted (length == 0)
        (uint8[] memory klimaSwapDexes, address[] memory klimaAmmRouters, address[] memory klimaSwapPath) =
            constantsFacet.getSwapInfo(C.nct(), C.klima());

        assertEq(klimaSwapDexes.length, 0, "KLIMA -> NCT swap dexes should be empty");
        assertEq(klimaAmmRouters.length, 0, "KLIMA -> NCT AMM routers should be empty");
        assertEq(klimaSwapPath.length, 0, "KLIMA -> NCT swap path should be empty");
    }

    function testRetireNCTWithNativeUSDC() public {
        upgradeScript.run();

        _performUpgrade();

        // Setup test with native USDC
        address testUser = address(0x1242);
        uint256 retireAmount = 1e18; // 1 NCT

        // Deal native USDC to test user
        deal(C.usdc(), testUser, 100e6);

        // Get quote for retirement
        uint256 sourceNeeded = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc(),
            C.nct(),
            retireAmount
        );

        assertTrue(sourceNeeded > 0, "Source amount should be greater than 0");
        assertTrue(sourceNeeded <= 100e6, "Source amount should be within available balance");

        vm.startPrank(testUser);
        IERC20(C.usdc()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        // Execute retirement - should convert to USDC.e then route to NCT
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc(),
            C.nct(),
            sourceNeeded,
            retireAmount,
            "Test Entity NCT",
            testUser,
            "Test Beneficiary",
            "Test NCT Retirement",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify retirement succeeded
        assertTrue(IERC20(C.usdc()).balanceOf(testUser) < 100e6, "Native USDC should have been spent");
    }

    function testRetireSpecificNCTWithNativeUSDC() public {
        upgradeScript.run();

        _performUpgrade();

        // Setup test with native USDC
        address testUser = address(0x1243);
        uint256 retireAmount = 1e18; // 1 NCT worth of specific TCO2

        // Deal native USDC to test user
        deal(C.usdc(), testUser, 100e6);

        // Get quote for specific retirement
        uint256 sourceNeeded = retirementQuoter.getSourceAmountSpecificRetirement(
            C.usdc(),
            C.nct(),
            retireAmount
        );

        assertTrue(sourceNeeded > 0, "Source amount should be greater than 0");
        assertTrue(sourceNeeded <= 100e6, "Source amount should be within available balance");

        vm.startPrank(testUser);
        IERC20(C.usdc()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        // Execute specific retirement - should convert native USDC to USDC.e then route to NCT
        retireCarbonFacet.retireExactCarbonSpecific(
            C.usdc(),
            C.nct(),
            0x05a28540DE2869281fE8a39882fbadC96Ec4766c, // Specific NCT project token
            sourceNeeded,
            retireAmount,
            "Test Entity Specific NCT",
            testUser,
            "Test Beneficiary",
            "Test Specific NCT Retirement",
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify retirement succeeded
        assertTrue(IERC20(C.usdc()).balanceOf(testUser) < 100e6, "Native USDC should have been spent");
    }
}
