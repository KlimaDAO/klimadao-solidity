// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../helpers/AssertionHelper.sol";
import "../helpers/DeploymentHelper.sol";
import "../helpers/TestHelper.sol";

import {CarbonRetirementBondDepository} from "src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "src/protocol/allocators/RetirementBondAllocator.sol";
import {KlimaTreasury} from "src/protocol/staking/utils/KlimaTreasury.sol";
import {KlimaLiquidityBootstrap} from "src/protocol/liquidity/KlimaLiquidityBootstrap.sol";
import {SafeERC20} from "src/protocol/interfaces/IKLIMA.sol";
import {IStakingHelper} from "src/infinity/interfaces/IKlima.sol";
import {IUniswapV2Router02} from "src/protocol/interfaces/IUniswapV2Router02.sol";

import {console} from "forge-std/console.sol";

contract LiquidityBootstrapTest is TestHelper, AssertionHelper, DeploymentHelper {
    using SafeERC20 for IERC20;

    address DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;

    address public KLIMA = vm.envAddress("KLIMA_ERC20_ADDRESS");
    address public SKLIMA = vm.envAddress("SKLIMA_ERC20_ADDRESS");
    address public constant STAKING_HELPER = 0x4D70a031Fc76DA6a9bC0C922101A05FA95c3A227;
    address public constant STAKING = 0x25d28a24Ceb6F81015bB0b2007D795ACAc411b4d;

    address depositor = 0x5a755a0955187eB8047536d10d769930bBc36CA8;
    address pairToken = 0x82B37070e43C1BA0EA9e2283285b674eF7f1D4E2;
    uint256 pairTokenDecimals = 18;
    uint256 bootstrapPrice = 1e7;

    KlimaLiquidityBootstrap bootstrap;

    function setUp() public {
        bootstrap = new KlimaLiquidityBootstrap(depositor, pairToken, pairTokenDecimals, bootstrapPrice);
        bootstrap.transferOwnership(DAO);
        vm.prank(DAO);
        bootstrap.acceptOwnership();
    }

    function test_protocol_bootstrap_deposit_allowed() public {
        uint256 depositAmount = 24_000_000;
        vm.startPrank(depositor);
        IERC20(pairToken).safeIncreaseAllowance(address(bootstrap), depositAmount);
        bootstrap.deposit(pairToken, depositAmount);
    }

    function test_protocol_bootstrap_deploy() public {
        uint256 depositAmount = 2_400_000 * 1e18;
        uint256 klimaAmount = 24_000 * 1e9;

        vm.startPrank(depositor);

        IERC20(KLIMA).safeIncreaseAllowance(STAKING_HELPER, klimaAmount);
        IStakingHelper(STAKING_HELPER).stake(klimaAmount);

        IERC20(pairToken).safeIncreaseAllowance(address(bootstrap), depositAmount);

        IERC20(SKLIMA).safeIncreaseAllowance(address(bootstrap), klimaAmount);

        bootstrap.deposit(pairToken, depositAmount);
        bootstrap.deposit(SKLIMA, klimaAmount);

        vm.startPrank(DAO);

        IERC20(KLIMA).safeIncreaseAllowance(address(bootstrap), klimaAmount);

        bootstrap.deployLiquidity();
        bootstrap.updateDeployedLiquidityToken(0x4D2263FF85e334C1f1d04C6262F6c2580335a93C);

        vm.stopPrank();
    }

    function test_protocol_bootstrap_repayDebt() public {
        uint256 depositAmount = 2_400_000 * 1e18;
        uint256 klimaAmount = 24_000 * 1e9;

        vm.startPrank(depositor);

        IERC20(KLIMA).safeIncreaseAllowance(STAKING_HELPER, klimaAmount);
        IStakingHelper(STAKING_HELPER).stake(klimaAmount);

        IERC20(pairToken).safeIncreaseAllowance(address(bootstrap), depositAmount);

        IERC20(SKLIMA).safeIncreaseAllowance(address(bootstrap), klimaAmount);

        bootstrap.deposit(pairToken, depositAmount);
        bootstrap.deposit(SKLIMA, klimaAmount);

        vm.startPrank(DAO);

        IERC20(KLIMA).safeIncreaseAllowance(address(bootstrap), klimaAmount);

        bootstrap.deployLiquidity();
        bootstrap.updateDeployedLiquidityToken(0x4D2263FF85e334C1f1d04C6262F6c2580335a93C);

        vm.startPrank(depositor);

        console.log("======Pre Repay======");
        console.log("SKLIMA Balance for bootstrap contract: %s", IERC20(SKLIMA).balanceOf(address(bootstrap)));
        console.log("Liquidity current debt: %s", bootstrap.currentDebt());
        console.log("Liquidity held value: %s", bootstrap.heldLiquidity());
        console.log(
            "Liquidity token balance: %s",
            IERC20(0x4D2263FF85e334C1f1d04C6262F6c2580335a93C).balanceOf(address(bootstrap))
        );

        bootstrap.repayDebt(SKLIMA, 0);
        vm.stopPrank();

        console.log("======Post repay=======");
        console.log("SKLIMA Balance for bootstrap contract: %s", IERC20(SKLIMA).balanceOf(address(bootstrap)));
        console.log("Liquidity current debt: %s", bootstrap.currentDebt());
        console.log("Liquidity held value: %s", bootstrap.heldLiquidity());
        console.log(
            "Liquidity token balance: %s",
            IERC20(0x4D2263FF85e334C1f1d04C6262F6c2580335a93C).balanceOf(address(bootstrap))
        );
    }

    function test_protocol_bootstrap_swap() public {
        uint256 depositAmount = 2_400_000 * 1e18;
        uint256 klimaAmount = 24_000 * 1e9;

        vm.startPrank(depositor);

        IERC20(KLIMA).safeIncreaseAllowance(STAKING_HELPER, klimaAmount);
        IStakingHelper(STAKING_HELPER).stake(klimaAmount);

        IERC20(pairToken).safeIncreaseAllowance(address(bootstrap), depositAmount);

        IERC20(SKLIMA).safeIncreaseAllowance(address(bootstrap), klimaAmount);

        bootstrap.deposit(pairToken, depositAmount);
        bootstrap.deposit(SKLIMA, klimaAmount);

        vm.startPrank(DAO);

        IERC20(KLIMA).safeIncreaseAllowance(address(bootstrap), klimaAmount);

        bootstrap.deployLiquidity();
        bootstrap.updateDeployedLiquidityToken(0x4D2263FF85e334C1f1d04C6262F6c2580335a93C);

        address router = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

        uint256 amountIn = 100e9;
        uint256 amountOut = 1e18;
        address[] memory path = new address[](2);
        path[0] = KLIMA;
        path[1] = pairToken;

        IERC20(KLIMA).safeIncreaseAllowance(router, 1000e9);
        IERC20(pairToken).safeIncreaseAllowance(router, 1000e18);

        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, amountOut, path, address(this), block.timestamp
        );

        amountIn = 100e18;
        amountOut = 1e9;
        path[0] = pairToken;
        path[1] = KLIMA;

        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, amountOut, path, address(this), block.timestamp
        );
    }
}
