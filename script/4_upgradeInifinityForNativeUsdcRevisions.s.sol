// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import "../src/infinity/facets/DiamondCutFacet.sol";
import "../src/infinity/facets/DiamondLoupeFacet.sol";
import {RedeemC3PoolFacet} from "../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RedeemToucanPoolFacet} from "../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RetirementQuoter} from "../src/infinity/facets/RetirementQuoter.sol";
import {RetireCarbonFacet} from "../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {NativeUSDCInit} from "../src/infinity/init/NativeUSDCInit.sol";

import {console2} from "forge-std/console2.sol";

import "../test/infinity/HelperContract.sol";

contract UpgradeInfinityForNativeUsdcRevisions is Script, HelperContract {
    RedeemC3PoolFacet public c3RedeemF;
    RedeemToucanPoolFacet public toucanRedeemF;
    RetirementQuoter public retirementQuoterF;
    RetireCarbonFacet public retireCarbonF;
    IDiamondCut.FacetCut[] public cuts;

    bytes public nativeUsdcUpdateCalldata;


    function getCuts() public view returns (IDiamondCut.FacetCut[] memory) {
        return cuts;
    }

    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the four updated facets
        c3RedeemF = new RedeemC3PoolFacet();
        toucanRedeemF = new RedeemToucanPoolFacet();
        retirementQuoterF = new RetirementQuoter();
        retireCarbonF = new RetireCarbonFacet();

        vm.stopBroadcast();

        // Given, all the following updates to the Klima Infinity will be 
        // processed by a multiple, when we generate the calldata that will 
        // be plugged to the safeSDK to propose multi-sign txn. 

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](4);

        // Klima Infinity specific facets
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retirementQuoterF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );

        cuts.push(cut[0]);

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cuts.push(cut[1]);

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(toucanRedeemF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemToucanPoolFacet")
            })
        );

        cuts.push(cut[2]);

        cut[3] = (
            IDiamondCut.FacetCut({
                facetAddress: address(c3RedeemF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemC3PoolFacet")
            })
        );

        cuts.push(cut[3]);


        console2.log("New C3 Redeem Facet address");
        console2.logAddress(address(c3RedeemF));

        console2.log("New Toucan Redeem Facet address");
        console2.logAddress(address(toucanRedeemF));

        console2.log("New Retirement Quoter Facet address");
        console2.logAddress(address(retirementQuoterF));

        console2.log("New Retire Carbon Facet address");
        console2.logAddress(address(retireCarbonF));

        nativeUsdcUpdateCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            cut,
            address(0),
            ""
        );

        console2.log("Update Native USDC Revisions Calldata");
        console2.logBytes(nativeUsdcUpdateCalldata);

    }
}
