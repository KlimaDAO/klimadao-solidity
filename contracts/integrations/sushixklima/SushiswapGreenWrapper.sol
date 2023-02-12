// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IUniswapV2Router02.sol";

/**
 * @title Sushiswap Green Swap Wrapper
 * @author KlimaDAO
 *
 * @notice This contracts allows for a sushiswap swap to be offset in a 2nd txn triggered
 *
 */

contract SushiswapGreenSwapWrapper is
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address payable public retirementHoldingAddress;
    address public sushiRouterMain;
    uint256 public sushiAmountOffset;

    event newRetirementHolder(address newHolder);
    event newSushiRouter(address newRouter);
    event newSushiAmountOffset(uint256 newAmount);

    function initialize() public initializer {
        __Ownable_init();
        __Context_init();
    }

    /**
     * @notice This function will do a retirement as well as a swap, while it is \
     * configurable, it can be pre-populated with default values from the Sushi UI
     */

    function GreenSwapTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) public payable {
        // Transfer tokens here and then approve the swap on Sushi
        IERC20Upgradeable(path[0]).safeTransferFrom(
            _msgSender(),
            address(this),
            amountIn
        );
        IERC20Upgradeable(path[0]).safeIncreaseAllowance(
            sushiRouterMain,
            amountIn
        );

        // Perform Swap
        IUniswapV2Router02(sushiRouterMain).swapTokensForExactTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );

        // Send native asset to retirementHolder address
        (bool sent, bytes memory data) = retirementHoldingAddress.call{
            value: sushiAmountOffset
        }("");
        require(sent, "Failed to send Ether");
    }

    function setRetirementHoldingAddress(address _newHoldingAddress)
        public
        onlyOwner
    {
        retirementHoldingAddress = payable(address(_newHoldingAddress));
        emit newRetirementHolder(_newHoldingAddress);
    }

    function setSushiRouterMain(address _newSushiRouter) public onlyOwner {
        sushiRouterMain = _newSushiRouter;
        emit newSushiRouter(sushiRouterMain);
    }

    function setSushiAmountOffset(uint256 _newSushiAmountOffset)
        public
        onlyOwner
    {
        sushiAmountOffset = _newSushiAmountOffset;
        emit newSushiAmountOffset(sushiAmountOffset);
    }
}
