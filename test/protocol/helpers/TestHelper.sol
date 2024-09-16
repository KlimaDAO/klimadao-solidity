// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * \
 * Authors: Cujo <rawr@cujowolf.dev>
 * Helper functions for various protocol tests
 * /*****************************************************************************
 */
import "forge-std/Test.sol";
import "oz-4-8-3/token/ERC20/IERC20.sol";

import {CarbonRetirementBondDepository} from "../../../src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "../../../src/protocol/allocators/RetirementBondAllocator.sol";

import {IKlimaTreasury} from "../../../src/protocol/interfaces/IKLIMA.sol";

abstract contract TestHelper is Test {
    function maxBondAmount(address token, address allocatorAddress) internal returns (uint256 maxAmount) {
        address treasury = vm.envAddress("KLIMA_TREASURY_ADDRESS");
        RetirementBondAllocator allocator = RetirementBondAllocator(allocatorAddress);

        uint256 currentExcessReserves = IKlimaTreasury(treasury).excessReserves() * 1e9;
        uint256 maxExcessReserves =
            (currentExcessReserves * allocator.maxReservePercent()) / allocator.PERCENT_DIVISOR();
        uint256 maxTreasuryHoldings =
            (IERC20(token).balanceOf(treasury) * allocator.maxReservePercent()) / allocator.PERCENT_DIVISOR();

        maxAmount = maxExcessReserves >= maxTreasuryHoldings ? maxTreasuryHoldings : maxExcessReserves;
    }
}
