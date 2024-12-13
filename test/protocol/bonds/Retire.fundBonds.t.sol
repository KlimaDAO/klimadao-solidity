// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../helpers/AssertionHelper.sol";
import "../helpers/DeploymentHelper.sol";
import "../helpers/TestHelper.sol";

import {CarbonRetirementBondDepository} from "src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "src/protocol/allocators/RetirementBondAllocator.sol";
import {KlimaTreasury} from "src/protocol/staking/utils/KlimaTreasury.sol";

contract RetireBondFundMarketTest is TestHelper, AssertionHelper, DeploymentHelper {
    CarbonRetirementBondDepository retireBond;
    RetirementBondAllocator allocator;
    KlimaTreasury treasury;

    event MarketOpened(address pool, uint256 amount);
    event MarketClosed(address pool, uint256 amount);

    address POLICY = vm.envAddress("POLICY_MSIG");
    address TREASURY = vm.envAddress("KLIMA_TREASURY_ADDRESS");

    address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
    address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;
    address MCO2 = 0xAa7DbD1598251f856C12f63557A4C4397c253Cea;
    address UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
    address NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;

    function setUp() public {
        (address retireBondAddress, address allocatorAddress) = deployRetirementBondWithAllocator();
        retireBond = CarbonRetirementBondDepository(retireBondAddress);
        allocator = RetirementBondAllocator(allocatorAddress);
        treasury = KlimaTreasury(TREASURY);

        toggleRetirementBondAllocatorWithTreasury(allocatorAddress);
    }

    function test_protocol_retireBond_fundWithBct_fuzz(uint256 amount) public {
        fundBonds(BCT, amount);
    }

    function test_protocol_retireBond_fundWithNct_fuzz(uint256 amount) public {
        fundBonds(NCT, amount);
    }

    function test_protocol_retireBond_fundWithMco2_fuzz(uint256 amount) public {
        fundBonds(MCO2, amount);
    }

    function test_protocol_retireBond_fundWithUbo_fuzz(uint256 amount) public {
        fundBonds(UBO, amount);
    }

    function test_protocol_retireBond_fundWithNbo_fuzz(uint256 amount) public {
        fundBonds(NBO, amount);
    }

    function test_protocol_retireBond_returnBct_fuzz(uint256 amount) public {
        fundBonds(BCT, amount);
        returnBonds(BCT);
    }

    function test_protocol_retireBond_returnNct_fuzz(uint256 amount) public {
        fundBonds(NCT, amount);
        returnBonds(NCT);
    }

    function test_protocol_retireBond_returnMco2_fuzz(uint256 amount) public {
        fundBonds(MCO2, amount);
        returnBonds(MCO2);
    }

    function test_protocol_retireBond_returnUbo_fuzz(uint256 amount) public {
        fundBonds(UBO, amount);
        returnBonds(UBO);
    }

    function test_protocol_retireBond_returnNbo_fuzz(uint256 amount) public {
        fundBonds(NBO, amount);
        returnBonds(NBO);
    }

    function test_protocol_retireBond_fundWithBct_revert_insufficientReserves() public {
        vm.prank(retireBond.DAO());
        allocator.updateMaxReservePercent(100_000);

        vm.prank(allocator.owner());
        vm.expectRevert("Insufficient reserves");
        allocator.fundBonds(BCT, 15_000_000 * 1e18);
    }

    function test_protocol_retireBond_fundWithBct_revert_notOwner() public {
        vm.prank(retireBond.DAO());
        vm.expectRevert("Ownable: caller is not the owner");
        allocator.fundBonds(BCT, 15_000_000 * 1e18);
    }

    function fundBonds(address token, uint256 amount) internal {
        vm.startPrank(allocator.owner());

        if (amount > maxBondAmount(token, address(allocator))) {
            vm.expectRevert("Bond amount exceeds limit");
            allocator.fundBonds(token, amount);
        } else {
            vm.expectEmit(true, true, true, true);
            emit MarketOpened(token, amount);

            allocator.fundBonds(token, amount);

            assertTokenBalance(token, address(retireBond), amount);
            assertZeroTokenBalance(token, address(allocator));
        }

        vm.stopPrank();
    }

    function returnBonds(address token) internal {
        uint256 tokenBalance = IERC20(token).balanceOf(address(retireBond));

        vm.expectEmit(true, true, true, true);
        emit MarketClosed(token, tokenBalance);

        vm.prank(allocator.owner());
        allocator.closeBonds(token);

        assertZeroTokenBalance(token, address(retireBond));
        assertZeroTokenBalance(token, address(allocator));
    }
}
