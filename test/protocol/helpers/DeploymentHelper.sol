// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/******************************************************************************\
* Authors: Cujo <rawr@cujowolf.dev>
* Helper functions for the common assertions used in testing
/******************************************************************************/

import "forge-std/Test.sol";
import "oz/token/ERC20/IERC20.sol";

import {CarbonRetirementBondDepository} from "../../../src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "../../../src/protocol/allocators/RetirementBondAllocator.sol";

import {IKlimaTreasury} from "../../../src/protocol/interfaces/IKLIMA.sol";

abstract contract DeploymentHelper is Test {
    function deployRetirementBondWithAllocator()
        internal
        returns (address retireBondAddress, address allocatorAddress)
    {
        address POLICY = vm.envAddress("POLICY_MSIG");
        address DAO = vm.envAddress("DAO_MSIG");

        CarbonRetirementBondDepository retireBond = new CarbonRetirementBondDepository();
        retireBond.transferOwnership(POLICY);
        vm.prank(POLICY);
        retireBond.acceptOwnership();

        RetirementBondAllocator allocator = new RetirementBondAllocator(address(retireBond));
        allocator.transferOwnership(POLICY);
        vm.startPrank(POLICY);
        allocator.acceptOwnership();

        retireBond.setAllocator(address(allocator));
        vm.stopPrank();

        vm.startPrank(DAO);
        allocator.updateMaxReservePercent(500); // 5% max
        vm.stopPrank();

        return (address(retireBond), address(allocator));
    }

    function toggleRetirementBondAllocatorWithTreasury(address allocator) internal {
        address TREASURY = vm.envAddress("KLIMA_TREASURY_ADDRESS");
        address DAO = vm.envAddress("DAO_MSIG");

        // Set up and toggle new contract within treasury
        vm.startPrank(DAO);

        IKlimaTreasury(TREASURY).queue(3, allocator);
        vm.roll(IKlimaTreasury(TREASURY).ReserveManagerQueue(allocator));
        IKlimaTreasury(TREASURY).toggle(3, allocator, address(0));

        vm.stopPrank();
    }
}
