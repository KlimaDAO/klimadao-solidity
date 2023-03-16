// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IToucanPool {
    function redeemAuto2(uint256 amount)
        external
        returns (address[] memory tco2s, uint256[] memory amounts);

    function redeemMany(address[] calldata erc20s, uint256[] calldata amounts)
        external;

    function feeRedeemPercentageInBase() external pure returns (uint256);

    function feeRedeemDivider() external pure returns (uint256);

    function redeemFeeExemptedAddresses(address) external view returns (bool);
}
