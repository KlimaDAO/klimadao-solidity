//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

interface ICarbonmark {
    /**
     * @notice Struct containing all of the detail information needed to fill a listing
     * @param account Ethereum address of the account who owns the listing
     * @param token Ethereum address of the token being listing
     * @param originalAmount Original amount of the listing
     * @param remainingAmount Remaining amount that can be filled on this listing
     * @param unitPrice The unit price in USDC of the listing
     * @param minFillAmount The minimum amount needed to purchase in order to fill the listing
     * @param deadline The block timestamp at which this listing expires
     */
    struct CreditListing {
        bytes32 id;
        address account;
        address token;
        uint256 remainingAmount;
        uint256 unitPrice;
    }

    /**
     * @notice This function creates a new listing and returns the resulting listing ID
     * @param token The token being listed
     * @param amount The amount to be listed
     * @param unitPrice The unit price in USDC to list. Should be provided in full form so a price of 2.5 USDC = input
     * of 2500000
     * @param minFillAmount The minimum number of tons needed to be purchased to fill this listing
     * @param deadline The block timestamp at which this listing will expire
     * @return id The ID of the listing that was created
     */
    function createListing(address token, uint256 amount, uint256 unitPrice, uint256 minFillAmount, uint256 deadline)
        external
        returns (bytes32 id);

    /**
     * @notice This function fills an existing listing
     * @param id The listing ID to update
     * @param listingAccount The account that created the listing you are filling
     * @param listingToken The token you are swapping for
     * @param listingUnitPrice The unit price per token to fill the listing
     * @param amount Amount of the listing to fill
     * @param maxCost Maximum cost in USDC for filling this listing
     */
    function fillListing(
        bytes32 id,
        address listingAccount,
        address listingToken,
        uint256 listingUnitPrice,
        uint256 amount,
        uint256 maxCost
    ) external;

    function getListingOwner(bytes32 id) external view returns (address);

    function getUnitPrice(bytes32 id) external view returns (uint256);

    function getRemainingAmount(bytes32 id) external view returns (uint256);

    function getListingDeadline(bytes32 id) external view returns (uint256);
}
