// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/******************************************************************************\
* Authors: Cujo <rawr@cujowolf.dev>
* Helper functions for the common assertions used in testing
/******************************************************************************/

import "forge-std/Test.sol";
import "oz/token/ERC20/IERC20.sol";

abstract contract AssertionHelper is Test {
    function assertZeroTokenBalance(address token, address target) internal {
        assertEq(IERC20(token).balanceOf(target), 0);
    }
}
