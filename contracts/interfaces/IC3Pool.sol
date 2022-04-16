// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IC3Pool {
    function freeRedeem(uint256 amount) external;

    function taxedRedeem(
        address[] memory erc20Addresses,
        uint256[] memory amount
    ) external;

    function getFreeRedeemAddresses() external view returns (address[] memory);

    function feeRedeem() external view returns (uint256);
}
