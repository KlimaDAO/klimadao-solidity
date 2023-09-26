// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../libraries/LibRetire.sol";
import "../../libraries/TokenSwap/LibSwap.sol";
import "../../ReentrancyGuard.sol";

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

    struct RetirementDetails {
        address poolToken;
        address projectToken;
        uint256 retireAmount;
        string retiringEntityString;
        address beneficiaryAddress;
        string beneficiaryString;
        string retirementMessage;
    }

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

        if (sourceToken == poolToken) {
            require(totalCarbon == maxAmountIn, "Incorrect pool amount");
        }

        LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

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
            LibSwap.returnTradeDust(sourceToken, poolToken);
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

        if (sourceToken == poolToken) {
            require(totalCarbon == maxAmountIn, "Incorrect pool amount");
        }

        LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

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

            // Check for any trade dust and send back
            LibSwap.returnTradeDust(sourceToken, poolToken);

            require(carbonReceived >= totalCarbon, "Swap not enough");
            totalCarbon = carbonReceived;
        }

        uint256 redeemedPool = LibRetire.retireReceivedExactCarbonSpecific(
            poolToken,
            projectToken,
            retireAmount,
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

    /* ========== Batch Retirements ========== */

    /**
     * @notice                     Retires an exact amount of carbon using default redemption
     * @param retirements          Array of RetirementDetails struct containing the individual retirement details being batched
     * @param sourceToken          Source ERC-20 token to use for the retirement
     * @param poolToken            Pool token to use for this retirement
     * @param maxAmountIn          Maximum amount of source tokens to spend in this retirement
     * @param fromMode             From Mode for transfering tokens
     */
    function retireExactCarbonDefaultBatch(
        RetirementDetails[] calldata retirements,
        address sourceToken,
        address poolToken,
        uint256 maxAmountIn,
        LibTransfer.From fromMode
    ) external payable nonReentrant {
        require(retirements.length > 0, "Cannot retire empty batch");

        uint256 totalSourceAmount;
        uint256 totalRetirementAmount;

        for (uint256 i = 0; i < retirements.length; ++i) {
            totalRetirementAmount += retirements[i].retireAmount;
        }

        uint256 totalCarbon = LibRetire.getTotalCarbon(totalRetirementAmount);

        if (sourceToken == poolToken) {
            require(totalCarbon == maxAmountIn, "Incorrect pool amount");
        }

        LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

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
            LibSwap.returnTradeDust(sourceToken, poolToken);
        }

        for (uint256 i = 0; i < retirements.length; ++i) {
            retireBatchItem(retirements[i], false);
        }

        // Send any aggregator fees to treasury
        if (totalCarbon - totalRetirementAmount > 0) {
            LibTransfer.sendToken(
                IERC20(poolToken), totalCarbon - totalRetirementAmount, C.treasury(), LibTransfer.To.EXTERNAL
            );
        }
    }

    /**
     * @notice                     Retires an exact amount of carbon using default redemption
     * @param retirements          Array of RetirementDetails struct containing the individual retirement details being batched
     * @param sourceToken          Source ERC-20 token to use for the retirement
     * @param poolToken            Pool token to use for this retirement
     * @param maxAmountIn          Maximum amount of source tokens to spend in this retirement
     * @param fromMode             From Mode for transfering tokens
     */
    function retireExactCarbonSpecificBatch(
        RetirementDetails[] calldata retirements,
        address sourceToken,
        address poolToken,
        uint256 maxAmountIn,
        LibTransfer.From fromMode
    ) external payable nonReentrant {
        require(retirements.length > 0, "Cannot retire empty batch");

        uint256 totalSourceAmount;
        uint256 totalRetirementAmount;

        for (uint256 i = 0; i < retirements.length; ++i) {
            totalRetirementAmount += retirements[i].retireAmount;
        }

        uint256 totalCarbon = LibRetire.getTotalCarbonSpecific(poolToken, totalRetirementAmount);

        if (sourceToken == poolToken) {
            require(totalCarbon == maxAmountIn, "Incorrect pool amount");
        }

        LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

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
            LibSwap.returnTradeDust(sourceToken, poolToken);
        }

        uint256 redeemedAmount;

        for (uint256 i = 0; i < retirements.length; ++i) {
            redeemedAmount += retireBatchItem(retirements[i], true);
        }

        // Send any aggregator fees to treasury
        if (totalCarbon - totalRetirementAmount > 0) {
            LibTransfer.sendToken(
                IERC20(poolToken), totalCarbon - redeemedAmount, C.treasury(), LibTransfer.To.EXTERNAL
            );
        }
    }

    /**
     * @notice                     Retires an exact amount of carbon using values from the provided struct.
     * @param retirement           RetirementDetails struct containing the individual retirement details
     * @param specific             Flag for if this is a specific or default redemption
     */
    function retireBatchItem(RetirementDetails memory retirement, bool specific)
        private
        returns (uint256 redeemedAmount)
    {
        require(retirement.retireAmount > 0, "Cannot retire zero tonnes");
        if (!specific) {
            LibRetire.retireReceivedCarbon(
                retirement.poolToken,
                retirement.retireAmount,
                msg.sender,
                retirement.retiringEntityString,
                retirement.beneficiaryAddress,
                retirement.beneficiaryString,
                retirement.retirementMessage
            );
        } else {
            return LibRetire.retireReceivedExactCarbonSpecific(
                retirement.poolToken,
                retirement.projectToken,
                retirement.retireAmount,
                msg.sender,
                retirement.retiringEntityString,
                retirement.beneficiaryAddress,
                retirement.beneficiaryString,
                retirement.retirementMessage
            );
        }
    }
}
