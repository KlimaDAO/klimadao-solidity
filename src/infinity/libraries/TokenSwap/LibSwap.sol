// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @author Cujo
 * @title LibSwap
 */
import "../../C.sol";
import "../LibAppStorage.sol";
import "../LibKlima.sol";
import "../Token/LibTransfer.sol";
import "./LibUniswapV2Swap.sol";
import "./LibTridentSwap.sol";
import "./LibTreasurySwap.sol";

library LibSwap {
    using LibTransfer for IERC20;

    /* ========== Swap to Exact Carbon Default Functions ========== */

    /**
     * @notice                      Swaps to an exact number of carbon tokens
     * @param sourceToken           Source token provided to swap
     * @param carbonToken           Pool token needed
     * @param sourceAmount          Max amount of the source token
     * @param carbonAmount          Needed amount of tokens out
     * @return carbonReceived       Pool tokens actually received
     */
    function swapToExactCarbonDefault(
        address sourceToken,
        address carbonToken,
        uint256 sourceAmount,
        uint256 carbonAmount
    ) internal returns (uint256 carbonReceived) {
        AppStorage storage s = LibAppStorage.diamondStorage();

        // If providing a staked version of Klima, update sourceToken to use Klima default path.
        if (sourceToken == C.sKlima() || sourceToken == C.wsKlima()) sourceToken = C.klima();

        // If source token is not defined in the default, swap to USDC on Sushiswap.
        // This is wrapped in its own statement to allow for the fewest number of swaps
        if (s.swap[carbonToken][sourceToken].swapDexes.length == 0) {
            address[] memory firstPath = new address[](s.swap[carbonToken][C.usdc_bridged()].swapPaths[0].length + 1);
            firstPath[0] = sourceToken;
            for (uint8 i = 0; i < s.swap[carbonToken][C.usdc_bridged()].swapPaths[0].length; ++i) {
                firstPath[i + 1] = s.swap[carbonToken][C.usdc_bridged()].swapPaths[0][i];
            }

            // Now that we have added to the initial USDC path, set the sourceToken to USDC and proceed as normal.
            sourceToken = C.usdc_bridged();

            // Single DEX swap
            if (s.swap[carbonToken][sourceToken].swapDexes.length == 1) {
                return _performToExactSwap(
                    s.swap[carbonToken][sourceToken].swapDexes[0],
                    s.swap[carbonToken][sourceToken].ammRouters[0],
                    firstPath,
                    sourceAmount,
                    carbonAmount
                );
            }

            // Multiple DEX swap
            uint256[] memory amountsIn = getMultipleSourceAmount(sourceToken, carbonToken, carbonAmount);
            carbonReceived = sourceAmount;
            for (uint256 i = 0; i < s.swap[carbonToken][sourceToken].swapDexes.length; ++i) {
                carbonReceived = _performToExactSwap(
                    s.swap[carbonToken][sourceToken].swapDexes[i],
                    s.swap[carbonToken][sourceToken].ammRouters[i],
                    i == 0 ? firstPath : s.swap[carbonToken][sourceToken].swapPaths[uint8(i)],
                    carbonReceived,
                    i + 1 == s.swap[carbonToken][sourceToken].swapDexes.length ? carbonAmount : amountsIn[i + 1]
                );
            }
            return carbonReceived;
        }

        // Single DEX swap
        if (s.swap[carbonToken][sourceToken].swapDexes.length == 1) {
            return _performToExactSwap(
                s.swap[carbonToken][sourceToken].swapDexes[0],
                s.swap[carbonToken][sourceToken].ammRouters[0],
                s.swap[carbonToken][sourceToken].swapPaths[0],
                sourceAmount,
                carbonAmount
            );
        }

        // Multiple DEX swap
        uint256[] memory amountsIn = getMultipleSourceAmount(sourceToken, carbonToken, carbonAmount);
        carbonReceived = sourceAmount;
        for (uint256 i = 0; i < s.swap[carbonToken][sourceToken].swapDexes.length; ++i) {
            carbonReceived = _performToExactSwap(
                s.swap[carbonToken][sourceToken].swapDexes[i],
                s.swap[carbonToken][sourceToken].ammRouters[i],
                s.swap[carbonToken][sourceToken].swapPaths[uint8(i)],
                carbonReceived,
                i + 1 == s.swap[carbonToken][sourceToken].swapDexes.length ? carbonAmount : amountsIn[i + 1]
            );
        }
        return carbonReceived;
    }

    /* ========== Swap to Exact Source Default Functions ========== */

    /**
     * @notice                      Swaps to an exact number of source tokens
     * @param sourceToken           Source token provided to swap
     * @param carbonToken           Pool token needed
     * @param amount                Amount of the source token to swap
     * @return carbonReceived       Pool tokens actually received
     */
    function swapExactSourceToCarbonDefault(address sourceToken, address carbonToken, uint256 amount)
        internal
        returns (uint256 carbonReceived)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();

        // If providing a staked version of Klima, update sourceToken to use Klima default path.
        if (sourceToken == C.sKlima() || sourceToken == C.wsKlima()) sourceToken = C.klima();

        // If source token is not defined in the default, swap to USDC on Sushiswap.
        // Then use the USDC default path.
        if (s.swap[carbonToken][sourceToken].swapDexes.length == 0) {
            address[] memory path = new address[](2);
            path[0] = sourceToken;
            path[1] = C.usdc_bridged();

            amount = _performExactSourceSwap(
                s.swap[carbonToken][C.usdc_bridged()].swapDexes[0],
                s.swap[carbonToken][C.usdc_bridged()].ammRouters[0],
                path,
                amount
            );
            // Now that we have USDC, set the sourceToken to USDC and proceed as normal.
            sourceToken = C.usdc_bridged();
        }

        // Single DEX swap
        if (s.swap[carbonToken][sourceToken].swapDexes.length == 1) {
            return _performExactSourceSwap(
                s.swap[carbonToken][sourceToken].swapDexes[0],
                s.swap[carbonToken][sourceToken].ammRouters[0],
                s.swap[carbonToken][sourceToken].swapPaths[0],
                amount
            );
        }

        // Multiple DEX swap
        uint256 currentOutput;
        for (uint256 i = 0; i < s.swap[carbonToken][sourceToken].swapDexes.length; ++i) {
            currentOutput = _performExactSourceSwap(
                s.swap[carbonToken][sourceToken].swapDexes[i],
                s.swap[carbonToken][sourceToken].ammRouters[i],
                s.swap[carbonToken][sourceToken].swapPaths[uint8(i)],
                i == 0 ? amount : currentOutput
            );
        }
        return currentOutput;
    }

    /**
     * @notice                  Return any dust/slippaged amounts still held by the contract
     * @param sourceToken       Source token provided to swap
     * @param poolToken         Pool token used
     */
    function returnTradeDust(address sourceToken, address poolToken) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        address dustToken = sourceToken;
        if (sourceToken == C.wsKlima() || sourceToken == C.sKlima()) {
            dustToken = C.klima();
        } else if (s.swap[poolToken][sourceToken].swapDexes.length == 0) {
            dustToken = C.usdc_bridged();
            sourceToken = C.usdc_bridged();
        }

        uint256 dustBalance = IERC20(dustToken).balanceOf(address(this));

        if (dustBalance != 0) {
            if (sourceToken == C.wsKlima()) dustBalance = LibKlima.wrapKlima(dustBalance);
            if (sourceToken == C.sKlima()) LibKlima.stakeKlima(dustBalance);

            LibTransfer.sendToken(IERC20(sourceToken), dustBalance, msg.sender, LibTransfer.To.EXTERNAL);
        }
    }

    /* ========== Smaller Specific Swap Functions ========== */

    /**
     * @notice                  Swaps a given amount of USDC for KLIMA using Sushiswap
     * @param sourceAmount      Amount of USDC to swap
     * @param klimaAmount       Amount of KLIMA to swap for
     * @return klimaReceived    Amount of KLIMA received
     */
    function swapToKlimaFromUsdc(uint256 sourceAmount, uint256 klimaAmount) internal returns (uint256 klimaReceived) {
        address[] memory path = new address[](2);
        path[0] = C.usdc_bridged();
        path[1] = C.klima();

        return _performToExactSwap(0, C.sushiRouter(), path, sourceAmount, klimaAmount);
    }

    /**
     * @notice                  Swaps from arbitrary token routed through USDC for KLIMA
     * @param sourceToken       Source token provided to swap
     * @param sourceAmount      Amount of source token to swap
     * @param klimaAmount       Amount of KLIMA to swap for
     * @return klimaReceived    Amount of KLIMA received
     */
    function swapToKlimaFromOther(address sourceToken, uint256 sourceAmount, uint256 klimaAmount)
        internal
        returns (uint256 klimaReceived)
    {
        address[] memory path = new address[](3);
        path[0] = sourceToken;
        path[1] = C.usdc_bridged();
        path[2] = C.klima();
        return _performToExactSwap(0, C.sushiRouter(), path, sourceAmount, klimaAmount);
    }

    /**
     * @notice                  Performs a swap with Retirement Bonds for carbon to retire.
     * @param sourceToken       Source token provided to swap
     * @param carbonToken       Carbon token to receive
     * @param sourceAmount      Amount of source token to swap
     * @param carbonAmount      Amount of carbon token needed
     * @return carbonRecieved   Amount of carbon token received from the swap
     */
    function swapWithRetirementBonds(
        address sourceToken,
        address carbonToken,
        uint256 sourceAmount,
        uint256 carbonAmount
    ) internal returns (uint256 carbonRecieved) {
        // Any form of KLIMA should be unwrapped/unstaked before this is called.
        if (sourceToken == C.klima() || sourceToken == C.sKlima() || sourceToken == C.wsKlima()) {
            LibTreasurySwap.swapToExact(carbonToken, sourceAmount, carbonAmount);
            return carbonAmount;
        }

        // The only other source tokens at this point should be USDC or non-KLIMA and non-Pool tokens

        if (sourceToken == C.usdc_bridged()) {
            sourceAmount = swapToKlimaFromUsdc(sourceAmount, LibTreasurySwap.getAmountIn(carbonToken, carbonAmount));
        } else {
            sourceAmount =
                swapToKlimaFromOther(sourceToken, sourceAmount, LibTreasurySwap.getAmountIn(carbonToken, carbonAmount));
        }

        LibTreasurySwap.swapToExact(carbonToken, sourceAmount, carbonAmount);
        return carbonAmount;
    }

    /* ========== Source Amount View Functions ========== */

    /**
     * @notice                  Get the source amount needed when swapping within a single DEX
     * @param sourceToken       Source token provided to swap
     * @param carbonToken       Pool token used
     * @param amount            Amount of carbon tokens needed
     * @return sourceNeeded     Total source tokens needed for output amount
     */
    function getSourceAmount(address sourceToken, address carbonToken, uint256 amount)
        internal
        view
        returns (uint256 sourceNeeded)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();

        uint8 wrapped;
        if (sourceToken == C.wsKlima()) wrapped = 1;
        if (sourceToken == C.sKlima() || sourceToken == C.wsKlima()) sourceToken = C.klima();

        if (s.swap[carbonToken][sourceToken].swapDexes.length == 1) {
            if (wrapped == 0) {
                return _getAmountIn(
                    s.swap[carbonToken][sourceToken].swapDexes[0],
                    s.swap[carbonToken][sourceToken].ammRouters[0],
                    s.swap[carbonToken][sourceToken].swapPaths[0],
                    amount
                );
            }

            return LibKlima.toWrappedAmount(
                _getAmountIn(
                    s.swap[carbonToken][sourceToken].swapDexes[0],
                    s.swap[carbonToken][sourceToken].ammRouters[0],
                    s.swap[carbonToken][sourceToken].swapPaths[0],
                    amount
                )
            );
        } else if (s.swap[carbonToken][sourceToken].swapDexes.length > 1) {
            uint256[] memory amountsIn = getMultipleSourceAmount(sourceToken, carbonToken, amount);
            if (wrapped == 0) return amountsIn[0];
            return LibKlima.toWrappedAmount(amountsIn[0]);
        } else {
            uint256 usdcAmount = getSourceAmount(C.usdc_bridged(), carbonToken, amount);
            address[] memory usdcPath = new address[](2);
            usdcPath[0] = sourceToken;
            usdcPath[1] = C.usdc_bridged();
            // Swap to USDC on Sushiswap
            return _getAmountIn(0, C.sushiRouter(), usdcPath, usdcAmount);
        }
    }

    /**
     * @notice                  Get the source amount needed when swapping between multiple DEXs
     * @param sourceToken       Source token provided to swap
     * @param carbonToken       Pool token used
     * @param amount            Amount of carbon tokens needed
     * @return sourcesNeeded    Total source tokens needed for output amount
     */
    function getMultipleSourceAmount(address sourceToken, address carbonToken, uint256 amount)
        internal
        view
        returns (uint256[] memory)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();

        uint256[] memory sourcesNeeded = new uint256[](s.swap[carbonToken][sourceToken].swapDexes.length);
        uint256 currentAmount = amount;
        for (uint256 i = 0; i < s.swap[carbonToken][sourceToken].swapDexes.length; ++i) {
            // Work backwards from the path definitions to get total source amount
            uint8 index = uint8(s.swap[carbonToken][sourceToken].swapDexes.length - 1 - i);

            sourcesNeeded[s.swap[carbonToken][sourceToken].swapDexes.length - 1 - i] = _getAmountIn(
                s.swap[carbonToken][sourceToken].swapDexes[index],
                s.swap[carbonToken][sourceToken].ammRouters[index],
                s.swap[carbonToken][sourceToken].swapPaths[index],
                currentAmount
            );

            currentAmount = sourcesNeeded[s.swap[carbonToken][sourceToken].swapDexes.length - 1 - i];
        }

        return sourcesNeeded;
    }

    /**
     * @notice                  Fetches the amount of KLIMA needed for a retirement bond, then calculates the source
     *                          amount needed if a DEX swap is required.
     * @param sourceToken       Source token provided to swap
     * @param carbonToken       Pool token used
     * @param amount            Amount of carbon tokens needed
     * @return sourceNeeded     Total source tokens needed for output amount
     */
    function getSourceAmountFromRetirementBond(address sourceToken, address carbonToken, uint256 amount)
        internal
        view
        returns (uint256 sourceNeeded)
    {
        // Return the direct quote in KLIMA first
        if (sourceToken == C.klima() || sourceToken == C.sKlima()) {
            return LibTreasurySwap.getAmountIn(carbonToken, amount);
        }

        // Wrap the amount if using wsKLIMA
        if (sourceToken == C.wsKlima()) {
            return LibKlima.toWrappedAmount(LibTreasurySwap.getAmountIn(carbonToken, amount));
        }

        // Direct swap from USDC to KLIMA on Sushi
        if (sourceToken == C.usdc_bridged()) {
            uint256 klimaAmount = LibTreasurySwap.getAmountIn(carbonToken, amount);

            address[] memory path = new address[](2);
            path[0] = C.usdc_bridged();
            path[1] = C.klima();

            return LibUniswapV2Swap.getAmountIn(C.sushiRouter(), path, klimaAmount);
        }

        // At this point we only have non USDC and not KLIMA tokens. Route through a source <> USDC pool on Sushi
        uint256 klimaAmount = LibTreasurySwap.getAmountIn(carbonToken, amount);

        address[] memory path = new address[](3);
        path[0] = sourceToken;
        path[1] = C.usdc_bridged();
        path[2] = C.klima();

        return LibUniswapV2Swap.getAmountIn(C.sushiRouter(), path, klimaAmount);
    }

    /* ========== Output Amount View Functions ========== */

    /**
     * @notice                  Get the source amount needed when swapping between multiple DEXs
     * @param sourceToken       Source token provided to swap
     * @param carbonToken       Pool token used
     * @param amount            Amount of carbon tokens needed
     * @return amountOut        Amount of carbonTokens recieved for the input amount
     */
    function getDefaultAmountOut(address sourceToken, address carbonToken, uint256 amount)
        internal
        view
        returns (uint256 amountOut)
    {
        AppStorage storage s = LibAppStorage.diamondStorage();

        amountOut = amount;

        if (sourceToken == C.wsKlima()) amountOut = LibKlima.toUnwrappedAmount(amount);
        if (sourceToken == C.sKlima() || sourceToken == C.wsKlima()) sourceToken = C.klima();

        for (uint8 i = 0; i < s.swap[carbonToken][sourceToken].swapDexes.length; ++i) {
            amountOut = _getAmountOut(
                s.swap[carbonToken][sourceToken].swapDexes[i],
                s.swap[carbonToken][sourceToken].ammRouters[i],
                s.swap[carbonToken][sourceToken].swapPaths[i],
                amountOut
            );
        }
    }

    /* ========== Private Functions ========== */

    /**
     * @notice              Perform a toExact swap depending on the dex provided
     * @param dex           Identifier for which DEX to use
     * @param router        Router for the swap
     * @param path          Trade path to use
     * @param maxAmountIn   Max amount of source tokens to swap
     * @param amount        Total pool tokens needed
     * @return amountOut    Total pool tokens swapped
     */
    function _performToExactSwap(uint8 dex, address router, address[] memory path, uint256 maxAmountIn, uint256 amount)
        private
        returns (uint256 amountOut)
    {
        // UniswapV2 is DEX ID 0
        if (dex == 0) {
            amountOut = LibUniswapV2Swap.swapTokensForExactTokens(router, path, maxAmountIn, amount);
        }
        if (dex == 1) {
            amountOut = LibTridentSwap.swapExactTokensForTokens(
                router,
                LibTridentSwap.getTridentPool(path[0], path[1]),
                path[0],
                LibTridentSwap.getAmountIn(LibTridentSwap.getTridentPool(path[0], path[1]), path[0], path[1], amount),
                amount
            );
        }

        return amountOut;
    }

    /**
     * @notice              Perform a swap using all source tokens
     * @param dex           Identifier for which DEX to use
     * @param router        Router for the swap
     * @param path          Trade path to use
     * @param amount        Amount of tokens to swap
     * @return amountOut    Total pool tokens swapped
     */
    function _performExactSourceSwap(uint8 dex, address router, address[] memory path, uint256 amount)
        private
        returns (uint256 amountOut)
    {
        // UniswapV2 is DEX ID 0
        if (dex == 0) {
            amountOut = LibUniswapV2Swap.swapExactTokensForTokens(router, path, amount);
        } else if (dex == 1) {
            amountOut = LibTridentSwap.swapExactTokensForTokens(
                router, LibTridentSwap.getTridentPool(path[0], path[1]), path[0], amount, 1
            );
        }

        return amountOut;
    }

    /**
     * @notice              Return the amountIn needed for an exact swap
     * @param dex           Identifier for which DEX to use
     * @param router        Router for the swap
     * @param path          Trade path to use
     * @param amount        Total pool tokens needed
     * @return amountIn     Total pool tokens swapped
     */
    function _getAmountIn(uint8 dex, address router, address[] memory path, uint256 amount)
        private
        view
        returns (uint256 amountIn)
    {
        if (dex == 0) {
            amountIn = LibUniswapV2Swap.getAmountIn(router, path, amount);
        } else if (dex == 1) {
            amountIn =
                LibTridentSwap.getAmountIn(LibTridentSwap.getTridentPool(path[0], path[1]), path[0], path[1], amount);
        }
    }

    /**
     * @notice              Return the amountIn needed for an exact swap
     * @param dex           Identifier for which DEX to use
     * @param router        Router for the swap
     * @param path          Trade path to use
     * @param amount        Total source tokens spent
     * @return amountOut    Total pool tokens swapped
     */
    function _getAmountOut(uint8 dex, address router, address[] memory path, uint256 amount)
        private
        view
        returns (uint256 amountOut)
    {
        if (dex == 0) {
            amountOut = LibUniswapV2Swap.getAmountOut(router, path, amount);
        } else if (dex == 1) {
            amountOut =
                LibTridentSwap.getAmountOut(LibTridentSwap.getTridentPool(path[0], path[1]), path[0], path[1], amount);
        }
    }
}
