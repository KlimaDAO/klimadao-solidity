// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../helpers/AssertionHelper.sol";
import "../helpers/DeploymentHelper.sol";
import "../helpers/TestHelper.sol";

import {CarbonRetirementBondDepository} from "../../../src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "../../../src/protocol/allocators/RetirementBondAllocator.sol";

contract RetireBondSwapToExactTest is AssertionHelper, DeploymentHelper, TestHelper {
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

    uint256 maxBctBond;

    function setUp() public {
        (address retireBondAddress, address allocatorAddress) = deployRetirementBondWithAllocator();
        retireBond = CarbonRetirementBondDepository(retireBondAddress);
        allocator = RetirementBondAllocator(allocatorAddress);

        toggleRetirementBondAllocatorWithTreasury(allocatorAddress);

        vm.startPrank(vm.envAddress("POLICY_MSIG"));

        retireBond.setPoolReference(BCT, vm.envAddress("SUSHI_BCT_LP"));
        retireBond.updateMaxSlippage(BCT, 200);
        retireBond.updateDaoFee(BCT, 3000);

        maxBctBond = maxBondAmount(BCT, address(allocator));

        allocator.fundBonds(BCT, maxBondAmount(BCT, address(allocator)));
        vm.stopPrank();
    }

    function test_protocol_RetireBond_swapToExact_onlyInfinity() public {
        vm.expectRevert("Caller is not Infinity");
        retireBond.swapToExact(BCT, 1e18);
    }

    function test_protocol_RetireBond_swapToExact_noTokensRevert() public {
        vm.prank(retireBond.INFINITY());
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        retireBond.swapToExact(BCT, 1e18);
    }

    function test_protocol_RetireBond_swapToExact_noKlimaRevert() public {
        vm.prank(retireBond.INFINITY());
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        retireBond.swapToExact(BCT, 1e18);
    }

    function test_protocol_RetireBond_swapToExact(uint256 retireAmount) public {
        // Limit the total amount for fuzzing to an amount that won't break UniV2 quoting
        vm.assume(retireAmount < (IERC20(BCT).balanceOf(SUSHI_LP) * 50) / 100 && retireAmount < maxBctBond);

        // Set up and fund infinity contract with KLIMA
        uint256 klimaSupply = IERC20(klima).totalSupply();
        uint256 daoKlima = IERC20(klima).balanceOf(retireBond.DAO());
        fundInfinityWithKlima(daoKlima);

        if (retireAmount == 0) vm.expectRevert("UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        uint256 klimaNeeded = retireBond.getKlimaAmount(retireAmount, BCT);

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

            assertTokenBalance(BCT, address(retireBond), maxBctBond - retireAmount);
            assertTokenBalance(klima, retireBond.INFINITY(), (daoKlima) - klimaNeeded);
            assertTokenBalance(klima, retireBond.DAO(), (klimaNeeded * 3000) / 10_000);
            assertEq(klimaSupply - (klimaNeeded - ((klimaNeeded * 3000) / 10_000)), IERC20(klima).totalSupply());
        }
        vm.stopPrank();
    }

    function fundInfinityWithKlima(uint256 amount) internal {
        vm.prank(retireBond.DAO());
        IERC20(klima).transfer(infinityDiamond, amount);
    }
}
