// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../helpers/AssertionHelper.sol";
import "../helpers/DeploymentHelper.sol";

import {CarbonRetirementBondDepository} from "../../../src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "../../../src/protocol/allocators/RetirementBondAllocator.sol";
import {KlimaTreasury} from "../../../src/protocol/staking/utils/KlimaTreasury.sol";

contract RetireBondFundMarketTest is AssertionHelper, DeploymentHelper {
    CarbonRetirementBondDepository retireBond;
    RetirementBondAllocator allocator;
    KlimaTreasury treasury;

    address POLICY = vm.envAddress("POLICY_MSIG");

    address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
    address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;
    address MCO2 = 0xAa7DbD1598251f856C12f63557A4C4397c253Cea;
    address UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
    address NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;

    function setUp() public {
        (address retireBondAddress, address allocatorAddress) = deployRetirementBondWithAllocator();
        retireBond = CarbonRetirementBondDepository(retireBondAddress);
        allocator = RetirementBondAllocator(allocatorAddress);

        toggleRetirementBondAllocatorWithTreasury(allocatorAddress);
    }

    function test_fundWithBct() public {
        fundBonds(BCT, 1_000_000 * 1e18);
    }

    function test_fundWithNct() public {
        fundBonds(NCT, 35_000 * 1e18);
    }

    function test_fundWithMco2() public {
        fundBonds(MCO2, 250_000 * 1e18);
    }

    function test_fundWithUbo() public {
        fundBonds(UBO, 35_000 * 1e18);
    }

    function test_fundWithNbo() public {
        fundBonds(NBO, 2_500 * 1e18);
    }

    function test_returnBct() public {
        fundBonds(BCT, 1_000_000 * 1e18);
        returnBonds(BCT);
    }

    function test_returnNct() public {
        fundBonds(NCT, 35_000 * 1e18);
        returnBonds(NCT);
    }

    function test_returnMco2() public {
        fundBonds(MCO2, 250_000 * 1e18);
        returnBonds(MCO2);
    }

    function test_returnUbo() public {
        fundBonds(UBO, 35_000 * 1e18);
        returnBonds(UBO);
    }

    function test_returnNbo() public {
        fundBonds(NBO, 2_500 * 1e18);
        returnBonds(NBO);
    }

    function test_fundWithBct_revert_insufficientReserves() public {
        vm.prank(allocator.owner());
        vm.expectRevert("Insufficient reserves");
        allocator.fundBonds(BCT, 15_000_000 * 1e18);
    }

    function test_fundWithBct_revert_notOwner() public {
        vm.prank(retireBond.DAO());
        vm.expectRevert("Ownable: caller is not the owner");
        allocator.fundBonds(BCT, 15_000_000 * 1e18);
    }

    function fundBonds(address token, uint amount) internal {
        vm.prank(allocator.owner());
        allocator.fundBonds(token, amount);

        assertTokenBalance(token, address(retireBond), amount);
        assertZeroTokenBalance(token, address(allocator));
    }

    function returnBonds(address token) internal {
        vm.prank(allocator.owner());
        allocator.closeBonds(token);

        assertZeroTokenBalance(token, address(retireBond));
        assertZeroTokenBalance(token, address(allocator));
    }
}
