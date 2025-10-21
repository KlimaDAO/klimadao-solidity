// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/infinity/interfaces/IDiamondCut.sol";
import {UpgradeBCTSwapPaths} from "../src/infinity/init/UpgradeBCTSwapPaths.sol";
import {RetireCarbonFacet} from "../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetireSourceFacet} from "../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../src/infinity/facets/RetirementQuoter.sol";
import {RedeemToucanPoolFacet} from "../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RedeemC3PoolFacet} from "../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {console2} from "forge-std/console2.sol";
import "../test/infinity/HelperContract.sol";

contract UpgradeBCTSwapPathsScript is Script, HelperContract {
    UpgradeBCTSwapPaths public UpgradeBCTSwapPathsInit;
    RetireCarbonFacet public retireCarbonF;
    RetireSourceFacet public retireSourceF;
    RetirementQuoter public retirementQuoterF;
    RedeemToucanPoolFacet public redeemToucanPoolF;
    RedeemC3PoolFacet public redeemC3PoolF;

    bytes public updateSwapPathsCalldata;
    bytes public updateFacetsCalldata;

    function run() external returns (bytes memory swapPathsCalldata, bytes memory facetsCalldata) {
        uint256 proposerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(proposerPrivateKey);

        // Deploy init contract
        UpgradeBCTSwapPathsInit = new UpgradeBCTSwapPaths();

        // Deploy updated facets
        retireCarbonF = new RetireCarbonFacet();
        retireSourceF = new RetireSourceFacet();
        retirementQuoterF = new RetirementQuoter();
        redeemToucanPoolF = new RedeemToucanPoolFacet();
        redeemC3PoolF = new RedeemC3PoolFacet();

        vm.stopBroadcast();

        // Generate calldata for multisig - swap paths update
        updateSwapPathsCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            new IDiamondCut.FacetCut[](0), // No facet changes
            address(UpgradeBCTSwapPathsInit),
            abi.encodeWithSignature("init()")
        );

        // FacetCut array for all facet replacements
        IDiamondCut.FacetCut[] memory facetCuts = _buildFacetCuts();

        updateFacetsCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            facetCuts,
            address(0),
            ""
        );

        console2.log("UpgradeBCTSwapPaths Init Address:");
        console2.logAddress(address(UpgradeBCTSwapPathsInit));
        console2.log("\nSwap Paths Update Calldata:");
        console2.logBytes(updateSwapPathsCalldata);

        console2.log("\nNew RetirementQuoter Address:");
        console2.logAddress(address(retirementQuoterF));

        console2.log("\nNew RetireSourceFacet Address:");
        console2.logAddress(address(retireSourceF));

        console2.log("\nNew RetireCarbonFacet Address:");
        console2.logAddress(address(retireCarbonF));
        console2.log("\nNew RedeemToucanPoolFacet Address:");
        console2.logAddress(address(redeemToucanPoolF));
        console2.log("\nNew RedeemC3PoolFacet Address:");
        console2.logAddress(address(redeemC3PoolF));
        console2.log("\nFacet Update Calldata:");
        console2.logBytes(updateFacetsCalldata);

        return (updateSwapPathsCalldata, updateFacetsCalldata);
    }

    function _buildFacetCuts() internal returns (IDiamondCut.FacetCut[] memory facetCuts) {
        facetCuts = new IDiamondCut.FacetCut[](5);
        facetCuts[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retirementQuoterF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );
        facetCuts[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );
        facetCuts[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireSourceF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireSourceFacet")
            })
        );
        facetCuts[3] = (
            IDiamondCut.FacetCut({
                facetAddress: address(redeemToucanPoolF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemToucanPoolFacet")
            })
        );
        facetCuts[4] = (
            IDiamondCut.FacetCut({
                facetAddress: address(redeemC3PoolF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemC3PoolFacet")
            })
        );

        return facetCuts;
    }
}
