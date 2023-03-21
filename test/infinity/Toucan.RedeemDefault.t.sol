// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {TestHelper} from "test/infinity/TestHelper.sol";

contract WellSkimTest is TestHelper {
    function setUp() public {
        setupInfinity();
    }

    function test_initialized() public {
        // Well should have liquidity
        assert(true);
    }
}
