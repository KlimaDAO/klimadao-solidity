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

contract UpgradeInfinityForNativeUsdcTest is TestHelper {
    UpgradeInfinityForNativeUsdc upgradeScript;
    address mockDiamond;
    uint256 deployerPrivateKey;
    uint256 polygonFork;

    // set by env
    address INFINITY_ADDRESS;
    address multisig;
    // testin
    address eoa = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address VCS_1190_2018 = address(0x64de5C0A430B2b15c6a3A7566c3930e1cF9b22DF);

    address seller = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    address buyer = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    ConstantsGetter constantsFacet;

    AppStorage s;

    function getSwapInfo(
        address poolToken,
        address sourceToken
    ) public view returns (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath) {
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

    // //on the forked environment we can't prank a multisig. So for testing "only" reset the owner in contract storage to an anvil EOA to be able to call the txns
    // function setEOAOwner() public returns (address owner) {
    //     // Calculate the storage slot for contractOwner
    //     bytes32 DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");
    //     uint256 contractOwnerSlot = uint256(DIAMOND_STORAGE_POSITION) + 4;

    //     bytes32 ownerFromStorage = vm.load(INFINITY_ADDRESS, bytes32(contractOwnerSlot));
    //     address ownerAddress = address(uint160(uint256(ownerFromStorage)));
    //     require(ownerAddress == multisig, "Current owner is not the multisig");

    //     address newOwner = eoa;

    //     // store the EOA in the owner storage slot
    //     vm.store(INFINITY_ADDRESS, bytes32(contractOwnerSlot), bytes32(uint256(uint160(newOwner))));

    //     // Verify owner change
    //     OwnershipFacet ownershipFacet = OwnershipFacet(INFINITY_ADDRESS);
    //     owner = ownershipFacet.owner();
    //     require(owner == newOwner, "Failed to change owner");
    // }

    function setUp() public {
        upgradeScript = new UpgradeInfinityForNativeUsdc();

        // Set up environment variables
        INFINITY_ADDRESS = vm.envAddress("INFINITY_ADDRESS");
        multisig = vm.envAddress("INFINITY_OWNER_ADDRESS");

        addConstantsGetter(INFINITY_ADDRESS);
        constantsFacet = ConstantsGetter(INFINITY_ADDRESS);
    }

    function verifyUpdatedSwapPaths() public {
        // Test BCT swap path
        (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath) = constantsFacet.getSwapInfo(
            C.bct(),
            C.usdc_bridged()
        );

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

    function verifyExistingSwapPaths() public {
        // Test BCT swap path
        (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath) = constantsFacet.getSwapInfo(
            C.bct(),
            C.usdc_bridged()
        );

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

        // This is based on the assumption that C3SushiInit was ran after Diamond Init () and hence just a single Dex Multi-swap
        // Test UBO swap path
        (swapDexes, ammRouters, swapPath) = constantsFacet.getSwapInfo(C.ubo(), C.usdc_bridged());

        assertEq(swapDexes.length, 1, "Incorrect number of swap dexes for UBO");
        assertEq(swapDexes[0], 0, "Incorrect swap dex for UBO");
        assertEq(ammRouters.length, 1, "Incorrect number of AMM routers for UBO");
        assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for UBO");
        assertEq(swapPath.length, 3, "Incorrect number of addresses in swap path for UBO");

        // This is based on the assumption that C3SushiInit was ran after Diamond Init () and hence just a single Dex Multi-swap
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

    function test_DeploymentOfNewFacetsAndInit() public {
        // Check if RetireCarbonmarkFacet was deployed
        assertTrue(address(upgradeScript.retireCarbonmarkF()) != address(0), "RetireCarbonmarkFacet not deployed");

        // Check if NativeUSDCInit was deployed
        assertTrue(address(upgradeScript.nativeUSDCInitF()) != address(0), "NativeUSDCInit not deployed");
    }

    function test_updated_FacetCutCreation() public {
        IDiamondCut.FacetCut[] memory cuts = upgradeScript.getCuts();

        assertEq(cuts.length, 1, "Incorrect number of cuts");
        assertEq(cuts[0].facetAddress, address(upgradeScript.retireCarbonmarkF()), "Incorrect facet address");

        assertEq(uint256(cuts[0].action), uint256(IDiamondCut.FacetCutAction.Replace), "Incorrect action");

        assertTrue(cuts[0].functionSelectors.length > 0, "No function selectors");
    }

    function test_upgrade_CallDataGeneration() public {
        uint snapshotId = vm.snapshot();

        upgradeScript.run();

        bytes memory usdcInitCalldata = upgradeScript.usdcInitCalldata();
        bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();
        bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

        assertTrue(usdcInitCalldata.length > 0, "USDC init calldata is empty");
        assertTrue(updateSwapPathsCalldata.length > 0, "Update swap paths calldata is empty");
        assertTrue(addNewRetireCarbonmarkFacetCalldata.length > 0, "Add new RetireCarbonmarkFacet calldata is empty");

        vm.revertTo(snapshotId);
    }

    function test_upgrade_swapInit() public {
        uint snapshotId = vm.snapshot();

        verifyUpdatedSwapPaths();

        // (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath) = constantsFacet.getSwapInfo(
        //     C.ubo(),
        //     C.usdc()
        // );

        // console2.log("SUP");
        // console2.log(swapDexes[0]);
        // console2.log("SUP2");
        // console2.log(swapDexes[1]);

        // vm.startPrank(multisig);

        // vm.deal(multisig, 1);

        // upgradeScript.run_test();

        // verifyUpdatedSwapPaths();

        vm.revertTo(snapshotId);
    }

    function test_existingSwapPaths() public {
        verifyExistingSwapPaths();
    }

    // function testSwapInitWithCalldataOnly() public {
    //     upgradeScript.run();

    //     address owner = setEOAOwner();

    //     IDiamondCut.FacetCut[] memory emptyCut = new IDiamondCut.FacetCut[](0);
    //     bytes memory updateSwapPathsCalldata = upgradeScript.updateSwapPathsCalldata();

    //     vm.startPrank(owner);
    //     (bool success, bytes memory returnData) = INFINITY_ADDRESS.call(updateSwapPathsCalldata);
    //     assertTrue(success, "Swap paths update failed");

    //     verifyUpdatedSwapPaths();
    // }

    // function testUpdatedRetireCarbonmarkFacet() public {
    //     upgradeScript.run();

    //     DiamondLoupeFacet loupe = DiamondLoupeFacet(INFINITY_ADDRESS);
    //     address oldFacetAddress = loupe.facetAddress(RetireCarbonmarkFacet.retireCarbonmarkListing.selector);

    //     address owner = setEOAOwner();

    //     bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

    //     vm.startPrank(owner);
    //     IDiamondCut.FacetCut[] memory cut = upgradeScript.getCuts();
    //     IDiamondCut(INFINITY_ADDRESS).diamondCut(cut, address(0), "");
    //     vm.stopPrank();

    //     // Get the facet address after update
    //     address newFacetAddress = loupe.facetAddress(RetireCarbonmarkFacet.retireCarbonmarkListing.selector);

    //     // Verify that the facet address is different
    //     assertNotEq(oldFacetAddress, newFacetAddress, "Facet address should have changed");

    //     verifyUpdatedRetireCarbonmarkFacet();
    // }

    // function testUpdatedRetireCarbonmarkFacetWithCalldataOnly() public {
    //     upgradeScript.run();

    //     address owner = setEOAOwner();

    //     bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

    //     vm.startPrank(owner);
    //     (bool success, bytes memory returnData) = INFINITY_ADDRESS.call(addNewRetireCarbonmarkFacetCalldata);
    //     assertTrue(success, "Add new RetireCarbonmarkFacet failed");
    //     vm.stopPrank();

    //     verifyUpdatedRetireCarbonmarkFacet();
    // }

    // function testRetireCarbonmarkFacetListingWithNativeUSDC() public {
    //     upgradeScript.run();

    //     IDiamondCut.FacetCut[] memory cut = upgradeScript.getCuts();

    //     address carbonmark = constantsFacet.carbonmark();

    //     address owner = setEOAOwner();

    //     vm.prank(owner);
    //     IDiamondCut(INFINITY_ADDRESS).diamondCut(cut, address(0), "");

    //     verifyUpdatedRetireCarbonmarkFacet();

    //     uint256 amount = 15e18;
    //     uint256 unitPrice = 1e6;
    //     uint256 minFillAmount = 1e18;
    //     uint256 deadline = block.timestamp + 100 days;

    //     vm.deal(seller, 1 ether);
    //     deal(VCS_1190_2018, seller, 100e18);

    //     vm.startPrank(seller);
    //     IERC20(VCS_1190_2018).approve(address(INFINITY_ADDRESS), 100e18);
    //     IERC20(VCS_1190_2018).approve(address(carbonmark), 100e18);
    //     bytes32 carbonmarkListingId = ICarbonmark(carbonmark).createListing(
    //         VCS_1190_2018,
    //         amount,
    //         unitPrice,
    //         minFillAmount,
    //         deadline
    //     );
    //     vm.stopPrank();

    //     ICarbonmark.CreditListing memory listing = ICarbonmark.CreditListing({
    //         id: carbonmarkListingId,
    //         account: ICarbonmark(carbonmark).getListingOwner(carbonmarkListingId),
    //         token: VCS_1190_2018,
    //         tokenId: 0,
    //         remainingAmount: ICarbonmark(carbonmark).getRemainingAmount(carbonmarkListingId),
    //         unitPrice: unitPrice
    //     });

    //     LibRetire.RetireDetails memory details = LibRetire.RetireDetails({
    //         retiringAddress: buyer,
    //         retiringEntityString: "Test Retiring Entity",
    //         beneficiaryAddress: buyer,
    //         beneficiaryString: "Test Beneficiary",
    //         retirementMessage: "Test Retirement Message",
    //         beneficiaryLocation: "United States",
    //         consumptionCountryCode: "US",
    //         consumptionPeriodStart: block.timestamp,
    //         consumptionPeriodEnd: block.timestamp + 1 days
    //     });

    //     deal(C.usdc(), buyer, 1000e6);
    //     deal(C.usdc_bridged(), buyer, 0);

    //     uint256 maxAmountIn = (amount * unitPrice) / 1e18;

    //     vm.startPrank(buyer);
    //     IERC20(C.usdc()).approve(address(INFINITY_ADDRESS), 1000e6);
    //     RetireCarbonmarkFacet(INFINITY_ADDRESS).retireCarbonmarkListing(
    //         listing,
    //         1_000_000_000,
    //         amount,
    //         details,
    //         LibTransfer.From.EXTERNAL
    //     );
    //     vm.stopPrank();
    // }
}
