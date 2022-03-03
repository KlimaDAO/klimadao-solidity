// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IToucanPool {
    function getScoredTCO2s() external view returns (address[] memory);

    function redeemAuto(uint256 amount) external;
}
