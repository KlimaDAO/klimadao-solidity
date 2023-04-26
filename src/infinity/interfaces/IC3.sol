// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IC3Pool {
    function freeRedeem(uint amount) external;

    function taxedRedeem(address[] memory erc20Addresses, uint[] memory amount) external;

    function getFreeRedeemAddresses() external view returns (address[] memory);

    function getERC20Tokens() external view returns (address[] memory);

    function feeRedeem() external view returns (uint);
}

interface IC3ProjectToken {
    function offsetFor(uint amount, address beneficiary, string memory transferee, string memory reason) external;
}
