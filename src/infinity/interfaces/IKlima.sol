// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IStaking {
    function unstake(uint _amount, bool _trigger) external;
}

interface IStakingHelper {
    function stake(uint _amount) external;
}

interface IwsKLIMA {
    function wrap(uint _amount) external returns (uint);

    function unwrap(uint _amount) external returns (uint);

    function wKLIMATosKLIMA(uint _amount) external view returns (uint);

    function sKLIMATowKLIMA(uint _amount) external view returns (uint);
}

interface IKlimaRetirementBond {
    function swapToExact(address poolToken, uint256 amount) external;

    function getKlimaAmount(uint256 poolAmount, address poolToken) external view returns (uint256 klimaNeeded);

    function owner() external returns (address);
}
