// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../helpers/AssertionHelper.sol";

import {CarbonRetirementBondDepository} from "../../../src/protocol/bonds/CarbonRetirementBondDepository.sol";

contract RetireBondSwapToExactTest is AssertionHelper {
    CarbonRetirementBondDepository retireBond;

    address infinityDiamond = vm.envAddress("INFINITY_ADDRESS");
    address bct = vm.envAddress("BCT_ERC20_ADDRESS");
    address klima = vm.envAddress("KLIMA_ERC20_ADDRESS");
    address SUSHI_LP = vm.envAddress("SUSHI_BCT_LP");
    address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
    address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;
    address MCO2 = 0xAa7DbD1598251f856C12f63557A4C4397c253Cea;
    address UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
    address NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;

    function setUp() public {
        retireBond = new CarbonRetirementBondDepository();

        retireBond.setPoolReference(BCT, SUSHI_LP);
        retireBond.updateMaxSlippage(BCT, 200);
        retireBond.updateDaoFee(BCT, 3000);
    }

    function test_RetireBond_swapToExact_onlyInfinity() public {
        vm.expectRevert("Caller is not Infinity");
        retireBond.swapToExact(bct, 1e18);
    }

    function test_RetireBond_swapToExact_noTokensRevert() public {
        vm.prank(retireBond.INFINITY());
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        retireBond.swapToExact(bct, 1e18);
    }

    function test_RetireBond_swapToExact_noKlimaRevert() public {
        fundWithBct(100 * 1e18);
        vm.prank(retireBond.INFINITY());
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        retireBond.swapToExact(bct, 1e18);
    }

    function test_RetireBond_swapToExact(uint retireAmount) public {
        // Limit the total amount for fuzzing to an amount that won't break UniV2 quoting
        vm.assume(retireAmount < (IERC20(bct).balanceOf(SUSHI_LP) * 50) / 100);

        // Set up and fund retirement and infinitycontracts
        fundWithBct(retireAmount + (100 * 1e18));

        uint klimaSupply = IERC20(klima).totalSupply();
        uint daoKlima = IERC20(klima).balanceOf(retireBond.DAO());
        fundInfinityWithKlima(daoKlima);

        if (retireAmount == 0) vm.expectRevert("UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        uint klimaNeeded = retireBond.getKlimaAmount(retireAmount, bct);

        vm.startPrank(retireBond.INFINITY());

        IERC20(klima).approve(address(retireBond), daoKlima);

        if (retireAmount == 0) {
            vm.expectRevert("Cannot swap for zero tokens");
            retireBond.swapToExact(bct, retireAmount);
        } else if (klimaNeeded > daoKlima) {
            vm.expectRevert();
            retireBond.swapToExact(bct, retireAmount);
        } else {
            retireBond.swapToExact(bct, retireAmount);

            assertTokenBalance(bct, address(retireBond), 100 * 1e18);
            assertTokenBalance(klima, retireBond.INFINITY(), (daoKlima) - klimaNeeded);
            assertTokenBalance(klima, retireBond.DAO(), (klimaNeeded * 3000) / 10000);
            assertEq(klimaSupply - (klimaNeeded - ((klimaNeeded * 3000) / 10000)), IERC20(klima).totalSupply());
        }
        vm.stopPrank();
    }

    function fundWithBct(uint amount) internal {
        vm.prank(retireBond.TREASURY());
        IERC20(bct).transfer(address(retireBond), amount);
    }

    function fundInfinityWithKlima(uint amount) internal {
        vm.prank(retireBond.DAO());
        IERC20(klima).transfer(infinityDiamond, amount);
    }
}
