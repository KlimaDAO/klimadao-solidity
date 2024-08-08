// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "oz/token/ERC721/IERC721.sol";
import "oz/token/ERC20/IERC20.sol";

import "../../C.sol";
import "../../interfaces/ICoorest.sol";

import "../LibAppStorage.sol";
import "../LibRetire.sol";
import "../Token/LibTransfer.sol";
import "../LibMeta.sol";

/**
 * @author must-be-carbon
 * @title  LibCoorestCarbon
 * @notice Handles interaction with the Coorest Pool and child tokens ( CCO2, POCC )
 */
library LibCoorestCarbon {
    struct FeeParams {
        uint256 feeRetireBp;
        uint256 feeRetireDivider;
    }

    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint256 retiredAmount
    );

    error FeePercentageGreaterThanDivider();
    error FeeRetireDividerIsZero();

    /**
     * @notice Retires CCO2
     * @dev Use this function to retire CCO2.
     * @dev This function assumes that checks to carbonToken are make higher up in call stack.
     * @dev It's important to know that Coorest transfers fee portion to it's account & rest amount is burned
     * @param carbonToken CCO2 token address.
     * @param retireAmount The amount of underlying tokens to retire.
     * @return poccId POCC Certificate Id.
     */
    function retireCarbonToken(
        address carbonToken,
        uint256 retireAmount,
        LibRetire.RetireDetails memory details
    ) internal returns (uint256 poccId) {
        require(details.beneficiaryAddress != address(0), "Beneficiary Address can't be 0");

        IERC20(carbonToken).approve(C.coorestPool(), retireAmount);

        // Transfer PoCC to beneficiary that's minted in favor RA
        // when Coorest retires CCO2
        poccId = ICoorest(C.coorestPool()).mintPOCC(
            retireAmount,
            details.retirementMessage,
            // Coorest expects owner as a string as it's to added to pocc token
            LibMeta.addressToString(details.beneficiaryAddress)
        );

        IERC721(C.coorestPoCCToken()).safeTransferFrom(address(this), details.beneficiaryAddress, poccId);

        LibRetire.saveRetirementDetails(
            carbonToken,
            address(0),
            retireAmount,
            details.beneficiaryAddress,
            details.beneficiaryString,
            details.retirementMessage
        );

        emit CarbonRetired(
            LibRetire.CarbonBridge.COOREST,
            details.retiringAddress,
            details.retiringEntityString,
            details.beneficiaryAddress,
            details.beneficiaryString,
            details.retirementMessage,
            carbonToken,
            address(0),
            retireAmount
        );
    }

    /**
     * @notice Calculates the Coorest fee that needs to be added to desired retire amount
     * @dev Use this function to compute the Coorest fee.
     * @dev This function assumes that checks to carbonToken are make higher up in call stack
     * @param carbonToken     CCO2 token address
     * @param amount          The amount of underlying tokens to retire.
     * @return feeAmount      Fee charged by Coorest.
     */
    function getSpecificRetirementFee(address carbonToken, uint256 amount) external view returns (uint256 feeAmount) {
        uint256 retireAmount = amount;
        require(retireAmount > 0, "Retire amount should be greater than 0");

        FeeParams memory feeParams = getFeePercent(carbonToken);

        feeAmount =
            ((retireAmount * feeParams.feeRetireDivider) / (feeParams.feeRetireDivider - feeParams.feeRetireBp)) -
            retireAmount;
    }

    /**
     * @dev This function fetches fee percent & divider from CCO2 token contract.
     * @param carbonToken CCO2 token address.
     * @return feeParams Fee percentage & the fee divider.
     */
    function getFeePercent(address carbonToken) private view returns (FeeParams memory feeParams) {
        uint256 feeRetireBp = ICCO2(carbonToken).burningPercentage();
        uint256 feeRetireDivider = ICCO2(carbonToken).decimalRatio();

        if (feeRetireBp < feeRetireDivider) {
            revert FeePercentageGreaterThanDivider();
        }

        if (feeRetireDivider == 0) {
            revert FeeRetireDividerIsZero();
        }

        return FeeParams({feeRetireBp: feeRetireBp, feeRetireDivider: feeRetireDivider});
    }
}
