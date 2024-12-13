// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../libraries/LibRetire.sol";
import "../../libraries/TokenSwap/LibSwap.sol";
import "../../ReentrancyGuard.sol";

contract RetireSourceFacet is ReentrancyGuard {
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
     * @notice                     Retires an exact amount of a source token using default redemption
     * @param sourceToken          Source ERC-20 token to use for the retirement
     * @param poolToken            Pool token to use for this retirement
     * @param maxAmountIn          Maximum amount of source tokens to spend in this retirement
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function retireExactSourceDefault(
        address sourceToken,
        address poolToken,
        uint256 maxAmountIn,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external payable nonReentrant returns (uint256 retirementIndex) {
        require(maxAmountIn > 0, "Cannot retire zero tonnes");

        LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

        /// @dev Initial value set assuming source == pool.
        uint256 totalCarbon = maxAmountIn;

        if (sourceToken != poolToken) {
            if (sourceToken == C.wsKlima()) {
                maxAmountIn = LibKlima.unwrapKlima(maxAmountIn);
            }
            if (sourceToken == C.sKlima()) LibKlima.unstakeKlima(maxAmountIn);

            totalCarbon = LibSwap.swapExactSourceToCarbonDefault(sourceToken, poolToken, maxAmountIn);
            require(totalCarbon > 0, "Swap returned nothing");
        }

        // Record the amount to retire based on the current fee.
        uint256 retireAmount = totalCarbon - LibRetire.getFee(totalCarbon);

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
     * @notice                     Retires an exact amount of a source token using specific redemption
     * @param sourceToken          Source ERC-20 token to use for the retirement
     * @param poolToken            Pool token to use for this retirement
     * @param projectToken         Project token to redeem and retire
     * @param maxAmountIn          Maximum amount of source tokens to spend in this retirement
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function retireExactSourceSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint256 maxAmountIn,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external payable nonReentrant returns (uint256 retirementIndex) {
        require(maxAmountIn > 0, "Cannot retire zero tonnes");

        LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

        /// @dev Initial value set assuming source == pool.
        uint256 totalCarbon = maxAmountIn;

        if (sourceToken != poolToken) {
            if (sourceToken == C.wsKlima()) {
                maxAmountIn = LibKlima.unwrapKlima(maxAmountIn);
            }
            if (sourceToken == C.sKlima()) LibKlima.unstakeKlima(maxAmountIn);

            totalCarbon = LibSwap.swapExactSourceToCarbonDefault(sourceToken, poolToken, maxAmountIn);
            require(totalCarbon > 0, "Swap returned nothing");
        }

        // Record the amount to retire based on the current fee.
        uint256 retireAmount = totalCarbon - LibRetire.getFee(totalCarbon);
        if (s.poolBridge[poolToken] == LibRetire.CarbonBridge.C3) {
            retireAmount = LibC3Carbon.getExactSourceSpecificRetireAmount(poolToken, retireAmount);
        }

        uint256 redeemedAmount = LibRetire.retireReceivedCarbonSpecificFromSource(
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
        if (totalCarbon - redeemedAmount > 0) {
            LibTransfer.sendToken(
                IERC20(poolToken), totalCarbon - redeemedAmount, C.treasury(), LibTransfer.To.EXTERNAL
            );
        }

        return LibRetire.getTotalRetirements(beneficiaryAddress);
    }
}
