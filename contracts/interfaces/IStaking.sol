// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStaking {
    function unstake(uint256 _amount, bool _trigger) external;
}
