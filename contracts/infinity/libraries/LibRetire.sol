// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @author Cujo
 * @title LibRetire
 */

import "../C.sol";
import "./LibAppStorage.sol";
import {LibMeta} from "./LibMeta.sol";
import "./Bridges/LibToucanCarbon.sol";
import "./Bridges/LibMossCarbon.sol";
import "./Bridges/LibC3Carbon.sol";
import "./Token/LibTransfer.sol";
import "./TokenSwap/LibSwap.sol";
import "../interfaces/IKlimaInfinity.sol";
import "../interfaces/IKlimaCarbonRetirements.sol";

library LibRetire {
    using LibTransfer for IERC20;
    using LibBalance for address payable;
    using LibApprove for IERC20;

    enum CarbonBridge {
        TOUCAN,
        MOSS,
        C3
    }

    /* ========== Default Redepmtion Retirements ========== */

    /**
     * @notice                     Retire received carbon based on the bridge of the provided pool tokens using default redemption
     * @param poolToken            Pool token used to retire
     * @param amount               The amount of carbon to retire
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     */
    function retireReceivedCarbon(
        address poolToken,
        uint256 amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        if (s.poolBridge[poolToken] == CarbonBridge.TOUCAN) {
            LibToucanCarbon.redeemAutoAndRetire(
                poolToken,
                amount,
                retiringAddress,
                retiringEntityString,
                beneficiaryAddress,
                beneficiaryString,
                retirementMessage
            );
        } else if (s.poolBridge[poolToken] == CarbonBridge.MOSS) {
            LibMossCarbon.offsetCarbon(
                poolToken,
                amount,
                retiringAddress,
                retiringEntityString,
                beneficiaryAddress,
                beneficiaryString,
                retirementMessage
            );
        } else if (s.poolBridge[poolToken] == CarbonBridge.C3) {
            LibC3Carbon.freeRedeemAndRetire(
                poolToken,
                amount,
                retiringAddress,
                retiringEntityString,
                beneficiaryAddress,
                beneficiaryString,
                retirementMessage
            );
        }
    }

    /* ========== Specific Redepmtion Retirements ========== */

    /**
     * @notice                     Retire received carbon based on the bridge of the provided pool tokens using specific redemption
     * @param poolToken            Pool token used to retire
     * @param projectToken         Project token being retired
     * @param amount               The amount of carbon to retire
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     */
    function retireReceivedExactCarbonSpecific(
        address poolToken,
        address projectToken,
        uint256 amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal returns (uint256 redeemedAmount) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            s.poolBridge[poolToken] == CarbonBridge.TOUCAN || s.poolBridge[poolToken] == CarbonBridge.C3,
            "Specific redeem not supported."
        );

        redeemedAmount = amount;

        if (s.poolBridge[poolToken] == CarbonBridge.TOUCAN) {
            redeemedAmount += LibToucanCarbon.getSpecificRedeemFee(poolToken, amount);
            LibToucanCarbon.redeemSpecificAndRetire(
                poolToken,
                projectToken,
                redeemedAmount,
                retiringAddress,
                retiringEntityString,
                beneficiaryAddress,
                beneficiaryString,
                retirementMessage
            );
        } else if (s.poolBridge[poolToken] == CarbonBridge.C3) {
            redeemedAmount += LibC3Carbon.getExactCarbonSpecificRedeemFee(poolToken, amount);

            LibC3Carbon.redeemSpecificAndRetire(
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
    }

    /**
     * @notice                     Additional function to handle the differences in wanting to fully retire x pool tokens specifically
     * @param poolToken            Pool token used to retire
     * @param projectToken         Project token being retired
     * @param amount               The amount of carbon to retire
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @return redeemedAmount      Number of pool tokens redeemed
     */
    function retireReceivedCarbonSpecificFromSource(
        address poolToken,
        address projectToken,
        uint256 amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal returns (uint256 redeemedAmount) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(
            s.poolBridge[poolToken] == CarbonBridge.TOUCAN || s.poolBridge[poolToken] == CarbonBridge.C3,
            "Specific redeem not supported."
        );

        redeemedAmount = amount;

        if (s.poolBridge[poolToken] == CarbonBridge.TOUCAN) {
            LibToucanCarbon.redeemSpecificAndRetire(
                poolToken,
                projectToken,
                amount,
                retiringAddress,
                retiringEntityString,
                beneficiaryAddress,
                beneficiaryString,
                retirementMessage
            );
        } else if (s.poolBridge[poolToken] == CarbonBridge.C3) {
            redeemedAmount += LibC3Carbon.getExactCarbonSpecificRedeemFee(poolToken, amount);
            LibC3Carbon.redeemSpecificAndRetire(
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
    }

    /* ========== Helper Functions ========== */

    /* ========== Common Functions ========== */

    /**
     * @notice                  Returns the total carbon needed fee included
     * @param retireAmount      Pool token used to retire
     * @return totalCarbon      Total pool token needed
     */
    function getTotalCarbon(uint256 retireAmount) internal view returns (uint256 totalCarbon) {
        return retireAmount + getFee(retireAmount);
    }

    /**
     * @notice                  Returns the total carbon needed fee included
     * @param poolToken         Pool token used to retire
     * @param retireAmount      Amount of carbon wanting to retire
     * @return totalCarbon      Total pool token needed
     */
    function getTotalCarbonSpecific(address poolToken, uint256 retireAmount)
        internal
        view
        returns (uint256 totalCarbon)
    {
        // This is for exact carbon retirements
        AppStorage storage s = LibAppStorage.diamondStorage();

        totalCarbon = getTotalCarbon(retireAmount);

        if (s.poolBridge[poolToken] == CarbonBridge.TOUCAN)
            totalCarbon += LibToucanCarbon.getSpecificRedeemFee(poolToken, retireAmount);
        else if (s.poolBridge[poolToken] == CarbonBridge.C3)
            totalCarbon += LibC3Carbon.getExactCarbonSpecificRedeemFee(poolToken, retireAmount);
    }

    /**
     * @notice                  Returns the total fee needed to retire x number of tokens
     * @param carbonAmount      Amount being retired
     * @return fee              Total fee charged
     */
    function getFee(uint256 carbonAmount) internal view returns (uint256 fee) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        fee = (carbonAmount * s.fee) / 100000;
    }

    /**
     * @notice                      Saves the details of the retirement over to KlimaCarbonRetirements and project details within AppStorage
     * @param poolToken             Pool token used to retire
     * @param projectToken          Pool token used to retire
     * @param amount                Amount of carbon wanting to retire
     * @param beneficiaryAddress    0x address for the beneficiary
     * @param beneficiaryString     String description of the beneficiary
     * @param retirementMessage     String message for this specific retirement
     */
    function saveRetirementDetails(
        address poolToken,
        address projectToken,
        uint256 amount,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        (uint256 currentRetirementIndex, , ) = IKlimaCarbonRetirements(C.klimaCarbonRetirements()).getRetirementTotals(
            beneficiaryAddress
        );

        // Save the base details of the retirement
        IKlimaCarbonRetirements(C.klimaCarbonRetirements()).carbonRetired(
            beneficiaryAddress,
            poolToken,
            amount,
            beneficiaryString,
            retirementMessage
        );

        // Save the details of the retirement
        s.a[beneficiaryAddress].retirements[currentRetirementIndex].projectTokenAddress = projectToken;
    }

    /* ========== Account Getters ========== */

    function getTotalRetirements(address account) internal view returns (uint256 totalRetirements) {
        (totalRetirements, , ) = IKlimaCarbonRetirements(C.klimaCarbonRetirements()).getRetirementTotals(account);
    }

    function getTotalCarbonRetired(address account) internal view returns (uint256 totalCarbonRetired) {
        (, totalCarbonRetired, ) = IKlimaCarbonRetirements(C.klimaCarbonRetirements()).getRetirementTotals(account);
    }

    function getTotalPoolRetired(address account, address poolToken) internal view returns (uint256 totalPoolRetired) {
        return IKlimaCarbonRetirements(C.klimaCarbonRetirements()).getRetirementPoolInfo(account, poolToken);
    }

    function getTotalProjectRetired(address account, address projectToken) internal view returns (uint256) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.a[account].totalProjectRetired[projectToken];
    }

    function getTotalRewardsClaimed(address account) internal view returns (uint256 totalClaimed) {
        (, , totalClaimed) = IKlimaCarbonRetirements(C.klimaCarbonRetirements()).getRetirementTotals(account);
    }

    function getRetirementDetails(address account, uint256 retirementIndex)
        internal
        view
        returns (
            address poolTokenAddress,
            address projectTokenAddress,
            address beneficiaryAddress,
            string memory beneficiary,
            string memory retirementMessage,
            uint256 amount
        )
    {
        (poolTokenAddress, amount, beneficiary, retirementMessage) = IKlimaCarbonRetirements(C.klimaCarbonRetirements())
            .getRetirementIndexInfo(account, retirementIndex);
        beneficiaryAddress = account;

        AppStorage storage s = LibAppStorage.diamondStorage();
        projectTokenAddress = s.a[account].retirements[retirementIndex].projectTokenAddress;
    }
}
