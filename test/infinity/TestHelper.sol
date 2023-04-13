// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test, console, stdError} from "forge-std/Test.sol";
import {stdMath} from "forge-std/StdMath.sol";
import {Strings} from "oz/utils/Strings.sol";

import {Users} from "test/helpers/Users.sol";

import "src/retirement_v1/interfaces/IKlimaCarbonRetirements.sol";

// Diamond Deployment
import "../../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "src/infinity/Diamond.sol";
import "src/infinity/facets/DiamondCutFacet.sol";
import "src/infinity/facets/DiamondLoupeFacet.sol";
import {OwnershipFacet} from "src/infinity/facets/OwnershipFacet.sol";
import {RedeemC3PoolFacet} from "src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RetireC3C3TFacet} from "src/infinity/facets/Bridges/C3/RetireC3C3TFacet.sol";
import {RedeemToucanPoolFacet} from "src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RetireToucanTCO2Facet} from "src/infinity/facets/Bridges/Toucan/RetireToucanTCO2Facet.sol";
import {RetireCarbonFacet} from "src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetireInfoFacet} from "src/infinity/facets/Retire/RetireInfoFacet.sol";
import {RetireSourceFacet} from "src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "src/infinity/facets/RetirementQuoter.sol";
import {DiamondInit} from "src/infinity/init/DiamondInit.sol";
import {ConstantsGetter} from "src/infinity/mocks/ConstantsGetter.sol";
import {DustFacet} from "src/infinity/facets/DustFacet.sol";
import "./HelperContract.sol";

abstract contract TestHelper is Test, HelperContract {
    using Strings for uint;

    // Users
    Users users;
    address user;
    address user2;

    // Diamond deployment public key
    address deployerAddress = vm.envAddress("PUBLIC_KEY");

    DiamondCutFacet dCutF;
    DiamondLoupeFacet dLoupeF;
    OwnershipFacet ownerF;
    RedeemC3PoolFacet c3RedeemF;
    RetireC3C3TFacet c3RetireF;
    RedeemToucanPoolFacet toucanRedeemF;
    RetireToucanTCO2Facet toucanRetireF;
    RetireCarbonFacet retireCarbonF;
    RetireInfoFacet retireInfoF;
    RetireSourceFacet retireSourceF;
    RetirementQuoter retirementQuoterF;

    function setupInfinity() internal returns (address) {
        //deploy facets and init contract
        dCutF = new DiamondCutFacet();
        dLoupeF = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        c3RedeemF = new RedeemC3PoolFacet();
        c3RetireF = new RetireC3C3TFacet();
        toucanRedeemF = new RedeemToucanPoolFacet();
        toucanRetireF = new RetireToucanTCO2Facet();
        retireCarbonF = new RetireCarbonFacet();
        retireInfoF = new RetireInfoFacet();
        retireSourceF = new RetireSourceFacet();
        retirementQuoterF = new RetirementQuoter();

        DiamondInit diamondInit = new DiamondInit();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](10);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(dLoupeF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(ownerF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        // Klima Infinity specific facets

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(c3RedeemF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RedeemC3PoolFacet")
            })
        );

        cut[3] = (
            IDiamondCut.FacetCut({
                facetAddress: address(c3RetireF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireC3C3TFacet")
            })
        );

        cut[4] = (
            IDiamondCut.FacetCut({
                facetAddress: address(toucanRedeemF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RedeemToucanPoolFacet")
            })
        );

        cut[5] = (
            IDiamondCut.FacetCut({
                facetAddress: address(toucanRetireF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireToucanTCO2Facet")
            })
        );

        cut[6] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cut[7] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireInfoF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireSourceFacet")
            })
        );

        cut[8] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireSourceF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireInfoFacet")
            })
        );

        cut[9] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retirementQuoterF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );

        // deploy diamond and perform diamondCut
        Diamond diamond = new Diamond(deployerAddress, address(dCutF));
        IDiamondCut(address(diamond)).diamondCut(cut, address(diamondInit), abi.encodeWithSignature("init()"));

        return address(diamond);
    }

    function addConstantsGetter(address infinityDiamond) internal {
        ownerF = OwnershipFacet(infinityDiamond);

        vm.startPrank(ownerF.owner());

        ConstantsGetter constantF = new ConstantsGetter();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(constantF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("ConstantsGetter")
            })
        );

        IDiamondCut(infinityDiamond).diamondCut(cut, address(0), "");
        vm.stopPrank();
    }

    function sendDustToTreasury(address infinityDiamond) internal {
        ownerF = OwnershipFacet(infinityDiamond);

        vm.startPrank(ownerF.owner());

        DustFacet dustF = new DustFacet();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(dustF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("DustFacet")
            })
        );

        IDiamondCut(infinityDiamond).diamondCut(cut, address(0), "");
        DustFacet wrappedDust = DustFacet(infinityDiamond);
        wrappedDust.sendDust();
        vm.stopPrank();
    }

    function initUser() internal {
        users = new Users();
        address[] memory _user = new address[](2);
        _user = users.createUsers(2);
        user = _user[0];
        user2 = _user[1];
    }

    //////////// EVM Helpers ////////////

    function increaseTime(uint _seconds) internal {
        vm.warp(block.timestamp + _seconds);
    }

    modifier prank(address from) {
        vm.startPrank(from);
        _;
        vm.stopPrank();
    }

    //////////// Other Helpers ////////////

    function randomish(uint maxValue) internal view returns (uint) {
        uint seed = uint(keccak256(abi.encodePacked(block.timestamp)));
        return (seed % (maxValue));
    }
}
