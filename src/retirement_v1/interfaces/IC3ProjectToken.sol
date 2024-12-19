// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IC3ProjectToken {
    function offsetFor(uint256 amount, address beneficiary, string memory transferee, string memory reason) external;
}
