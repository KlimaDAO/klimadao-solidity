/*
 SPDX-License-Identifier: MIT
*/

pragma solidity ^0.8.16;

import "../diamond/AppStorage.sol";

/**
 * @author Publius
 * @title App Storage Library allows libaries to access Klima Infinity's state.
 **/
library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}
