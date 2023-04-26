// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "oz/token/ERC20/IERC20.sol";

interface IwsKLIMA is IERC20 {
    function sKLIMA() external returns (address);

    function wrap(uint256 _amount) external returns (uint256);

    function unwrap(uint256 _amount) external returns (uint256);

    function wKLIMATosKLIMA(uint256 _amount) external view returns (uint256);

    function sKLIMATowKLIMA(uint256 _amount) external view returns (uint256);
}
