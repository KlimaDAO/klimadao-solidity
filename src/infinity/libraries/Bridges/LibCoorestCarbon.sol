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
 * @notice Handles interaction with the Coorest Registry/Pool and child tokens ( CCO2, POCC )
 */
library LibCoorestCarbon {
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

    /**
     * @notice Retires CCO2
     * @dev Use this function to retire CCO2.
     * @param carbonToken The pool token to retire.
     * @param amount The amount of underlying tokens to retire.
     * @return The total retirement amount including the Coorest fee.
     */
    function retireCarbonToken(
        address carbonToken,
        uint256 _retireAmount,
        LibRetire.RetireDetails memory details
    ) external nonReentrant {
        // Once the CCO2 is burnt, the Coorest contract will mint a POCC Cert to msg.sender
        // It makes sense for the RA to transfer the PoCC to the beneficiary
        uint256 poccId = ICoorest(C.coorestPool()).mintPOCC(
            _retireAmount,
            details.retirementMessage,
            details.beneficiaryAddress
        );

        IERC721(C.coorestPoCCToken()).safeTransferFrom(address(this), details.beneficiaryAddress, poccId);

        emit CarbonRetired(
            LibRetire.CarbonBridge.COOREST,
            details.retiringAddress,
            details.retiringEntityString,
            details.beneficiaryAddress,
            details.beneficiaryString,
            details.retirementMessage,
            C.coorestPool(),
            carbonToken,
            _retireAmount
        );
    }

    // TODO  [ REVIEW ] : GET INSIGHT: There's no straight forward read function to get fee amount.. ( bad interface )
    /**
     * @notice Calculates the Coorest fee that needs to be added to desired retire amount
     * @dev Use this function to compute the Coorest fee
     * @param carbonToken The pool token to retire.
     * @param amount The amount of underlying tokens to retire.
     * @return The total retirement amount including the Coorest fee.
     */
    function getSpecificRetirementFee(
        address carbonToken,
        uint256 amount
    ) external view nonReentrant returns (uint256 feeAmount) {
        require(amount > 0, "Retire amount > 0");

        uint256 retireAmount = amount;
        uint256 feeRetireBp = ICCO2(carbonToken).burningPercentage();
        uint256 feeRetireDivider = ICCO2(carbonToken).decimalRatio();

        // TODO[Review] : Do we need this check ?? ( Most likely not )
        require(feeRetireBp <= feeRetireDivider, "Burn percentage should be greater than decimalRatio");

        feeAmount = ((retireAmount * feeRetireDivider) / (feeRetireDivider - feeRetireBp)) - retireAmount;
    }

    /**
     * @notice Calculates the retirement amount factoring in the fee.
     * @dev Use this function to compute the Coorest fee
     * @param carbonToken The pool token to retire.
     * @param amount The amount of underlying tokens to retire.
     * @return The total retirement amount including the Coorest fee.
     */
    function getSpecificRetireAmount(address carbonToken, uint256 amount) internal view returns (uint256 retireAmount) {
        retireAmount = amount;
        uint256 feeRedeemBp = ICCO2(carbonToken).burningPercentage();
        uint256 feeRedeemDivider = ICCO2(carbonToken).decimalRatio();

        // TODO[Review] : Do we need this check ?? ( Most likely not )
        require(feeRetireBp <= feeRetireDivider, "Burn percentage should be greater than decimalRatio");

        retireAmount = (amount * (feeRedeemDivider - feeRedeemBp)) / feeRedeemDivider;
    }
}
