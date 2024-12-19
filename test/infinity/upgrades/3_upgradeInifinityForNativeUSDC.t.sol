// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../script/3_upgradeInfinityForNativeUsdc.s.sol";
import "../../../src/infinity/interfaces/IDiamondCut.sol";
import "../../../src/infinity/facets/DiamondCutFacet.sol";
import "../../../src/infinity/facets/DiamondLoupeFacet.sol";
import "../../../src/infinity/libraries/LibAppStorage.sol";
import {RetireCarbonmarkFacet} from "../../../src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";
import {NativeUSDCInit} from "../../../src/infinity/init/NativeUSDCInit.sol";
import {C} from "../../../src/infinity/C.sol";
import {LibDiamond} from "../../../src/infinity/libraries/LibDiamond.sol";
import {OwnershipFacet} from "../../../src/infinity/facets/OwnershipFacet.sol";
import {ConstantsGetter} from "../../../src/infinity/mocks/ConstantsGetter.sol";
import {ICarbonmark} from "../../../src/infinity/interfaces/ICarbonmark.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {TestHelper} from "../TestHelper.sol";
import {ListingsHelper} from "../../helpers/Listings.sol";

contract UpgradeInfinityForNativeUsdcTest is TestHelper, ListingsHelper {
    UpgradeInfinityForNativeUsdc upgradeScript;
    address diamond;
    address carbonmark;
    uint256 deployerPrivateKey;
    uint256 polygonFork;

    // set by env
    address payable INFINITY_ADDRESS;
    address multisig;

    // address eoa = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    // address VCS_1190_2018 = address(0x64de5C0A430B2b15c6a3A7566c3930e1cF9b22DF);

    // address seller = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    ConstantsGetter constantsFacet;

    AppStorage s;

    function contains(bytes4[] memory array, bytes4 element) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }
        return false;
    }

    function verifyUpdatedSwapPaths() public {
        // Test BCT swap path
        (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath) =
            constantsFacet.getSwapInfo(C.bct(), C.usdc_bridged());

        assertEq(swapDexes[0], 0, "Incorrect swap dex for BCT");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for BCT");
        assertEq(swapPath[0], C.usdc_bridged(), "Incorrect first address in swap path for BCT");
        assertEq(swapPath[1], C.klima(), "Incorrect second address in swap path for BCT");
        assertEq(swapPath[2], C.bct(), "Incorrect third address in swap path for BCT");

        // Test NCT swap path
        (swapDexes, ammRouters, swapPath) = constantsFacet.getSwapInfo(C.nct(), C.usdc_bridged());
        assertEq(swapDexes.length, 1, "Incorrect number of swap dexes for NCT");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for NCT");
        assertEq(ammRouters.length, 1, "Incorrect number of AMM routers for NCT");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for NCT");
        assertEq(swapPath.length, 2, "Incorrect number of addresses in swap path for NCT");
        assertEq(swapPath[0], C.usdc_bridged(), "Incorrect first address in swap path for NCT");
        assertEq(swapPath[1], C.nct(), "Incorrect second address in swap path for NCT");

        // Test MCO2 swap path
        (swapDexes, ammRouters, swapPath) = constantsFacet.getSwapInfo(C.mco2(), C.usdc_bridged());
        assertEq(swapDexes.length, 2, "Incorrect number of swap dexes for MCO2");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for MCO2");
        assertEq(swapDexes[1], 0, "Incorrect swap dex for MCO2");
        assertEq(ammRouters.length, 2, "Incorrect number of AMM routers for MCO2");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for MCO2");
        assertEq(ammRouters[1], C.quickswapRouter(), "Incorrect AMM router for MCO2");
        assertEq(swapPath.length, 2, "Incorrect number of addresses in swap path for MCO2");

        // Test UBO swap path
        (swapDexes, ammRouters, swapPath) = constantsFacet.getSwapInfo(C.ubo(), C.usdc_bridged());
        assertEq(swapDexes.length, 1, "Incorrect number of swap dexes for UBO");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for UBO");
        assertEq(ammRouters.length, 1, "Incorrect number of AMM routers for UBO");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for UBO");
        assertEq(swapPath.length, 3, "Incorrect number of addresses in swap path for UBO");

        // Test NBO swap path
        (swapDexes, ammRouters, swapPath) = constantsFacet.getSwapInfo(C.nbo(), C.usdc_bridged());
        assertEq(swapDexes.length, 1, "Incorrect number of swap dexes for NBO");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for NBO");
        assertEq(ammRouters.length, 1, "Incorrect number of AMM routers for NBO");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for NBO");
        assertEq(swapPath.length, 3, "Incorrect number of addresses in swap path for NBO");

        // Test Coorest CCO2 swap path
        (swapDexes, ammRouters, swapPath) = constantsFacet.getSwapInfo(C.coorestCCO2Token(), C.usdc_bridged());
        assertEq(swapDexes.length, 1, "Incorrect number of swap dexes for Coorest CCO2");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for Coorest CCO2");
        assertEq(ammRouters.length, 1, "Incorrect number of AMM routers for Coorest CCO2");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for Coorest CCO2");
        assertEq(swapPath.length, 3, "Incorrect number of addresses in swap path for Coorest CCO2");
        assertEq(swapPath[0], C.usdc_bridged(), "Incorrect first address in swap path for Coorest CCO2");
        assertEq(swapPath[1], C.klima(), "Incorrect second address in swap path for Coorest CCO2");
    }

    function verifyUpdatedRetireCarbonmarkFacet() public {
        DiamondLoupeFacet loupe = DiamondLoupeFacet(INFINITY_ADDRESS);
        address loupeFacet = loupe.facetAddress(RetireCarbonmarkFacet.retireCarbonmarkListing.selector);
        assertEq(loupeFacet, address(upgradeScript.retireCarbonmarkF()), "RetireCarbonmarkFacet address mismatch");
        bytes4[] memory selectors = loupe.facetFunctionSelectors(loupeFacet);
        bytes4[] memory expectedSelectors = generateSelectors("RetireCarbonmarkFacet");
        assertEq(selectors.length, expectedSelectors.length, "Number of selectors mismatch");

        for (uint256 i = 0; i < expectedSelectors.length; i++) {
            assertTrue(contains(selectors, expectedSelectors[i]), "Missing selector");
        }
    }

    function setUp() public {
        upgradeScript = new UpgradeInfinityForNativeUsdc();
        diamond = address(0x1234567890123456789012345678901234567890);
        deployerPrivateKey = 0xabc123;

        // Set up environment variables
        INFINITY_ADDRESS = payable(vm.envAddress("INFINITY_ADDRESS"));
        multisig = vm.envAddress("CONTRACT_MULTISIG");

        addConstantsGetter(INFINITY_ADDRESS);
        constantsFacet = ConstantsGetter(INFINITY_ADDRESS);
        carbonmark = constantsFacet.carbonmark();
    }

    function testDeploymentOfNewFacetsAndInit() public {
        upgradeScript.run();

        // Check if RetireCarbonmarkFacet was deployed
        assertTrue(address(upgradeScript.retireCarbonmarkF()) != address(0), "RetireCarbonmarkFacet not deployed");

        // Check if NativeUSDCInit was deployed
        assertTrue(address(upgradeScript.nativeUSDCInitF()) != address(0), "NativeUSDCInit not deployed");
    }

    function testFacetCutCreation() public {
        upgradeScript.run();

        IDiamondCut.FacetCut[] memory cuts = upgradeScript.getCuts();
        assertEq(cuts.length, 1, "Incorrect number of cuts");
        assertEq(cuts[0].facetAddress, address(upgradeScript.retireCarbonmarkF()), "Incorrect facet address");
        assertEq(uint256(cuts[0].action), uint256(IDiamondCut.FacetCutAction.Replace), "Incorrect action");
        assertTrue(cuts[0].functionSelectors.length > 0, "No function selectors");
    }

    function testCallDataGeneration() public {
        upgradeScript.run();

        bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();
        bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

        assertTrue(updateSwapPathsCalldata.length > 0, "USDC init calldata is empty");
        assertTrue(addNewRetireCarbonmarkFacetCalldata.length > 0, "Add new RetireCarbonmarkFacet calldata is empty");
    }

    function testSwapInit() public {
        upgradeScript.run();

        IDiamondCut.FacetCut[] memory emptyCut = new IDiamondCut.FacetCut[](0);
        bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();

        vm.deal(multisig, 1);

        vm.startPrank(multisig);
        IDiamondCut(INFINITY_ADDRESS).diamondCut(
            emptyCut, address(upgradeScript.nativeUSDCInitF()), abi.encodeWithSignature("init()")
        );
        vm.stopPrank();

        verifyUpdatedSwapPaths();
    }

    function testSwapInitWithCalldataOnly() public {
        upgradeScript.run();

        IDiamondCut.FacetCut[] memory emptyCut = new IDiamondCut.FacetCut[](0);
        bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();

        vm.prank(multisig);
        (bool success, bytes memory returnData) = INFINITY_ADDRESS.call(updateSwapPathsCalldata);
        assertTrue(success, "Swap paths update failed");

        verifyUpdatedSwapPaths();
    }

    function testUpdatedRetireCarbonmarkFacet() public {
        upgradeScript.run();

        DiamondLoupeFacet loupe = DiamondLoupeFacet(INFINITY_ADDRESS);
        address oldFacetAddress = loupe.facetAddress(RetireCarbonmarkFacet.retireCarbonmarkListing.selector);

        vm.startPrank(multisig);
        IDiamondCut.FacetCut[] memory cut = upgradeScript.getCuts();
        IDiamondCut(INFINITY_ADDRESS).diamondCut(cut, address(0), "");
        vm.stopPrank();

        // Get the facet address after update
        address newFacetAddress = loupe.facetAddress(RetireCarbonmarkFacet.retireCarbonmarkListing.selector);

        // Verify that the facet address is different
        assertNotEq(oldFacetAddress, newFacetAddress, "Facet address should have changed");

        verifyUpdatedRetireCarbonmarkFacet();
    }

    function testUpdatedRetireCarbonmarkFacetWithCalldataOnly() public {
        upgradeScript.run();

        // address owner = setEOAOwner();

        bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

        vm.startPrank(multisig);
        (bool success,) = INFINITY_ADDRESS.call(addNewRetireCarbonmarkFacetCalldata);
        assertTrue(success, "Add new RetireCarbonmarkFacet failed");
        vm.stopPrank();

        verifyUpdatedRetireCarbonmarkFacet();
    }

    // this test won't pass locally unless carbonmark has already been updated on the fork

    function testRetireCarbonmarkFacetListingWithNativeUSDC() public {
        upgradeScript.run();

        IDiamondCut.FacetCut[] memory cut = upgradeScript.getCuts();

        vm.prank(multisig);
        IDiamondCut(INFINITY_ADDRESS).diamondCut(cut, address(0), "");

        verifyUpdatedRetireCarbonmarkFacet();

        uint256 amount = 15e18;
        uint256 unitPrice = 1e6;
        uint256 minFillAmount = 1e18;
        uint256 deadline = block.timestamp + 100 days;

        vm.deal(seller, 1 ether);
        deal(VCS_1190_2018, seller, 100e18);

        vm.startPrank(seller);
        IERC20(VCS_1190_2018).approve(address(INFINITY_ADDRESS), 100e18);
        IERC20(VCS_1190_2018).approve(address(carbonmark), 100e18);

        // create a carbonmark listing
        bytes32 carbonmarkListingId =
            createCarbonmarkListing(carbonmark, INFINITY_ADDRESS, amount, unitPrice, minFillAmount, deadline);
        vm.stopPrank();

        ICarbonmark.CreditListing memory listingStruct =
            getCarbonmarkListingStruct(carbonmark, carbonmarkListingId, amount, unitPrice);
        LibRetire.RetireDetails memory retirementDetails = getRetirementDetails(buyer);

        // ensure only native USDC is available
        deal(C.usdc(), buyer, 100e6);
        deal(C.usdc_bridged(), buyer, 0);

        assertEq(IERC20(C.usdc()).balanceOf(buyer), 100e6, "Buyer should have 100 USDC");
        assertEq(IERC20(C.usdc_bridged()).balanceOf(buyer), 0, "Buyer should have 0 USDC_bridged");

        uint256 maxAmountIn = (amount * unitPrice) / 1e18;

        vm.startPrank(buyer);
        IERC20(C.usdc()).approve(address(INFINITY_ADDRESS), 100e6);
        RetireCarbonmarkFacet(INFINITY_ADDRESS).retireCarbonmarkListing(
            listingStruct, maxAmountIn, amount, retirementDetails, LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        assertEq(IERC20(C.usdc_bridged()).balanceOf(buyer), 0, "Buyer should have 0 bridged USDC");
        assertEq(
            IERC20(C.usdc()).balanceOf(buyer),
            100e6 - maxAmountIn,
            "Buyer should have balance minus maxAmountIn of native USDC"
        );
    }

    function testRetireCarbonmarkFacetListingWithBridgedUSDC() public {
        upgradeScript.run();

        IDiamondCut.FacetCut[] memory cut = upgradeScript.getCuts();

        vm.prank(multisig);
        IDiamondCut(INFINITY_ADDRESS).diamondCut(cut, address(0), "");

        verifyUpdatedRetireCarbonmarkFacet();

        uint256 amount = 15e18;
        uint256 unitPrice = 1e6;
        uint256 minFillAmount = 1e18;
        uint256 deadline = block.timestamp + 100 days;

        vm.deal(seller, 1 ether);
        deal(VCS_1190_2018, seller, 100e18);

        vm.startPrank(seller);
        IERC20(VCS_1190_2018).approve(address(INFINITY_ADDRESS), 100e18);
        IERC20(VCS_1190_2018).approve(address(carbonmark), 100e18);

        // create a carbonmark listing
        bytes32 carbonmarkListingId =
            createCarbonmarkListing(carbonmark, INFINITY_ADDRESS, amount, unitPrice, minFillAmount, deadline);
        vm.stopPrank();

        ICarbonmark.CreditListing memory listingStruct =
            getCarbonmarkListingStruct(carbonmark, carbonmarkListingId, amount, unitPrice);
        LibRetire.RetireDetails memory retirementDetails = getRetirementDetails(buyer);
        // ensure only bridged USDC is available
        deal(C.usdc(), buyer, 0);
        deal(C.usdc_bridged(), buyer, 100e6);

        assertEq(IERC20(C.usdc()).balanceOf(buyer), 0, "Buyer should have 0 USDC");
        assertEq(IERC20(C.usdc_bridged()).balanceOf(buyer), 100e6, "Buyer should have 100 USDC_bridged");

        uint256 maxAmountIn = (amount * unitPrice) / 1e18;

        vm.startPrank(buyer);
        IERC20(C.usdc_bridged()).approve(address(INFINITY_ADDRESS), 100e6);
        RetireCarbonmarkFacet(INFINITY_ADDRESS).retireCarbonmarkListing(
            listingStruct, maxAmountIn, amount, retirementDetails, LibTransfer.From.EXTERNAL
        );
        vm.stopPrank();

        assertEq(IERC20(C.usdc()).balanceOf(buyer), 0, "Buyer should have 0 bridged USDC");
        assertEq(
            IERC20(C.usdc_bridged()).balanceOf(buyer),
            100e6 - maxAmountIn,
            "Buyer should have balance minus maxAmountIn of native USDC"
        );
    }

    function testRetireCarbonmarkFacetListing_notEnoughBalanceOfEitherUSDC() public {
        upgradeScript.run();

        IDiamondCut.FacetCut[] memory cut = upgradeScript.getCuts();

        vm.prank(multisig);
        IDiamondCut(INFINITY_ADDRESS).diamondCut(cut, address(0), "");
    }
}
