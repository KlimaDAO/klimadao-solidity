// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../../src/infinity/interfaces/IDiamondCut.sol";
import "../../src/infinity/Diamond.sol";
import "../../src/infinity/facets/DiamondCutFacet.sol";
import "../../src/infinity/facets/DiamondLoupeFacet.sol";
import {RedeemC3PoolFacet} from "../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RedeemToucanPoolFacet} from "../../src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RetirementQuoter} from "../../src/infinity/facets/RetirementQuoter.sol";
import {RetireCarbonFacet} from "../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {NativeUSDCInit} from "../../src/infinity/init/NativeUSDCInit.sol";

import {console2} from "forge-std/console2.sol";

import "../../test/infinity/HelperContract.sol";

contract Rollback_UpgradeInfinityForNativeUsdcRevisions is Script, HelperContract {

    bytes public rollback_nativeUsdcUpdateCalldata;


    function getCuts() public view returns (IDiamondCut.FacetCut[] memory) {
        return cuts;
    }

    function run() external {


        /**
        * To Rollback 4_upgradeInifinityForNativeUSDCRevisions.s.sol:
        * 1) check out commit: f40794f0c0185039f0f5ae1ec2487ba9b0976ad8
        * 2) Create a multisig proposal based on previous templates
        * 3) run this script and copy calldata into the multi sig txn
        * 4) run the multisig script and complete txn in safe
        */

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](4);

        // Klima Infinity specific facets
        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(0xd93dB3d041902b87BBAa3B0d41EDFd8766f70EB3),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );

        cuts.push(cut[0]);

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(0x3fB90DcE452e89A545A43aF8225CFE1adc02B3d4),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cuts.push(cut[1]);

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(0x3eC904bF51f34D984748Bcefd6F132ccC12aCc7A),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemToucanPoolFacet")
            })
        );

        cuts.push(cut[2]);

        cut[3] = (
            IDiamondCut.FacetCut({
                facetAddress: address(0xf76015860Bfa5Fa0C82682DAeF5f0723f55443cD),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RedeemC3PoolFacet")
            })
        );

        cuts.push(cut[3]);


        rollback_nativeUsdcUpdateCalldata = abi.encodeWithSelector(
            IDiamondCut.diamondCut.selector,
            cut,
            address(0),
            ""
        );

        console2.log("Rollback Native USDC Revisions Calldata");
        console2.logBytes(rollback_nativeUsdcUpdateCalldata);

    }
}
