// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../script/3_upgradeInfinityForNativeUsdc.sol";
import "../../../src/infinity/interfaces/IDiamondCut.sol";
import "../../../src/infinity/facets/DiamondCutFacet.sol";
import "../../../src/infinity/facets/DiamondLoupeFacet.sol";
import "../../../src/infinity/libraries/LibAppStorage.sol";
import {RetireCarbonmarkFacet} from "../../../src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";
import {NativeUSDCInit} from "../../../src/infinity/init/NativeUSDCInit.sol";
import {C} from "../../../src/infinity/C.sol";
import {LibDiamond} from "../../../src/infinity/libraries/LibDiamond.sol";
import {OwnershipFacet} from "../../../src/infinity/facets/OwnershipFacet.sol";

import {TestHelper} from "../TestHelper.sol";

contract UpgradeInfinityForNativeUsdcTest is TestHelper {
    UpgradeInfinityForNativeUsdc upgradeScript;
    address mockDiamond;
    uint256 deployerPrivateKey;
    address owner = address(0x843dE2e99449834cd6C6456Bd35894d0B157B947);

    AppStorage s;

    function getSwapInfo(address poolToken, address sourceToken)
        public
        view
        returns (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath)
    {
        Storage.DefaultSwap storage defaultSwap = s.swap[poolToken][sourceToken];
        swapDexes = defaultSwap.swapDexes;
        ammRouters = defaultSwap.ammRouters;
        swapPath = defaultSwap.swapPaths[0]; // Assuming we want the first swap path
        return (swapDexes, ammRouters, swapPath);
    }

    function setUp() public {
        upgradeScript = new UpgradeInfinityForNativeUsdc();
        mockDiamond = address(0x1234567890123456789012345678901234567890);
        deployerPrivateKey = 0xabc123;

        // Set up environment variables
        vm.setEnv("PRIVATE_KEY", vm.toString(deployerPrivateKey));
        vm.setEnv("INFINITY_ADDRESS", vm.toString(mockDiamond));
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
        bytes memory diamondCutCalldata = upgradeScript.diamondCutCalldata();
        bytes memory addNewRetireCarbonmarkFacetCalldata = upgradeScript.addNewRetireCarbonmarkFacetCalldata();

        assertTrue(usdcInitCalldata.length > 0, "USDC init calldata is empty");
        assertTrue(diamondCutCalldata.length > 0, "Diamond cut calldata is empty");
        assertTrue(addNewRetireCarbonmarkFacetCalldata.length > 0, "Add new RetireCarbonmarkFacet calldata is empty");
    }

    function testSwapInit() public {
        upgradeScript.run();
        // create diamond instance
        address payable INFINITY_ADDRESS = payable(vm.envAddress("INFINITY_ADDRESS"));
        Diamond diamond = Diamond(INFINITY_ADDRESS);

        // update diamond storage
        IDiamondCut.FacetCut[] memory emptyCut = new IDiamondCut.FacetCut[](0);
        bytes memory usdcInitCalldata = upgradeScript.usdcInitCalldata();

        ownerF = OwnershipFacet(INFINITY_ADDRESS);

        vm.deal(owner, 1);

        vm.prank(owner);
        // IDiamondCut(INFINITY_ADDRESS).diamondCut(emptyCut, address(0), usdcInitCalldata);

        // // Test BCT swap path
        // (uint8[] memory swapDexes, address[] memory ammRouters, address[] memory swapPath) =
        //     getSwapInfo(C.bct(), C.usdc_bridged());
        // console2.log("shit");
        // console2.log(swapDexes[0]);
        // console2.log("shit2");
        // console2.log(ammRouters[0]);
        // console2.log("shit3");
        // console2.log(swapPath[0]);
        // assertEq(swapDexes[0], 0, "Incorrect swap dex for BCT");
        // assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for BCT");
        // assertEq(swapPath[0], C.usdc_bridged(), "Incorrect first address in swap path for BCT");
        // assertEq(swapPath[1], C.klima(), "Incorrect second address in swap path for BCT");
        // assertEq(swapPath[2], C.bct(), "Incorrect third address in swap path for BCT");

        // // Test NCT swap path
        // (swapDexes, ammRouters, swapPath) = getSwapInfo(C.nct(), C.usdc_bridged());
        // assertEq(swapDexes.length, 1, "Incorrect number of swap dexes for NCT");
        // assertEq(swapDexes[0], 0, "Incorrect swap dex for NCT");
        // assertEq(ammRouters.length, 1, "Incorrect number of AMM routers for NCT");
        // assertEq(ammRouters[0], C.sushiRouter(), "Incorrect AMM router for NCT");
        // assertEq(swapPath.length, 2, "Incorrect number of addresses in swap path for NCT");
        // assertEq(swapPath[0], C.usdc_bridged(), "Incorrect first address in swap path for NCT");
        // assertEq(swapPath[1], C.nct(), "Incorrect second address in swap path for NCT");
    }

    //     function testRetireCarbonmarkListingWithNativeUSDC() public {
    //     // Run the upgrade script
    //     upgradeScript.run();

    //     address payable INFINITY_ADDRESS = payable(vm.envAddress("INFINITY_ADDRESS"));
    //     // Deploy the DiamondCutFacet and DiamondLoupeFacet
    //     Diamond diamond = Diamond(INFINITY_ADDRESS);

    // }
}
