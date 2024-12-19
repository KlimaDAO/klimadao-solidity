// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IC3Pool {
    function freeRedeem(uint256 amount) external;

    function taxedRedeem(address[] memory erc20Addresses, uint256[] memory amount) external;

    function getFreeRedeemAddresses() external view returns (address[] memory);

    function getERC20Tokens() external view returns (address[] memory);

    function feeRedeem() external view returns (uint256);
}

interface IC3ProjectToken {
    function offsetFor(uint256 amount, address beneficiary, string memory transferee, string memory reason) external;
}

interface IC3ProjectFactory {
    function isTokenExists(address _address) external returns (bool);
}
