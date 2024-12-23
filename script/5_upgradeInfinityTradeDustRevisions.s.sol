// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import "../src/infinity/facets/DiamondCutFacet.sol";
import "../src/infinity/facets/DiamondLoupeFacet.sol";
import {RedeemC3PoolFacet} from "../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RedeemToucanPoolFacet} from "../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RetireCarbonFacet} from "../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {NativeUSDCInit} from "../src/infinity/init/NativeUSDCInit.sol";

import "../test/infinity/HelperContract.sol";

contract UpgradeInfinityForTradeDustRevisions is Script, HelperContract {
    RedeemC3PoolFacet public c3RedeemF;
    RedeemToucanPoolFacet public toucanRedeemF;
    RetireCarbonFacet public retireCarbonF;
    IDiamondCut.FacetCut[] public cuts;

    bytes public tradeDustUpdateCallData;

    function getCuts() public view returns (IDiamondCut.FacetCut[] memory) {
        return cuts;
    }

    function getFacets() public view returns (address[] memory) {
        address[] memory newFacets = new address[](3);
        newFacets[0] = address(c3RedeemF);
        newFacets[1] = address(toucanRedeemF);
        newFacets[2] = address(retireCarbonF);
        return newFacets;
    }

    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the four updated facets
        c3RedeemF = new RedeemC3PoolFacet();
        toucanRedeemF = new RedeemToucanPoolFacet();
        retireCarbonF = new RetireCarbonFacet();

        vm.stopBroadcast();

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        // Klima Infinity specific facets

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(c3RedeemF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemC3PoolFacet")
            })
        );

        cuts.push(cut[0]);

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(toucanRedeemF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemToucanPoolFacet")
            })
        );

        cuts.push(cut[1]);

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cuts.push(cut[2]);

        console2.log("New C3 Redeem Facet address");
        console2.logAddress(address(c3RedeemF));

        console2.log("New Toucan Redeem Facet address");
        console2.logAddress(address(toucanRedeemF));

        console2.log("New Retire Carbon Facet address");
        console2.logAddress(address(retireCarbonF));

        tradeDustUpdateCallData = abi.encodeWithSelector(IDiamondCut.diamondCut.selector, cut, address(0), "");

        console2.log("Update Native USDC Revisions Trade Dust Calldata");
        console2.logBytes(tradeDustUpdateCallData);
    }
}
