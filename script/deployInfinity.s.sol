// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * \
 * Authors: Cujo <rawr@cujowolf.dev>
 * EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
 *
 * Script to deploy Infinity diamond with Cut, Loupe, Ownership and Infinity facets
 * /*****************************************************************************
 */

import "forge-std/Script.sol";
import "../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "../src/infinity/Diamond.sol";
import "../src/infinity/facets/DiamondCutFacet.sol";
import "../src/infinity/facets/DiamondLoupeFacet.sol";
import "../src/infinity/facets/OwnershipFacet.sol";
import {RedeemC3PoolFacet} from "../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RetireC3C3TFacet} from "../src/infinity/facets/Bridges/C3/RetireC3C3TFacet.sol";
import {RedeemToucanPoolFacet} from "../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RetireToucanTCO2Facet} from "../src/infinity/facets/Bridges/Toucan/RetireToucanTCO2Facet.sol";
import {RetireCarbonFacet} from "../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetireInfoFacet} from "../src/infinity/facets/Retire/RetireInfoFacet.sol";
import {RetireSourceFacet} from "../src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "../src/infinity/facets/RetirementQuoter.sol";
import {ERC1155ReceiverFacet} from "src/infinity/facets/ERC1155ReceiverFacet.sol";
import {RetireICRFacet} from "src/infinity/facets/Bridges/ICR/RetireICRFacet.sol";
import {DiamondInit} from "../src/infinity/init/DiamondInit.sol";
import "../test/infinity/HelperContract.sol";

import {KlimaCarbonRetirements} from "../src/retirement_v1/KlimaCarbonRetirements.sol";

contract DeployInfinityScript is Script, HelperContract {
    DiamondCutFacet dCutF;
    DiamondLoupeFacet dLoupeF;
    OwnershipFacet ownerF;
    KlimaCarbonRetirements retireStorage;

    function run() external returns (address) {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.envAddress("PUBLIC_KEY");

        vm.startBroadcast(deployerPrivateKey);

        //deploy facets and init contract
        // retireStorage = KlimaCarbonRetirements(0xe6d0C3172bd2964bB632C00D45b1CF260d997dA5);
        retireStorage = new KlimaCarbonRetirements();
        dCutF = new DiamondCutFacet();
        dLoupeF = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        // RedeemC3PoolFacet c3RedeemF = new RedeemC3PoolFacet();
        // RetireC3C3TFacet c3RetireF = new RetireC3C3TFacet();
        // RedeemToucanPoolFacet toucanRedeemF = new RedeemToucanPoolFacet();
        // RetireToucanTCO2Facet toucanRetireF = new RetireToucanTCO2Facet();
        RetireCarbonFacet retireCarbonF = new RetireCarbonFacet();
        RetireInfoFacet retireInfoF = new RetireInfoFacet();
        // RetireSourceFacet retireSourceF = new RetireSourceFacet();
        RetirementQuoter retirementQuoterF = new RetirementQuoter();
        RetireICRFacet retireICRF = new RetireICRFacet();
        ERC1155ReceiverFacet erc1155ReceiverF = new ERC1155ReceiverFacet();

        DiamondInit diamondInit = new DiamondInit();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](7);

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

        // // Klima Infinity specific facets

        // cut[2] = (
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(c3RedeemF),
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: generateSelectors("RedeemC3PoolFacet")
        //     })
        // );

        // cut[3] = (
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(c3RetireF),
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: generateSelectors("RetireC3C3TFacet")
        //     })
        // );

        // cut[4] = (
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(toucanRedeemF),
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: generateSelectors("RedeemToucanPoolFacet")
        //     })
        // );

        // cut[5] = (
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(toucanRetireF),
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: generateSelectors("RetireToucanTCO2Facet")
        //     })
        // );

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cut[3] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireInfoF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireInfoFacet")
            })
        );

        // cut[8] = (
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(retireSourceF),
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: generateSelectors("RetireSourceFacet")
        //     })
        // );

        cut[4] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retirementQuoterF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );

        cut[5] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireICRF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireICRFacet")
            })
        );

        cut[6] = (
            IDiamondCut.FacetCut({
                facetAddress: address(erc1155ReceiverF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("ERC1155ReceiverFacet")
            })
        );

        // // deploy diamond and perform diamondCut
        Diamond diamond = new Diamond(deployerAddress, address(dCutF));
        IDiamondCut(address(diamond)).diamondCut(cut, address(diamondInit), abi.encodeWithSignature("init()"));

        retireStorage.addHelperContract(0xdFb60D6c3787d4e7705A34ea46FF8755C3633031);

        vm.stopBroadcast();

        console.log("Retirement Storage deployed to: %s", address(retireStorage));
        console.log("Main diamond deplyed to: %s", address(diamond));
        // return (address(diamond));
        return address(0);
    }
}
