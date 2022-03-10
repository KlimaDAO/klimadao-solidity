// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IToucanPool {
    function redeemAuto2(uint256 amount) external returns (address[] memory, uint256[] memory);
}
