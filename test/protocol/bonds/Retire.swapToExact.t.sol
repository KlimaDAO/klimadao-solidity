// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../helpers/AssertionHelper.sol";
import "../helpers/DeploymentHelper.sol";

import {CarbonRetirementBondDepository} from "../../../src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "../../../src/protocol/allocators/RetirementBondAllocator.sol";

contract RetireBondSwapToExactTest is AssertionHelper, DeploymentHelper {
    CarbonRetirementBondDepository retireBond;
    RetirementBondAllocator allocator;

    address infinityDiamond = vm.envAddress("INFINITY_ADDRESS");
    address klima = vm.envAddress("KLIMA_ERC20_ADDRESS");
    address SUSHI_LP = vm.envAddress("SUSHI_BCT_LP");
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

        vm.startPrank(vm.envAddress("POLICY_MSIG"));

        retireBond.setPoolReference(BCT, vm.envAddress("SUSHI_BCT_LP"));
        retireBond.updateMaxSlippage(BCT, 200);
        retireBond.updateDaoFee(BCT, 3000);

        retireBond.setPoolReference(NCT, vm.envAddress("SUSHI_NCT_LP"));
        retireBond.updateMaxSlippage(NCT, 200);
        retireBond.updateDaoFee(NCT, 3000);

        retireBond.setPoolReference(MCO2, vm.envAddress("MCO2_QUICKSWAP"));
        retireBond.updateMaxSlippage(MCO2, 200);
        retireBond.updateDaoFee(MCO2, 3000);

        retireBond.setPoolReference(UBO, vm.envAddress("TRIDENT_UBO_LP"));
        retireBond.updateMaxSlippage(UBO, 200);
        retireBond.updateDaoFee(UBO, 3000);

        retireBond.setPoolReference(NBO, vm.envAddress("TRIDENT_NBO_LP"));
        retireBond.updateMaxSlippage(NBO, 200);
        retireBond.updateDaoFee(NBO, 3000);

        allocator.fundBonds(BCT, 1_000_000 * 1e18);
        allocator.fundBonds(NCT, 35_000 * 1e18);
        allocator.fundBonds(MCO2, 250_000 * 1e18);
        allocator.fundBonds(UBO, 35_000 * 1e18);
        allocator.fundBonds(NBO, 2_500 * 1e18);
        vm.stopPrank();
    }

    function test_RetireBond_swapToExact_onlyInfinity() public {
        vm.expectRevert("Caller is not Infinity");
        retireBond.swapToExact(BCT, 1e18);
    }

    function test_RetireBond_swapToExact_noTokensRevert() public {
        vm.prank(retireBond.INFINITY());
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        retireBond.swapToExact(BCT, 1e18);
    }

    function test_RetireBond_swapToExact_noKlimaRevert() public {
        vm.prank(retireBond.INFINITY());
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        retireBond.swapToExact(BCT, 1e18);
    }

    function test_RetireBond_swapToExact(uint retireAmount) public {
        // Limit the total amount for fuzzing to an amount that won't break UniV2 quoting
        vm.assume(retireAmount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100);

        // Set up and fund infinity contract with KLIMA
        uint klimaSupply = IERC20(klima).totalSupply();
        uint daoKlima = IERC20(klima).balanceOf(retireBond.DAO());
        fundInfinityWithKlima(daoKlima);

        if (retireAmount == 0) vm.expectRevert("UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        uint klimaNeeded = retireBond.getKlimaAmount(retireAmount, BCT);

        vm.startPrank(retireBond.INFINITY());

        IERC20(klima).approve(address(retireBond), daoKlima);

        if (retireAmount == 0) {
            vm.expectRevert("Cannot swap for zero tokens");
            retireBond.swapToExact(BCT, retireAmount);
        } else if (klimaNeeded > daoKlima) {
            vm.expectRevert();
            retireBond.swapToExact(BCT, retireAmount);
        } else {
            retireBond.swapToExact(BCT, retireAmount);

            assertTokenBalance(BCT, address(retireBond), 1_000_000 * 1e18 - retireAmount);
            assertTokenBalance(klima, retireBond.INFINITY(), (daoKlima) - klimaNeeded);
            assertTokenBalance(klima, retireBond.DAO(), (klimaNeeded * 3000) / 10000);
            assertEq(klimaSupply - (klimaNeeded - ((klimaNeeded * 3000) / 10000)), IERC20(klima).totalSupply());
        }
        vm.stopPrank();
    }

    function fundInfinityWithKlima(uint amount) internal {
        vm.prank(retireBond.DAO());
        IERC20(klima).transfer(infinityDiamond, amount);
    }
}
