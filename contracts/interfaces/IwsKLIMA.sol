// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../bonds-v2/interfaces/IERC20.sol";

interface IwsKLIMA is IERC20 {
    function wrap(uint256 _amount) external returns (uint256);

    function unwrap(uint256 _amount) external returns (uint256);

    function wKLIMATosKLIMA(uint256 _amount) external view returns (uint256);

    function sKLIMATowKLIMA(uint256 _amount) external view returns (uint256);
}
