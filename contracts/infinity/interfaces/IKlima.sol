// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IStaking {
    function unstake(uint256 _amount, bool _trigger) external;
}

interface IStakingHelper {
    function stake(uint256 _amount) external;
}

interface IwsKLIMA {
    function wrap(uint256 _amount) external returns (uint256);

    function unwrap(uint256 _amount) external returns (uint256);

    function wKLIMATosKLIMA(uint256 _amount) external view returns (uint256);

    function sKLIMATowKLIMA(uint256 _amount) external view returns (uint256);
}
