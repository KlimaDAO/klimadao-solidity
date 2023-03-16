// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../LibRetire.sol";
import "../Token/LibTransfer.sol";
import "../../interfaces/IC3.sol";

import "lib/forge-std/src/console.sol";

/**
 * @author Cujo
 * @title LibC3Carbon
 */

library LibC3Carbon {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint retiredAmount
    );

    /**
     * @notice                     Calls freeRedeem on a C3 pool and retires the underlying C3T
     * @param poolToken            Pool token to use for this retirement
     * @param amount               Amount of tokens to redeem and retire
     * @param retiringAddress      Address initiating this retirement
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     */
    function freeRedeemAndRetire(
        address poolToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        address[] memory projectTokens = IC3Pool(poolToken).getFreeRedeemAddresses();

        // Redeem pool tokens
        IC3Pool(poolToken).freeRedeem(amount);

        // Retire C3T
        for (uint i = 0; i < projectTokens.length && amount > 0; i++) {
            uint balance = IERC20(projectTokens[i]).balanceOf(address(this));
            // Skip over any C3Ts returned that were not actually redeemed.
            if (balance == 0) continue;

            retireC3T(
                poolToken,
                projectTokens[i],
                balance,
                retiringAddress,
                retiringEntityString,
                beneficiaryAddress,
                beneficiaryString,
                retirementMessage
            );

            amount -= balance;
        }

        require(amount == 0, "Didn't retire all tons");
    }

    /**
     * @notice                     Calls taxedRedeem on a C3 pool and retires the underlying C3T
     * @param poolToken            Pool token to use for this retirement
     * @param projectToken         Project token being redeemed
     * @param amount               Amount of tokens to redeem and retire
     * @param retiringAddress      Address initiating this retirement
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     */
    function redeemSpecificAndRetire(
        address poolToken,
        address projectToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        // Redeem pool tokens
        // C3 fee is additive, not subtractive

        // Put redemption address into arrays for calling the redeem.

        address[] memory projectTokens = new address[](1);
        projectTokens[0] = projectToken;

        uint[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        IC3Pool(poolToken).taxedRedeem(projectTokens, amounts);

        // Retire C3T
        retireC3T(
            poolToken,
            projectToken,
            amount,
            retiringAddress,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage
        );
    }

    /**
     * @notice                     Retire a C3T token
     * @param poolToken            Pool token to use for this retirement
     * @param projectToken         Project token being redeemed
     * @param amount               Amount of tokens to redeem and retire
     * @param retiringAddress      Address initiating this retirement
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     */
    function retireC3T(
        address poolToken,
        address projectToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        IC3ProjectToken(projectToken).offsetFor(amount, beneficiaryAddress, beneficiaryString, retirementMessage);

        LibRetire.saveRetirementDetails(
            poolToken, projectToken, amount, beneficiaryAddress, beneficiaryString, retirementMessage
        );

        emit CarbonRetired(
            LibRetire.CarbonBridge.C3,
            retiringAddress,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage,
            poolToken,
            projectToken,
            amount
        );
    }

    /**
     * @notice                     Return the additional fee needed to redeem specific number of project tokens.
     * @param poolToken            Pool token to use for this retirement
     * @param amount               Amount of tokens to redeem and retire
     * @return poolFeeAmount       Additional C3 pool tokens needed for the redemption
     */
    function getExactCarbonSpecificRedeemFee(address poolToken, uint amount)
        internal
        view
        returns (uint poolFeeAmount)
    {
        uint feeRedeem = IC3Pool(poolToken).feeRedeem();
        uint feeDivider = 10_000; // This is hardcoded in current C3 contract.

        poolFeeAmount = (amount * feeRedeem) / feeDivider;
    }

    /**
     * @notice                     Return the amount that can be specifically redeemed from a C3 given x number of tokens.
     * @param poolToken            Pool token to use for this retirement
     * @param amount               Amount of tokens to redeem and retire
     * @return retireAmount        Amount of C3T that can be specifically redeemed from a given pool amount
     */
    function getExactSourceSpecificRetireAmount(address poolToken, uint amount)
        internal
        view
        returns (uint retireAmount)
    {
        // Backing into a redemption amount from a total pool token amount
        uint feeRedeem = IC3Pool(poolToken).feeRedeem();
        uint feeDivider = 10_000; // This is hardcoded in current C3 contract.

        retireAmount = amount - ((amount * feeDivider) / (feeDivider + feeRedeem));
    }

    /**
     * @notice                     Receives and redeems a number of pool tokens and sends the C3T to a destination..
     * @param poolToken            Pool token to use for this retirement
     * @param amount               Amount of tokens to redeem and retire
     * @param toMode               Where to send redeemed tokens to
     * @return allProjectTokens    Default redeem C3T list from the pool
     * @return amounts             Amount of C3T that was redeemed from the pool
     */
    function redeemPoolAuto(address poolToken, uint amount, LibTransfer.To toMode)
        internal
        returns (address[] memory allProjectTokens, uint[] memory amounts)
    {
        allProjectTokens = IC3Pool(poolToken).getFreeRedeemAddresses();
        amounts = new uint256[](allProjectTokens.length);

        // Redeem pool tokens
        IC3Pool(poolToken).freeRedeem(amount);

        for (uint i = 0; i < allProjectTokens.length && amount > 0; i++) {
            uint balance = IERC20(allProjectTokens[i]).balanceOf(address(this));
            // Skip over any C3Ts returned that were not actually redeemed.
            if (balance == 0) continue;

            amounts[i] = balance;

            LibTransfer.sendToken(IERC20(allProjectTokens[i]), balance, msg.sender, toMode);
            amount -= balance;
        }
    }

    /**
     * @notice                      Receives and redeems a number of pool tokens and sends the C3T to a destination.
     * @param poolToken             Pool token to use for this retirement
     * @param projectTokens         Project tokens to redeem
     * @param amounts               Amounts of the project tokens to redeem
     * @param toMode                Where to send redeemed tokens to
     * @return redeemedAmounts      Amounts of the project tokens redeemed
     */
    function redeemPoolSpecific(
        address poolToken,
        address[] memory projectTokens,
        uint[] memory amounts,
        LibTransfer.To toMode
    ) internal returns (uint[] memory) {
        uint[] memory beforeBalances = new uint256[](projectTokens.length);
        uint[] memory redeemedAmounts = new uint256[](projectTokens.length);
        for (uint i; i < projectTokens.length; i++) {
            beforeBalances[i] = IERC20(projectTokens[i]).balanceOf(address(this));
        }

        IC3Pool(poolToken).taxedRedeem(projectTokens, amounts);

        for (uint i; i < projectTokens.length; i++) {
            redeemedAmounts[i] = IERC20(projectTokens[i]).balanceOf(address(this)) - beforeBalances[i];
            LibTransfer.sendToken(IERC20(projectTokens[i]), redeemedAmounts[i], msg.sender, toMode);
        }
        return redeemedAmounts;
    }
}
