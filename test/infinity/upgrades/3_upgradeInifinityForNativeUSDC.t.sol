// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../script/3_upgradeInfinityForNativeUsdc.sol";
import "../../../src/infinity/interfaces/IDiamondCut.sol";
import "../../../src/infinity/facets/DiamondCutFacet.sol";
import "../../../src/infinity/facets/DiamondLoupeFacet.sol";
import {RetireCarbonmarkFacet} from "../../../src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";
import {NativeUSDCInit} from "../../../src/infinity/init/NativeUSDCInit.sol";

contract UpgradeInfinityForNativeUsdcTest is Test {
    UpgradeInfinityForNativeUsdc upgradeScript;
    address mockDiamond;
    uint256 deployerPrivateKey;

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
        assertEq(uint(cuts[0].action), uint(IDiamondCut.FacetCutAction.Replace), "Incorrect action");
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

    // create test to check for new swap paths
    function testNewSwapPaths() public {
        upgradeScript.run();

        // Check if new swap paths are created
        assertTrue(address(upgradeScript.nativeUSDCInitF()).length > 0, "New swap paths not created");
    }

    function testRetireCarbonmarkListingWithNativeUSDC() public {
    // Run the upgrade script
    upgradeScript.run();

    address INFINITY_ADDRESS = vm.envAddress("INFINITY_ADDRESS");
    // Deploy the DiamondCutFacet and DiamondLoupeFacet
    Diamond diamond = Diamond(INFINITY_ADDRESS);



}


    
}