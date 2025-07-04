// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * \
 * Authors: Timo Neumann <timo@fyde.fi>
 * EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
 * Helper functions for the translation from the jest tests in the original repo
 * to solidity tests.
 * /*****************************************************************************
 */
import "../../lib/solidity-stringutils/strings.sol";
import "../../src/infinity/interfaces/IDiamond.sol";
import "../../src/infinity/interfaces/IDiamondLoupe.sol";
import "../../lib/forge-std/src/Test.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract HelperContract is IDiamond, IDiamondLoupe, Test {
    using strings for *;

    // return array of function selectors for given facet name
    function generateSelectors(string memory _facetName) internal returns (bytes4[] memory selectors) {
        //get string of contract methods
        string[] memory cmd = new string[](5);
        cmd[0] = "forge";
        cmd[1] = "inspect";
        cmd[2] = _facetName;
        cmd[3] = "methods";
        cmd[4] = "--json";

        bytes memory res = vm.ffi(cmd);
        string memory st = string(res);

        // extract function signatures and take first 4 bytes of keccak
        strings.slice memory s = st.toSlice();

        strings.slice memory delim = ":".toSlice();
        strings.slice memory delim2 = ",".toSlice();
        selectors = new bytes4[]((s.count(delim)));
        for (uint256 i = 0; i < selectors.length; i++) {
            s.split('"'.toSlice());
            selectors[i] = bytes4(s.split(delim).until('"'.toSlice()).keccak());
            s.split(delim2);
        }
        return selectors;
    }

    // helper to remove index from bytes4[] array
    function removeElement(uint256 index, bytes4[] memory array) public pure returns (bytes4[] memory) {
        bytes4[] memory newarray = new bytes4[](array.length - 1);
        uint256 j = 0;
        for (uint256 i = 0; i < array.length; i++) {
            if (i != index) {
                newarray[j] = array[i];
                j += 1;
            }
        }
        return newarray;
    }

    // helper to remove value from bytes4[] array
    function removeElement(bytes4 el, bytes4[] memory array) public pure returns (bytes4[] memory) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == el) {
                return removeElement(i, array);
            }
        }
        return array;
    }

    function containsElement(bytes4[] memory array, bytes4 el) public pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == el) {
                return true;
            }
        }

        return false;
    }

    function containsElement(address[] memory array, address el) public pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == el) {
                return true;
            }
        }

        return false;
    }

    function sameMembers(bytes4[] memory array1, bytes4[] memory array2) public pure returns (bool) {
        if (array1.length != array2.length) {
            return false;
        }
        for (uint256 i = 0; i < array1.length; i++) {
            if (containsElement(array1, array2[i])) {
                return true;
            }
        }

        return false;
    }

    function getAllSelectors(address diamondAddress) public view returns (bytes4[] memory) {
        Facet[] memory facetList = IDiamondLoupe(diamondAddress).facets();

        uint256 len = 0;
        for (uint256 i = 0; i < facetList.length; i++) {
            len += facetList[i].functionSelectors.length;
        }

        uint256 pos = 0;
        bytes4[] memory selectors = new bytes4[](len);
        for (uint256 i = 0; i < facetList.length; i++) {
            for (uint256 j = 0; j < facetList[i].functionSelectors.length; j++) {
                selectors[pos] = facetList[i].functionSelectors[j];
                pos += 1;
            }
        }
        return selectors;
    }

    // implement dummy override functions
    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external {}

    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_) {}

    function facetAddresses() external view returns (address[] memory facetAddresses_) {}

    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_) {}

    function facets() external view returns (Facet[] memory facets_) {}

    /**
     * Sends transferAmount token from sender to receiver
     */
    function swipeERC20Tokens(address token, uint256 transferAmount, address sender, address receiver)
        public
        returns (uint256 newReceiverBalance)
    {
        uint256 initialSenderBalance = IERC20(token).balanceOf(sender);
        require(transferAmount <= initialSenderBalance);

        uint256 initialReceiverBalance = IERC20(token).balanceOf(receiver);

        // Impersonate sender
        vm.prank(sender);

        // Approve the test contract to spend tokens on behalf of sender
        IERC20(token).approve(address(this), transferAmount);

        // Transfer ERC20 tokens from sender to receiver
        IERC20(token).transferFrom(sender, receiver, transferAmount);

        // Check if the receiver contract received the tokens
        uint256 newBalance = IERC20(token).balanceOf(receiver);
        assertEq(newBalance, (initialReceiverBalance + transferAmount));

        // Reset msg.sender to the test contract
        vm.prank(address(this));
        return newBalance;
    }
}
