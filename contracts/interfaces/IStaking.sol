// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IStaking {
    function sKLIMA() external returns (address);
    function KLIMA() external returns (address);
    function unstake(uint256 _amount, bool _trigger) external;
    function stake(uint256 _amount) external;

}
