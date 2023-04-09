// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IKlimaRetirementBond {
    function swapToExact(address poolToken, uint256 amount) external;

    function swapFromExact(address poolToken, uint256 amount) external returns (uint amountOut);

    function getKlimaAmount(uint256 poolAmount, address poolToken) external view returns (uint256 klimaNeeded);
}
