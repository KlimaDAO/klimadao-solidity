// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../C.sol";
import "oz/token/ERC721/IERC721.sol";
import "../../interfaces/IToucan.sol";
import "../LibAppStorage.sol";
import "../LibRetire.sol";
import "../Token/LibTransfer.sol";
import "../LibMeta.sol";

/**
 * @author Cujo
 * @title LibToucanCarbon
 * Handles interactions with Toucan Protocol carbon
 */

library LibToucanCarbon {
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
     * @notice                      Redeems Toucan pool tokens using default redemtion and retires the TCO2
     * @param poolToken             Pool token to use for this retirement
     * @param amount                Amount of the project token to retire
     * @param retiringAddress       Address initiating this retirement
     * @param retiringEntityString  String description of the retiring entity
     * @param beneficiaryAddress    0x address for the beneficiary
     * @param beneficiaryString     String description of the beneficiary
     * @param retirementMessage     String message for this specific retirement
     */
    function redeemAutoAndRetire(
        address poolToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        // Redeem pool tokens
        (address[] memory listTCO2, uint[] memory amounts) = IToucanPool(poolToken).redeemAuto2(amount);

        // Retire TCO2
        for (uint i = 0; i < listTCO2.length; i++) {
            if (amounts[i] == 0) continue;

            retireTCO2(
                poolToken,
                listTCO2[i],
                amounts[i],
                retiringAddress,
                retiringEntityString,
                beneficiaryAddress,
                beneficiaryString,
                retirementMessage
            );
        }
    }

    /**
     * @notice                      Redeems Toucan pool tokens using specific redemtion and retires the TCO2
     * @param poolToken             Pool token to use for this retirement
     * @param projectToken          Project token to use for this retirement
     * @param amount                Amount of the project token to retire
     * @param retiringAddress       Address initiating this retirement
     * @param retiringEntityString  String description of the retiring entity
     * @param beneficiaryAddress    0x address for the beneficiary
     * @param beneficiaryString     String description of the beneficiary
     * @param retirementMessage     String message for this specific retirement
     * @return retiredAmount        The amount of TCO2 retired
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
    ) internal returns (uint retiredAmount) {
        // Redeem pool tokens
        // Put redemption address into arrays for calling the redeem.
        address[] memory projectTokens = new address[](1);
        projectTokens[0] = projectToken;

        uint[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        // Fetch balances, redeem, and update for net amount of TCO2 received from redemption.
        uint beforeBalance = IERC20(projectToken).balanceOf(address(this));
        IToucanPool(poolToken).redeemMany(projectTokens, amounts);
        amount = IERC20(projectToken).balanceOf(address(this)) - beforeBalance;

        // Retire TCO2
        retireTCO2(
            poolToken,
            projectToken,
            amount,
            retiringAddress,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage
        );
        return amount;
    }

    /**
     * @notice                      Redeems Toucan TCO2s
     * @param poolToken             Pool token to use for this retirement
     * @param projectToken          Project token to use for this retirement
     * @param amount                Amount of the project token to retire
     * @param retiringAddress       Address initiating this retirement
     * @param retiringEntityString  String description of the retiring entity
     * @param beneficiaryAddress    0x address for the beneficiary
     * @param beneficiaryString     String description of the beneficiary
     * @param retirementMessage     String message for this specific retirement
     */
    function retireTCO2(
        address poolToken,
        address projectToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        IToucanCarbonOffsets(projectToken).retireAndMintCertificate(
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage,
            amount
        );

        LibRetire.saveRetirementDetails(
            poolToken,
            projectToken,
            amount,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage
        );

        emit CarbonRetired(
            LibRetire.CarbonBridge.TOUCAN,
            retiringAddress,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage,
            poolToken,
            projectToken,
            amount
        );

        sendRetireCert(beneficiaryAddress);
    }

    /**
     * @notice                      Send the ERC-721 retirement certificate received to a beneficiary
     * @param _beneficiary          Beneficiary to send the certificate to
     */
    function sendRetireCert(address _beneficiary) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        // Transfer the latest ERC721 retirement token to the beneficiary
        IERC721(C.toucanCert()).safeTransferFrom(address(this), _beneficiary, s.lastERC721Received);
    }

    /**
     * @notice                      Calculates the additional pool tokens needed to specifically redeem x TCO2s
     * @param poolToken             Pool token to redeem
     * @param amount                Amount of TCO2 needed
     * @return poolFeeAmount        Number of additional pool tokens needed
     */
    function getSpecificRedeemFee(address poolToken, uint amount) internal view returns (uint poolFeeAmount) {
        bool feeExempt;

        try IToucanPool(poolToken).redeemFeeExemptedAddresses(address(this)) returns (bool result) {
            feeExempt = result;
        } catch {
            feeExempt = false;
        }

        if (feeExempt) {
            poolFeeAmount = 0;
        } else {
            uint feeRedeemBp = IToucanPool(poolToken).feeRedeemPercentageInBase();
            uint feeRedeemDivider = IToucanPool(poolToken).feeRedeemDivider();
            poolFeeAmount = ((amount * feeRedeemDivider) / (feeRedeemDivider - feeRedeemBp)) - amount;
        }
    }

    /**
     * @notice                      Returns the number of TCO2s retired when selectively redeeming x pool tokens
     * @param poolToken             Pool token to redeem
     * @param amount                Amount of pool tokens redeemed
     * @return retireAmount        Number TCO2s that can be retired.
     */
    function getSpecificRetireAmount(address poolToken, uint amount) internal view returns (uint retireAmount) {
        bool feeExempt;

        try IToucanPool(poolToken).redeemFeeExemptedAddresses(address(this)) returns (bool result) {
            feeExempt = result;
        } catch {
            feeExempt = false;
        }

        if (feeExempt) {
            retireAmount = amount;
        } else {
            uint feeRedeemBp = IToucanPool(poolToken).feeRedeemPercentageInBase();
            uint feeRedeemDivider = IToucanPool(poolToken).feeRedeemDivider();
            retireAmount = (amount * (feeRedeemDivider - feeRedeemBp)) / feeRedeemDivider;
        }
    }

    /**
     * @notice                      Simple wrapper to use redeem Toucan pools using the default list
     * @param poolToken             Pool token to redeem
     * @param amount                Amount of tokens being redeemed
     * @param toMode                Where to send TCO2 tokens
     * @return projectTokens        TCO2 token addresses redeemed
     * @return amounts              TCO2 token amounts redeemed
     */
    function redeemPoolAuto(
        address poolToken,
        uint amount,
        LibTransfer.To toMode
    ) internal returns (address[] memory projectTokens, uint[] memory amounts) {
        (projectTokens, amounts) = IToucanPool(poolToken).redeemAuto2(amount);
        for (uint i; i < projectTokens.length; i++) {
            LibTransfer.sendToken(IERC20(projectTokens[i]), amounts[i], msg.sender, toMode);
        }
    }

    /**
     * @notice                      Simple wrapper to use redeem Toucan pools using the specific list
     * @param poolToken             Pool token to redeem
     * @param projectTokens         Project tokens to redeem
     * @param amounts               Token amounts to redeem
     * @param toMode                Where to send TCO2 tokens
     * @return redeemedAmounts      TCO2 token amounts redeemed
     */
    function redeemPoolSpecific(
        address poolToken,
        address[] memory projectTokens,
        uint[] memory amounts,
        LibTransfer.To toMode
    ) internal returns (uint[] memory) {
        uint[] memory beforeBalances = new uint256[](projectTokens.length);
        uint[] memory redeemedAmounts = new uint256[](projectTokens.length);

        IToucanPool(poolToken).redeemMany(projectTokens, amounts);

        for (uint i; i < projectTokens.length; i++) {
            redeemedAmounts[i] = IERC20(projectTokens[i]).balanceOf(address(this)) - beforeBalances[i];
            LibTransfer.sendToken(IERC20(projectTokens[i]), redeemedAmounts[i], msg.sender, toMode);
        }
        return redeemedAmounts;
    }
}
