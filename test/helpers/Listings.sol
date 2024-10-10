// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * \
 * Authors: Cujo <rawr@cujowolf.dev>
 * Helper functions for the common assertions used in testing
 * /*****************************************************************************
 */
import "forge-std/Test.sol";
import "oz/token/ERC20/IERC20.sol";
import {ICarbonmark} from "../../src/infinity/interfaces/ICarbonmark.sol";
import {LibRetire} from "../../src/infinity/libraries/LibRetire.sol";

abstract contract ListingsHelper is Test {
    address VCS_1190_2018 = address(0x64de5C0A430B2b15c6a3A7566c3930e1cF9b22DF);

    address seller = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    address buyer = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    function createCarbonmarkListing(
        address carbonmark,
        address infinity,
        uint256 amount,
        uint256 unitPrice,
        uint256 minFillAmount,
        uint256 deadline
    ) internal returns (bytes32 carbonmarkListingId) {
        vm.deal(seller, 1 ether);
        deal(VCS_1190_2018, seller, 100e18);

        vm.startPrank(seller);
        IERC20(VCS_1190_2018).approve(infinity, 100e18);
        IERC20(VCS_1190_2018).approve(carbonmark, 100e18);
        carbonmarkListingId =
            ICarbonmark(carbonmark).createListing(VCS_1190_2018, amount, unitPrice, minFillAmount, deadline);
        vm.stopPrank();
    }

    function getCarbonmarkListingStruct(address carbonmark, bytes32 listingId, uint256 amount, uint256 unitPrice)
        internal
        view
        returns (ICarbonmark.CreditListing memory)
    {
        return ICarbonmark.CreditListing({
            id: listingId,
            account: ICarbonmark(carbonmark).getListingOwner(listingId),
            token: VCS_1190_2018,
            tokenId: 0,
            remainingAmount: ICarbonmark(carbonmark).getRemainingAmount(listingId),
            unitPrice: unitPrice
        });
    }

    function getRetirementDetails(address buyerAddress) internal view returns (LibRetire.RetireDetails memory) {
        return LibRetire.RetireDetails({
            retiringAddress: buyerAddress,
            retiringEntityString: "Test Retiring Entity",
            beneficiaryAddress: buyerAddress,
            beneficiaryString: "Test Beneficiary",
            retirementMessage: "Test Retirement Message",
            beneficiaryLocation: "United States",
            consumptionCountryCode: "US",
            consumptionPeriodStart: block.timestamp,
            consumptionPeriodEnd: block.timestamp + 1 days
        });
    }
}
