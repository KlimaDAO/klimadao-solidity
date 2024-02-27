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
        uint256 retiredAmount
    );

    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint256 tokenId,
        uint256 retiredAmount
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
        uint256 amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        // Redeem pool tokens
        (address[] memory listTCO2, uint256[] memory amounts) = IToucanPool(poolToken).redeemAuto2(amount);

        // Retire TCO2
        for (uint256 i = 0; i < listTCO2.length; i++) {
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
        uint256 amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal returns (uint256 retiredAmount) {
        // Redeem pool tokens
        // Put redemption address into arrays for calling the redeem.
        address[] memory projectTokens = new address[](1);
        projectTokens[0] = projectToken;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        // Fetch balances, redeem, and update for net amount of TCO2 received from redemption.
        uint256 beforeBalance = IERC20(projectToken).balanceOf(address(this));
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
        uint256 amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        IToucanCarbonOffsets(projectToken).retireAndMintCertificate(
            retiringEntityString, beneficiaryAddress, beneficiaryString, retirementMessage, amount
        );

        LibRetire.saveRetirementDetails(
            poolToken, projectToken, amount, beneficiaryAddress, beneficiaryString, retirementMessage
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
     * @notice                      Creates a Retirement Request for Toucan Puro TCO2s
     * @param tokenId               Credit token ID to be retired
     * @param projectToken          Project token to use for this retirement
     * @param amount                Amount of the project token to retire
     * @param retiringAddress       Address initiating this retirement
     * @param retiringEntityString  String description of the retiring entity
     * @param beneficiaryAddress    0x address for the beneficiary
     * @param beneficiaryString     String description of the beneficiary
     * @param retirementMessage     String message for this specific retirement
     */
    function retirePuroTCO2(
        uint256 tokenId,
        address projectToken,
        uint256 amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        uint256 _tokenId = tokenId;
        address _projectToken = projectToken;
        uint256 _amount = amount;

        _retirePuro(
            _tokenId,
            _projectToken,
            _amount,
            retiringEntityString,
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
            address(0),
            _projectToken,
            _tokenId,
            _amount
        );
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
    function getSpecificRedeemFee(address poolToken, uint256 amount) internal view returns (uint256 poolFeeAmount) {
        bool feeExempt;

        try IToucanPool(poolToken).redeemFeeExemptedAddresses(address(this)) returns (bool result) {
            feeExempt = result;
        } catch {
            feeExempt = false;
        }

        if (feeExempt) {
            poolFeeAmount = 0;
        } else {
            uint256 feeRedeemBp = IToucanPool(poolToken).feeRedeemPercentageInBase();
            uint256 feeRedeemDivider = IToucanPool(poolToken).feeRedeemDivider();
            poolFeeAmount = ((amount * feeRedeemDivider) / (feeRedeemDivider - feeRedeemBp)) - amount;
        }
    }

    /**
     * @notice                      Returns the number of TCO2s retired when selectively redeeming x pool tokens
     * @param poolToken             Pool token to redeem
     * @param amount                Amount of pool tokens redeemed
     * @return retireAmount        Number TCO2s that can be retired.
     */
    function getSpecificRetireAmount(address poolToken, uint256 amount) internal view returns (uint256 retireAmount) {
        bool feeExempt;

        try IToucanPool(poolToken).redeemFeeExemptedAddresses(address(this)) returns (bool result) {
            feeExempt = result;
        } catch {
            feeExempt = false;
        }

        if (feeExempt) {
            retireAmount = amount;
        } else {
            uint256 feeRedeemBp = IToucanPool(poolToken).feeRedeemPercentageInBase();
            uint256 feeRedeemDivider = IToucanPool(poolToken).feeRedeemDivider();
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
    function redeemPoolAuto(address poolToken, uint256 amount, LibTransfer.To toMode)
        internal
        returns (address[] memory projectTokens, uint256[] memory amounts)
    {
        (projectTokens, amounts) = IToucanPool(poolToken).redeemAuto2(amount);
        for (uint256 i; i < projectTokens.length; i++) {
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
        uint256[] memory amounts,
        LibTransfer.To toMode
    ) internal returns (uint256[] memory) {
        uint256[] memory beforeBalances = new uint256[](projectTokens.length);
        uint256[] memory redeemedAmounts = new uint256[](projectTokens.length);

        IToucanPool(poolToken).redeemMany(projectTokens, amounts);

        for (uint256 i; i < projectTokens.length; i++) {
            redeemedAmounts[i] = IERC20(projectTokens[i]).balanceOf(address(this)) - beforeBalances[i];
            LibTransfer.sendToken(IERC20(projectTokens[i]), redeemedAmounts[i], msg.sender, toMode);
        }
        return redeemedAmounts;
    }

    function isValid(address token) internal returns (bool) {
        return IToucanContractRegistry(C.toucanRegistry()).isValidERC20(token);
    }

    function _retirePuro(
        uint256 tokenId,
        address projectToken,
        uint256 amount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) private {
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;

        IToucanPuroCarbonOffsets.CreateRetirementRequestParams memory params = IToucanPuroCarbonOffsets
            .CreateRetirementRequestParams({
            tokenIds: tokenIds,
            amount: amount,
            retiringEntityString: retiringEntityString,
            beneficiary: beneficiaryAddress,
            beneficiaryString: beneficiaryString,
            retirementMessage: retirementMessage,
            beneficiaryLocation: "",
            consumptionCountryCode: "",
            consumptionPeriodStart: 0,
            consumptionPeriodEnd: 0
        });

        IToucanPuroCarbonOffsets(projectToken).requestRetirement(params);

        LibRetire.saveRetirementDetails(
            address(0), projectToken, amount, beneficiaryAddress, beneficiaryString, retirementMessage
        );
    }
}
