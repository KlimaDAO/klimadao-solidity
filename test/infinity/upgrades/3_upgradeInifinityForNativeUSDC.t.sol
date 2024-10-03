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

import {TestHelper} from "../TestHelper.sol";

contract UpgradeInfinityForNativeUsdcTest is TestHelper {
    UpgradeInfinityForNativeUsdc upgradeScript;
    address mockDiamond;
    uint256 deployerPrivateKey;
    uint256 polygonFork;
    address payable INFINITY_ADDRESS;
    address multisig = address(0x843dE2e99449834cd6C6456Bd35894d0B157B947);
    address eoa = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

    ConstantsGetter constantsFacet;

    AppStorage s;

    function getSwapInfo(address poolToken, address sourceToken)
        public
        view
        returns (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath)
    {
        Storage.DefaultSwap storage defaultSwap = s.swap[poolToken][sourceToken];
        swapDexes = defaultSwap.swapDexes;
        ammRouters = defaultSwap.ammRouters;
        swapPath = defaultSwap.swapPaths[0];
        return (swapDexes, ammRouters, swapPath);
    }

    function contains(bytes4[] memory array, bytes4 element) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }
        return false;
    }

    //on the forked environment we can't prank a multisig. So for testing "only" reset the owner in contract storage to an anvil EOA to be able to call the txns
    function setEOAOwner() public returns (address owner) {
        // Calculate the storage slot for contractOwner
        bytes32 DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
        uint256 contractOwnerSlot = uint256(DIAMOND_STORAGE_POSITION) + 4;

        bytes32 ownerFromStorage = vm.load(INFINITY_ADDRESS, bytes32(contractOwnerSlot));
        address ownerAddress = address(uint160(uint256(ownerFromStorage)));
        require(ownerAddress == multisig, "Current owner is not the multisig");

        address newOwner = eoa;

        // store the EOA in the owner storage slot
        vm.store(INFINITY_ADDRESS, bytes32(contractOwnerSlot), bytes32(uint256(uint160(newOwner))));

        // Verify owner change
        OwnershipFacet ownershipFacet = OwnershipFacet(INFINITY_ADDRESS);
        owner = ownershipFacet.owner();
        require(owner == newOwner, "Failed to change owner");
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
        assertEq(swapDexes.length, 2, "Incorrect number of swap dexes for UBO");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for UBO");
        assertEq(swapDexes[1], 1, "Incorrect swap dex for UBO");
        assertEq(ammRouters.length, 2, "Incorrect number of AMM routers for UBO");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for UBO");
        assertEq(ammRouters[1], C.sushiTridentRouter(), "Incorrect AMM router for UBO");
        assertEq(swapPath.length, 2, "Incorrect number of addresses in swap path for UBO");

        // Test NBO swap path
        (swapDexes, ammRouters, swapPath) = constantsFacet.getSwapInfo(C.nbo(), C.usdc_bridged());
        assertEq(swapDexes.length, 2, "Incorrect number of swap dexes for NBO");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for NBO");
        assertEq(swapDexes[1], 1, "Incorrect swap dex for NBO");
        assertEq(ammRouters.length, 2, "Incorrect number of AMM routers for NBO");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for NBO");
        assertEq(ammRouters[1], C.sushiTridentRouter(), "Incorrect AMM router for NBO");
        assertEq(swapPath.length, 2, "Incorrect number of addresses in swap path for NBO");

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
        mockDiamond = address(0x1234567890123456789012345678901234567890);
        deployerPrivateKey = 0xabc123;

        // Set up environment variables
        INFINITY_ADDRESS = payable(vm.envAddress("INFINITY_ADDRESS"));

        addConstantsGetter(INFINITY_ADDRESS);
        constantsFacet = ConstantsGetter(INFINITY_ADDRESS);
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

        bytes memory usdcInitCalldata = upgradeScript.usdcInitCalldata();
        bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();
        bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

        assertTrue(usdcInitCalldata.length > 0, "USDC init calldata is empty");
        assertTrue(updateSwapPathsCalldata.length > 0, "Update swap paths calldata is empty");
        assertTrue(addNewRetireCarbonmarkFacetCalldata.length > 0, "Add new RetireCarbonmarkFacet calldata is empty");
    }

    function testSwapInit() public {
        upgradeScript.run();

        setEOAOwner();

        IDiamondCut.FacetCut[] memory emptyCut = new IDiamondCut.FacetCut[](0);
        bytes memory usdcInitCalldata = upgradeScript.usdcInitCalldata();

        OwnershipFacet ownerFacet = OwnershipFacet(INFINITY_ADDRESS);

        address owner = ownerFacet.owner();

        vm.deal(owner, 1);

        vm.startPrank(owner);
        IDiamondCut(INFINITY_ADDRESS).diamondCut(emptyCut, address(upgradeScript.nativeUSDCInitF()), usdcInitCalldata);

        verifyUpdatedSwapPaths();
    }

    function testSwapInitWithCalldataOnly() public {
        upgradeScript.run();

        address owner = setEOAOwner();

        IDiamondCut.FacetCut[] memory emptyCut = new IDiamondCut.FacetCut[](0);
        bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();

        vm.startPrank(owner);
        (bool success, bytes memory returnData) = INFINITY_ADDRESS.call(updateSwapPathsCalldata);
        assertTrue(success, "Swap paths update failed");

        verifyUpdatedSwapPaths();
    }

    function testUpdatedRetireCarbonmarkFacet() public {
        upgradeScript.run();

        address owner = setEOAOwner();

        bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

        vm.startPrank(owner);
        IDiamondCut.FacetCut[] memory cut = upgradeScript.getCuts();
        IDiamondCut(INFINITY_ADDRESS).diamondCut(cut, address(0), "");
        vm.stopPrank();

        verifyUpdatedRetireCarbonmarkFacet();
    }

    function testUpdatedRetireCarbonmarkFacetWithCalldataOnly() public {
        upgradeScript.run();

        address owner = setEOAOwner();

        bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

        vm.startPrank(owner);
        (bool success, bytes memory returnData) = INFINITY_ADDRESS.call(addNewRetireCarbonmarkFacetCalldata);
        assertTrue(success, "Add new RetireCarbonmarkFacet failed");
        vm.stopPrank();

        verifyUpdatedetireCarbonmarkFacet();
    }

    function testRetireCarbonmarkFacetListingWithNativeUSDC() public {
        upgradeScript.run();

        address owner = setEOAOwner();

        bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

        vm.startPrank(owner);
        IDiamondCut.FacetCut[] memory cut = upgradeScript.getCuts();
        IDiamondCut(INFINITY_ADDRESS).diamondCut(cut, address(0), "");
        vm.stopPrank();

        verifyUpdatedRetireCarbonmarkFacet();

        // retire carbonmark
        RetireCarbonmarkFacet retireCarbonmarkFacet = RetireCarbonmarkFacet(INFINITY_ADDRESS);
        retireCarbonmarkFacet.retireCarbonmarkListing(C.bct(), 100);
    }
}
