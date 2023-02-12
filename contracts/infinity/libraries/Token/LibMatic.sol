/*
 SPDX-License-Identifier: MIT
*/

pragma solidity ^0.8.16;

import "../LibAppStorage.sol";

/**
 * @author Cujo
 * @title LibMatic
 **/

library LibMatic {
    function refundMatic() internal {
        //AppStorage storage s = LibAppStorage.diamondStorage();
        if (address(this).balance > 0) {
            (bool success, ) = msg.sender.call{value: address(this).balance}(new bytes(0));
            require(success, "Matic transfer Failed.");
        }
    }
}
