// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "oz/access/Ownable2Step.sol";
import "oz/token/ERC20/utils/SafeERC20.sol";

import {IUniswapV2Router01} from "src/protocol/interfaces/IUniswapV2Router01.sol";
import {IStaking} from "src/protocol/interfaces/IKLIMA.sol";

/**
 * @title KlimaLiquidityBootstrap
 * @author Cujo
 * @notice A contract for bootstrapping KLIMA paired liquidity using sKLIMA as collateral.
 */
contract KlimaLiquidityBootstrap is Ownable2Step {
    using SafeERC20 for IERC20;

    // https://dev.sushi.com/docs/Products/Classic%20AMM/Deployment%20Addresses
    address public constant SUSHI_V2_ROUTER = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    /* ===== KLIMA PROTOCOL CONSTANTS ===== */
    address public constant KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
    address public constant SKLIMA = 0xb0C22d8D350C67420f06F48936654f567C73E8C8;
    address public constant DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;
    address public constant STAKING = 0x25d28a24Ceb6F81015bB0b2007D795ACAc411b4d;

    address public immutable depositor;
    address public immutable pairToken;
    uint256 public immutable pairTokenDecimals;

    /// @dev Expressed in the number of Klima per native token multipled by KLIMA decimals (9)
    ///      0.5 KLIMA per pair token = 5e8
    uint256 public immutable bootstrapPrice;

    mapping(address => uint256) public depositedAmount;

    address public deployedLiquidityToken;
    uint256 public currentDebt;
    uint256 public heldLiquidity;

    bool public liquidityDeployed;

    event Deposit(address depositor, address token, uint256 amount);
    event Withdraw(address depositor, address token, uint256 amount);
    event Bootstrap(address token0, address token1, uint256 token0Amount, uint256 token1Amount);
    event IncreaseDebt(uint256 amount);
    event RepayDebt(uint256 amount);

    constructor(address _depositor, address _pairToken, uint256 _pairTokenDecimals, uint256 _bootstrapPrice) {
        depositor = _depositor;
        pairToken = _pairToken;
        pairTokenDecimals = _pairTokenDecimals;
        bootstrapPrice = _bootstrapPrice;
    }

    function deposit(address token, uint256 amount) external {
        require(msg.sender == depositor || msg.sender == DAO, "Depositor not whitelisted");

        require(token == pairToken || token == SKLIMA, "Token not whitelisted");

        if (token == pairToken) {
            // Only allow cleanly divisible amounts for pair token deposits
            require((amount * 1e9 / (10 ** pairTokenDecimals)) % bootstrapPrice == 0);
        } else if (token == SKLIMA) {
            // Only allow whole KLIMA token deposits
            require(amount % 1e9 == 0);
        }

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        depositedAmount[token] += amount;
        emit Deposit(msg.sender, token, amount);
    }

    function deployLiquidity() external onlyOwner {
        require(!liquidityDeployed);
        liquidityDeployed = true;

        // Get the amount of KLIMA based on pair token balance
        uint256 pairBalance = IERC20(pairToken).balanceOf(address(this));

        uint256 klimaAmount = pairBalance * bootstrapPrice / (10 ** pairTokenDecimals);

        // Must have deposited enough sKLIMA to bootstrap
        require(IERC20(SKLIMA).balanceOf(address(this)) >= klimaAmount);

        // Transfer in the KLIMA to pair with
        IERC20(KLIMA).safeTransferFrom(DAO, address(this), klimaAmount);

        IERC20(KLIMA).safeIncreaseAllowance(SUSHI_V2_ROUTER, klimaAmount);
        IERC20(pairToken).safeIncreaseAllowance(SUSHI_V2_ROUTER, pairBalance);

        (uint256 deployedToken0Amount, uint256 deployedToken1Amount, uint256 deployedLiquidity) = IUniswapV2Router01(
            SUSHI_V2_ROUTER
        ).addLiquidity(
            KLIMA, pairToken, klimaAmount, pairBalance, klimaAmount, pairBalance, address(this), block.timestamp
        );

        heldLiquidity = deployedLiquidity;
        currentDebt = klimaAmount;

        emit IncreaseDebt(currentDebt);
        emit Bootstrap(KLIMA, pairToken, deployedToken0Amount, deployedToken1Amount);
    }

    function repayDebt(address token, uint256 amount) external {
        require(msg.sender == depositor, "Only depositor can repay debt");

        require(token == KLIMA || token == SKLIMA, "Can only repay in KLIMA");

        uint256 repayAmount = amount;

        if (token == SKLIMA) {
            uint256 currentStaked = IERC20(SKLIMA).balanceOf(address(this));
            if (currentStaked >= currentDebt) {
                repayAmount = currentStaked - currentDebt;

                IERC20(SKLIMA).safeIncreaseAllowance(STAKING, repayAmount);
                IStaking(STAKING).unstake(repayAmount, false);
                IERC20(KLIMA).safeTransfer(DAO, repayAmount);
            }
        } else {
            IERC20(KLIMA).safeTransferFrom(msg.sender, DAO, amount);
        }

        uint256 unlockedLiquidity = heldLiquidity * repayAmount / currentDebt;
        currentDebt -= repayAmount;
        heldLiquidity -= unlockedLiquidity;

        IERC20(deployedLiquidityToken).safeTransfer(depositor, unlockedLiquidity);

        emit RepayDebt(repayAmount);
    }

    function updateDeployedLiquidityToken(address token) external onlyOwner {
        deployedLiquidityToken = token;
    }

    function withdraw(address token, uint256 amount) external {
        require(msg.sender == depositor);
        if (token == SKLIMA) {
            uint256 tokenBalance = IERC20(SKLIMA).balanceOf(address(this));
            if (currentDebt < tokenBalance) {
                amount = tokenBalance - currentDebt;
            }
        }

        IERC20(token).safeTransfer(msg.sender, amount);
        emit Withdraw(depositor, token, amount);
    }

    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}
