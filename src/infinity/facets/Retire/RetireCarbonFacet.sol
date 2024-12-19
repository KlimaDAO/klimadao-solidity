// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../libraries/LibRetire.sol";
import "../../libraries/TokenSwap/LibSwap.sol";
import "../../ReentrancyGuard.sol";

// Import the Uniswap V3 interfaces
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract RetireCarbonFacet is ReentrancyGuard {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address poolToken,
        uint256 retiredAmount
    );

    /* ========== Default Redemption Retirements ========== */

    /**
     * @notice                     Retires an exact amount of carbon using default redemption
     * @param sourceToken          Source ERC-20 token to use for the retirement
     * @param poolToken            Pool token to use for this retirement
     * @param maxAmountIn          Maximum amount of source tokens to spend in this retirement
     * @param retireAmount         The amount of carbon to retire
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function retireExactCarbonDefault(
        address sourceToken,
        address poolToken,
        uint256 maxAmountIn,
        uint256 retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external payable nonReentrant returns (uint256 retirementIndex) {
        require(retireAmount > 0, "Cannot retire zero tonnes");

        uint256 totalCarbon = LibRetire.getTotalCarbon(retireAmount);

        address originalSourceToken = sourceToken;

        if (sourceToken == poolToken) {
            require(totalCarbon == maxAmountIn, "Incorrect pool amount");
        }

        LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

        // after this point the contract has bridged usdc
        if (sourceToken == C.usdc()) {
            (sourceToken, maxAmountIn) = LibSwap.swapNativeUsdcToBridgedUsdc(maxAmountIn);
            originalSourceToken = C.usdc();
        }

        if (sourceToken != poolToken) {
            if (sourceToken == C.wsKlima()) {
                maxAmountIn = LibKlima.unwrapKlima(maxAmountIn);
            }
            if (sourceToken == C.sKlima()) LibKlima.unstakeKlima(maxAmountIn);

            uint256 carbonReceived;
            if (IERC20(poolToken).balanceOf(C.klimaRetirementBond()) >= totalCarbon) {
                carbonReceived = LibSwap.swapWithRetirementBonds(sourceToken, poolToken, maxAmountIn, totalCarbon);
            } else {
                carbonReceived = LibSwap.swapToExactCarbonDefault(sourceToken, poolToken, maxAmountIn, totalCarbon);
            }

            require(carbonReceived >= totalCarbon, "Swap not enough");
            totalCarbon = carbonReceived;

            // Check for any trade dust and send back
            LibSwap.returnTradeDust(originalSourceToken, poolToken);
        }

        LibRetire.retireReceivedCarbon(
            poolToken,
            retireAmount,
            msg.sender,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage
        );

        // Send any aggregator fees to treasury
        if (totalCarbon - retireAmount > 0) {
            LibTransfer.sendToken(IERC20(poolToken), totalCarbon - retireAmount, C.treasury(), LibTransfer.To.EXTERNAL);
        }

        return LibRetire.getTotalRetirements(beneficiaryAddress);
    }

    /* ========== Specific Redemption Retirements ========== */

    /**
     * @notice                     Retires an exact amount of carbon using specific redemption
     * @param sourceToken          Source ERC-20 token to use for the retirement
     * @param poolToken            Pool token to use for this retirement
     * @param projectToken         Project token to redeem and retire
     * @param maxAmountIn          Maximum amount of source tokens to spend in this retirement
     * @param retireAmount         The amount of carbon to retire
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function retireExactCarbonSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint256 maxAmountIn,
        uint256 retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external payable nonReentrant returns (uint256 retirementIndex) {
        require(retireAmount > 0, "Cannot retire zero tonnes");

        uint256 totalCarbon = LibRetire.getTotalCarbonSpecific(poolToken, retireAmount);

        address originalSourceToken = sourceToken;

        if (sourceToken == poolToken) {
            require(totalCarbon == maxAmountIn, "Incorrect pool amount");
        }

        LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

        // after this point the contract has bridged usdc
        if (sourceToken == C.usdc()) {
            (sourceToken, maxAmountIn) = LibSwap.swapNativeUsdcToBridgedUsdc(maxAmountIn);
            originalSourceToken = C.usdc();
        }

        if (sourceToken != poolToken) {
            if (sourceToken == C.wsKlima()) {
                maxAmountIn = LibKlima.unwrapKlima(maxAmountIn);
            }
            if (sourceToken == C.sKlima()) LibKlima.unstakeKlima(maxAmountIn);

            uint256 carbonReceived;
            if (IERC20(poolToken).balanceOf(C.klimaRetirementBond()) >= totalCarbon) {
                carbonReceived = LibSwap.swapWithRetirementBonds(sourceToken, poolToken, maxAmountIn, totalCarbon);
            } else {
                carbonReceived = LibSwap.swapToExactCarbonDefault(sourceToken, poolToken, maxAmountIn, totalCarbon);
            }

            // Check for any trade dust and send back. need to account for bridged --> native here
            LibSwap.returnTradeDust(originalSourceToken, poolToken);

            require(carbonReceived >= totalCarbon, "Swap not enough");
            totalCarbon = carbonReceived;
        }

        uint256 redeemedPool = LibRetire.retireReceivedExactCarbonSpecific(
            poolToken,
            projectToken,
            retireAmount, // Note: Bridge specific fee gets added in this function call.
            msg.sender,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage
        );

        // Send any aggregator fees to treasury
        if (totalCarbon - redeemedPool > 0) {
            LibTransfer.sendToken(IERC20(poolToken), totalCarbon - redeemedPool, C.treasury(), LibTransfer.To.EXTERNAL);
        }

        return LibRetire.getTotalRetirements(beneficiaryAddress);
    }
}
