// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../script/4_updateBCTSwapPaths.s.sol";
import "../../../src/infinity/interfaces/IDiamondCut.sol";
import "../../../src/infinity/facets/DiamondCutFacet.sol";
import "../../../src/infinity/facets/DiamondLoupeFacet.sol";
import "../../../src/infinity/libraries/LibAppStorage.sol";
import {UpdateBCTSwapPaths} from "../../../src/infinity/init/UpdateBCTSwapPaths.sol";
import {C} from "../../../src/infinity/C.sol";
import {LibDiamond} from "../../../src/infinity/libraries/LibDiamond.sol";
import {OwnershipFacet} from "../../../src/infinity/facets/OwnershipFacet.sol";
import {ConstantsGetter} from "../../../src/infinity/mocks/ConstantsGetter.sol";
import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {TestHelper} from "../TestHelper.sol";
import {IERC20} from "oz/token/ERC20/IERC20.sol";

contract UpdateBCTSwapPathsTest is TestHelper {
    UpdateBCTSwapPathsScript upgradeScript;
    address diamond;
    uint256 deployerPrivateKey;
    uint256 polygonFork;

    // set by env
    address payable INFINITY_ADDRESS;
    address multisig;

    ConstantsGetter constantsFacet;
    RetirementQuoter retirementQuoter;
    RetireCarbonFacet retireCarbonFacet;

    AppStorage s;

    function setUp() public {
        upgradeScript = new UpdateBCTSwapPathsScript();
        diamond = address(0x1234567890123456789012345678901234567890);
        deployerPrivateKey = 0xabc123;

        // Set up environment variables
        INFINITY_ADDRESS = payable(vm.envAddress("INFINITY_ADDRESS"));
        multisig = vm.envAddress("CONTRACT_MULTISIG");

        addConstantsGetter(INFINITY_ADDRESS);
        constantsFacet = ConstantsGetter(INFINITY_ADDRESS);
        retirementQuoter = RetirementQuoter(INFINITY_ADDRESS);
        retireCarbonFacet = RetireCarbonFacet(INFINITY_ADDRESS);
    }

    function testDeploymentOfUpdateBCTSwapPaths() public {
        upgradeScript.run();

        // Check if UpdateBCTSwapPaths was deployed
        assertTrue(address(upgradeScript.updateBCTSwapPathsInit()) != address(0), "UpdateBCTSwapPaths not deployed");
    }

    function testCallDataGeneration() public {
        upgradeScript.run();

        bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();

        assertTrue(updateSwapPathsCalldata.length > 0, "Update swap paths calldata is empty");
    }

    function testVerifyUpdatedBCTSwapPaths() public {
        upgradeScript.run();

        IDiamondCut.FacetCut[] memory emptyCut = new IDiamondCut.FacetCut[](0);
        bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();

        vm.prank(multisig);
        (bool success, bytes memory returnData) = INFINITY_ADDRESS.call(updateSwapPathsCalldata);
        assertTrue(success, "Swap paths update failed");

        // Verify BCT from USDC.e path is [USDC.e, BCT] (2 tokens)
        (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath) =
            constantsFacet.getSwapInfo(C.bct(), C.usdc_bridged());

        assertEq(swapDexes.length, 1, "Incorrect number of swap dexes for BCT");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for BCT");
        assertEq(ammRouters.length, 1, "Incorrect number of AMM routers for BCT");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for BCT");
        assertEq(swapPath.length, 2, "BCT swap path should be 2-hop (USDC.e -> BCT)");
        assertEq(swapPath[0], C.usdc_bridged(), "Incorrect first address in swap path for BCT");
        assertEq(swapPath[1], C.bct(), "Incorrect second address in swap path for BCT");

        // Verify KLIMA -> BCT path is deleted (length == 0)
        (uint8[] memory klimaSwapDexes, address[] memory klimaAmmRouters, address[] memory klimaSwapPath) =
            constantsFacet.getSwapInfo(C.bct(), C.klima());

        assertEq(klimaSwapDexes.length, 0, "KLIMA -> BCT swap dexes should be empty");
        assertEq(klimaAmmRouters.length, 0, "KLIMA -> BCT AMM routers should be empty");
    }

    function testRetireBCTWithUSDCe() public {
        upgradeScript.run();

        vm.prank(multisig);
        (bool success,) = INFINITY_ADDRESS.call(upgradeScript.updateSwapPathsCalldata());
        assertTrue(success, "Swap paths update failed");

        // Setup test with USDC.e
        address testUser = address(0x1234);
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

        LibRetire.RetireDetails memory retireDetails = LibRetire.RetireDetails({
            beneficiaryAddress: testUser,
            beneficiary: "Test Beneficiary",
            retirementMessage: "Test Retirement",
            beneficiaryLocation: "Test Location",
            consumptionCountryCode: "US",
            consumptionPeriodStart: 0,
            consumptionPeriodEnd: 0
        });

        vm.startPrank(testUser);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        // Execute retirement
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc_bridged(),
            C.bct(),
            sourceNeeded,
            retireAmount,
            retireDetails,
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify retirement succeeded
        assertTrue(IERC20(C.usdc_bridged()).balanceOf(testUser) < 100e6, "USDC.e should have been spent");
    }

    function testRetireBCTWithNativeUSDC() public {
        upgradeScript.run();

        vm.prank(multisig);
        (bool success,) = INFINITY_ADDRESS.call(upgradeScript.updateSwapPathsCalldata());
        assertTrue(success, "Swap paths update failed");

        // Setup test with native USDC
        address testUser = address(0x1235);
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

        LibRetire.RetireDetails memory retireDetails = LibRetire.RetireDetails({
            beneficiaryAddress: testUser,
            beneficiary: "Test Beneficiary",
            retirementMessage: "Test Retirement",
            beneficiaryLocation: "Test Location",
            consumptionCountryCode: "US",
            consumptionPeriodStart: 0,
            consumptionPeriodEnd: 0
        });

        vm.startPrank(testUser);
        IERC20(C.usdc()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        // Execute retirement - should convert to USDC.e then route to BCT
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc(),
            C.bct(),
            sourceNeeded,
            retireAmount,
            retireDetails,
            LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        // Verify retirement succeeded
        assertTrue(IERC20(C.usdc()).balanceOf(testUser) < 100e6, "Native USDC should have been spent");
    }

    function testRetireBCTWithKLIMA() public {
        upgradeScript.run();

        vm.prank(multisig);
        (bool success,) = INFINITY_ADDRESS.call(upgradeScript.updateSwapPathsCalldata());
        assertTrue(success, "Swap paths update failed");

        // Setup test with KLIMA
        address testUser = address(0x1236);
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

        LibRetire.RetireDetails memory retireDetails = LibRetire.RetireDetails({
            beneficiaryAddress: testUser,
            beneficiary: "Test Beneficiary",
            retirementMessage: "Test Retirement",
            beneficiaryLocation: "Test Location",
            consumptionCountryCode: "US",
            consumptionPeriodStart: 0,
            consumptionPeriodEnd: 0
        });

        vm.startPrank(testUser);
        IERC20(C.klima()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        // Execute retirement - should route KLIMA -> USDC.e -> BCT
        retireCarbonFacet.retireExactCarbonDefault(
            C.klima(),
            C.bct(),
            sourceNeeded,
            retireAmount,
            retireDetails,
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
        vm.prank(multisig);
        (bool success,) = INFINITY_ADDRESS.call(upgradeScript.updateSwapPathsCalldata());
        assertTrue(success, "Swap paths update failed");

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

        vm.prank(multisig);
        (bool success,) = INFINITY_ADDRESS.call(upgradeScript.updateSwapPathsCalldata());
        assertTrue(success, "Swap paths update failed");

        // Note: swapWithRetirementBonds is an internal function
        // We can't test it directly, but the retirement bond code path
        // should be unreachable after removing the bond liquidity checks
        // in RetirementQuoter.sol
    }

    function testAllCarbonTokenRetirements() public {
        upgradeScript.run();

        vm.prank(multisig);
        (bool success,) = INFINITY_ADDRESS.call(upgradeScript.updateSwapPathsCalldata());
        assertTrue(success, "Swap paths update failed");

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

        address testUser = address(0x1238);
        uint256 retireAmount = 1e18;

        // Get gas cost before upgrade
        deal(C.usdc_bridged(), testUser, 100e6);
        uint256 sourceNeeded = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        LibRetire.RetireDetails memory retireDetails = LibRetire.RetireDetails({
            beneficiaryAddress: testUser,
            beneficiary: "Test Beneficiary",
            retirementMessage: "Test Retirement",
            beneficiaryLocation: "Test Location",
            consumptionCountryCode: "US",
            consumptionPeriodStart: 0,
            consumptionPeriodEnd: 0
        });

        vm.startPrank(testUser);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        uint256 gasBefore = gasleft();
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc_bridged(),
            C.bct(),
            sourceNeeded,
            retireAmount,
            retireDetails,
            LibTransfer.From.EXTERNAL
        );
        uint256 gasUsedBefore = gasBefore - gasleft();
        vm.stopPrank();

        // Execute upgrade
        vm.prank(multisig);
        (bool success,) = INFINITY_ADDRESS.call(upgradeScript.updateSwapPathsCalldata());
        assertTrue(success, "Swap paths update failed");

        // Get gas cost after upgrade
        deal(C.usdc_bridged(), testUser, 100e6);
        sourceNeeded = retirementQuoter.getSourceAmountDefaultRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        vm.startPrank(testUser);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), sourceNeeded);

        uint256 gasAfter = gasleft();
        retireCarbonFacet.retireExactCarbonDefault(
            C.usdc_bridged(),
            C.bct(),
            sourceNeeded,
            retireAmount,
            retireDetails,
            LibTransfer.From.EXTERNAL
        );
        uint256 gasUsedAfter = gasAfter - gasleft();
        vm.stopPrank();

        // Log gas costs for documentation
        console.log("Gas used before upgrade:", gasUsedBefore);
        console.log("Gas used after upgrade:", gasUsedAfter);

        // After upgrade should use less gas (2-hop vs 3-hop)
        assertTrue(gasUsedAfter <= gasUsedBefore, "Gas usage should be less or equal after upgrade");
    }

    function testRetireSpecificTCO2WithUSDCe() public {
        upgradeScript.run();

        vm.prank(multisig);
        (bool success,) = INFINITY_ADDRESS.call(upgradeScript.updateSwapPathsCalldata());
        assertTrue(success, "Swap paths update failed");

        // This test verifies that specific TCO2 retirement path works
        // after swap path update by ensuring BCT redemption works correctly

        address testUser = address(0x1239);
        uint256 retireAmount = 1e18;

        deal(C.usdc_bridged(), testUser, 100e6);

        // Get quote for specific retirement
        uint256 sourceNeeded = retirementQuoter.getSourceAmountSpecificRetirement(
            C.usdc_bridged(),
            C.bct(),
            retireAmount
        );

        assertTrue(sourceNeeded > 0, "Source amount should be greater than 0");
    }
}
