// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

import "forge-std/Script.sol";
import "src/infinity/interfaces/IDiamondCut.sol";
import "src/infinity/facets/OwnershipFacet.sol";
import "../test/infinity/HelperContract.sol";

contract DeployScript is Script, HelperContract {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // address deployerAddress = vm.envAddress("PUBLIC_KEY");
        address diamond = vm.envAddress("INFINITY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        OwnershipFacet newOwnerF = new OwnershipFacet();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](2);

        bytes4[] memory add = new bytes4[](2);
        bytes4[] memory replace = new bytes4[](2);

        add[0] = 0x79ba5097; // acceptOwnership
        add[1] = 0xe30c3978; // pendingOwner
        replace[0] = 0x8da5cb5b; // owner
        replace[1] = 0xf2fde38b; // transferOwnership

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(newOwnerF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: replace
            })
        );
        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(newOwnerF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: add
            })
        );
        // deploy diamond
        IDiamondCut(diamond).diamondCut(cut, address(0), "");

        vm.stopBroadcast();
    }
}
