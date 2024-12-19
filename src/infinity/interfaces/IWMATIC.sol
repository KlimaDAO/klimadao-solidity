// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "oz/token/ERC20/IERC20.sol";

/**
 * @author Cujo
 * @title WMATIC Interface
 *
 */
interface IWMATIC is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}
