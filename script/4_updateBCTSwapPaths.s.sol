// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import {UpdateBCTSwapPaths} from "../src/infinity/init/UpdateBCTSwapPaths.sol";
import {RetireCarbonFacet} from "../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {console2} from "forge-std/console2.sol";
import "../test/infinity/HelperContract.sol";

contract UpdateBCTSwapPathsScript is Script, HelperContract {
    UpdateBCTSwapPaths public updateBCTSwapPathsInit;
    RetireCarbonFacet public retireCarbonF;
    IDiamondCut.FacetCut[] public cuts;

    bytes public updateSwapPathsCalldata;
    bytes public updateRetireCarbonFacetCalldata;

    function getCuts() public view returns (IDiamondCut.FacetCut[] memory) {
        return cuts;
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy init contract
        updateBCTSwapPathsInit = new UpdateBCTSwapPaths();

        // Deploy updated RetireCarbonFacet
        retireCarbonF = new RetireCarbonFacet();

        vm.stopBroadcast();

        // Generate calldata for multisig - swap paths update
        updateSwapPathsCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            new IDiamondCut.FacetCut[](0), // No facet changes
            address(updateBCTSwapPathsInit),
            abi.encodeWithSignature("init()")
        );

        // FacetCut array for RetireCarbonFacet update
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cuts.push(cut[0]);

        updateRetireCarbonFacetCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            cut,
            address(0),
            ""
        );

        console2.log("UpdateBCTSwapPaths Init Address:");
        console2.logAddress(address(updateBCTSwapPathsInit));
        console2.log("\nSwap Paths Update Calldata:");
        console2.logBytes(updateSwapPathsCalldata);

        console2.log("\nNew RetireCarbonFacet Address:");
        console2.logAddress(address(retireCarbonF));
        console2.log("\nRetireCarbonFacet Update Calldata:");
        console2.logBytes(updateRetireCarbonFacetCalldata);
    }
}
