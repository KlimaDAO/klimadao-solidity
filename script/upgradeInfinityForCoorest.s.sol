// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import "../src/infinity/facets/DiamondCutFacet.sol";
import "../src/infinity/facets/DiamondLoupeFacet.sol";
import "../src/infinity/facets/OwnershipFacet.sol";
import {RetireCarbonFacet} from "../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetireSourceFacet} from "../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../src/infinity/facets/RetirementQuoter.sol";
import {DiamondInitCoorest} from "../src/infinity/init/DiamondInitCoorest.sol";

import "../test/infinity/HelperContract.sol";

contract UpgradeInfinityForCoorest is Script, HelperContract {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");

        OwnershipFacet ownerF = OwnershipFacet(diamond);

        vm.startBroadcast(deployerPrivateKey);

        //deploy updated facets and init contract
        RetireCarbonFacet retireCarbonF = new RetireCarbonFacet();
        RetirementQuoter retirementQuoterF = new RetirementQuoter();
        RetireSourceFacet retireSourceFacet = new RetireSourceFacet();
        DiamondInitCoorest initCoorestF = new DiamondInitCoorest();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        // Klima Infinity specific facets
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retirementQuoterF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireSourceFacet),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireSourceFacet")
            })
        );

        // deploy diamond and perform diamondCut
        IDiamondCut(address(diamond)).diamondCut(cut, address(initCoorestF), abi.encodeWithSignature("init()"));

        vm.stopBroadcast();
    }
}
