// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LibSwap} from "../../../src/infinity/libraries/TokenSwap/LibSwap.sol";
import {TestHelper} from "../TestHelper.sol";
import {AssertionHelper} from "../../helpers/AssertionHelper.sol";
import {C} from "../../../src/infinity/C.sol";
import {IERC20} from "../../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LibSwapTest is TestHelper, AssertionHelper {
    address poolToken = address(0x2F800Db0fdb5223b3C3f354886d907A671414A7F);

    address defaultFoundrySender = address(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);

    function test_returnTradeDust_NATIVE_USDC() public {
        // give usdc.e dust to contract
        deal(C.usdc_bridged(), address(this), 1e6);

        assertEq(IERC20(C.usdc_bridged()).balanceOf(address(this)), 1e6);
        assertEq(IERC20(C.usdc()).balanceOf(address(this)), 0);

        LibSwap.returnTradeDust(C.usdc(), poolToken);

        assertZeroTokenBalance(C.usdc_bridged(), address(this));
        assertGt(IERC20(C.usdc()).balanceOf(defaultFoundrySender), 999_000);
    }

    function test_returnTradeDust_BRIDGED_USDC() public {
        // give dust to contract
        deal(C.usdc_bridged(), address(this), 1e6);

        vm.prank(defaultFoundrySender);
        LibSwap.returnTradeDust(C.usdc_bridged(), poolToken);

        assertZeroTokenBalance(C.usdc_bridged(), address(this));
        assertGt(IERC20(C.usdc_bridged()).balanceOf(defaultFoundrySender), 999_000);
    }
}
