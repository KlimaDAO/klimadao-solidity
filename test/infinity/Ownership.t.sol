// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {TestHelper} from "./TestHelper.sol";

import {OwnershipFacet} from "src/infinity/facets/OwnershipFacet.sol";
import "src/infinity/interfaces/IDiamondCut.sol";

contract Ownership is TestHelper {
    address diamond = vm.envAddress("INFINITY_ADDRESS");

    function test_ownershipTransfer() public {
        ownerF = OwnershipFacet(diamond);

        address newOwner = 0x843dE2e99449834cd6C6456Bd35894d0B157B947;
        address oldOwner = ownerF.owner();
        vm.startPrank(oldOwner);
        upgradeDiamond();

        ownerF.transferOwnership(newOwner);

        assertEq(newOwner, ownerF.pendingOwner());

        vm.startPrank(newOwner);
        ownerF.acceptOwnership();

        assertEq(newOwner, ownerF.owner());
        assertEq(address(0), ownerF.pendingOwner());

        upgradeDiamondFullReplace(false);
        vm.startPrank(oldOwner);
        upgradeDiamondFullReplace(true);
    }

    function upgradeDiamond() internal {
        OwnershipFacet newOwnerF = new OwnershipFacet();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](2);

        bytes4[] memory add = new bytes4[](2);
        bytes4[] memory replace = new bytes4[](2);

        add[0] = 0x79ba5097;
        add[1] = 0xe30c3978;
        replace[0] = 0x8da5cb5b;
        replace[1] = 0xf2fde38b;

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
    }

    function upgradeDiamondFullReplace(bool expectRevert) internal {
        OwnershipFacet newOwnerF = new OwnershipFacet();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(newOwnerF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        if (expectRevert) vm.expectRevert();
        // deploy diamond
        IDiamondCut(diamond).diamondCut(cut, address(0), "");
    }
}
