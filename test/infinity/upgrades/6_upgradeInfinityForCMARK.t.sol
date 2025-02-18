// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeInfinityForCMARK } from "../../../script/6_upgradeInfinityForCMARK.s.sol";
import { TestHelper } from "../../infinity/TestHelper.sol";
import { C } from "../../../src/infinity/C.sol";
import { AssertionHelper } from "../../helpers/AssertionHelper.sol";
import { ListingsHelper } from "../../helpers/Listings.sol";
import { Test } from "forge-std/Test.sol";
import { IERC20 } from "../../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { ICarbonmark } from "../../../src/infinity/interfaces/ICarbonmark.sol";
import { ICMARKCreditTokenFactory } from "../../../src/infinity/interfaces/ICMARKCredit.sol";
import { LibRetire } from "../../../src/infinity/libraries/LibRetire.sol";
import { LibTransfer } from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import { RetireCMARKFacet } from "../../../src/infinity/facets/Bridges/CMARK/RetireCMARKFacet.sol";
import { RetireCarbonmarkFacet } from "../../../src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";

contract UpgradeInfinityForCMARKCredits is TestHelper, AssertionHelper, ListingsHelper {
    UpgradeInfinityForCMARK upgradeScript;
    address USDC_ADDRESS;

    uint256 constant AMOUNT = 4 ether;
    uint256 constant SOURCE_AMOUNT = 2 ether;
    uint256 constant unitPrice = 1 ether;
    uint256 constant minFillAmount = 1e18;
    address RETIRER = vm.addr(1);

    address constant DIAMOND_OWNER = 0x843dE2e99449834cd6C6456Bd35894d0B157B947; // mainnet multisig
    address constant DIAMOND_ADDRESS = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8; // mainnet RA diamond
    address MARKETPLACE_ADDRESS; // mainnet marketplace diamond

    address constant CMARK_FACTORY_OWNER = 0xc51Cc27d3BB611DB27f26F617E1c15483A8790Cf;
    address constant CMARK_FACTORY_ADDRESS = 0xEeE3abDD638E219261e061c06C0798Fd5C05B5D3;
    string constant CMARK_TOKEN_ID = 'CMARK-1-2025';

    uint256 constant PREUPGRADE_BLOCK = 67015013;

    ICMARKCreditTokenFactory cmarkFactory;

    address CMARK_ADDRESS;
    address carbonmark;

    bytes data;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    LibRetire.RetireDetails details = LibRetire.RetireDetails({
        retiringAddress: address(this),
        retiringEntityString: entity,
        beneficiaryAddress: RETIRER,
        beneficiaryString: beneficiary,
        retirementMessage: message,
        beneficiaryLocation: "Germany",
        consumptionCountryCode: "DE",
        consumptionPeriodStart: block.timestamp,
        consumptionPeriodEnd: block.timestamp + 1 days
    });

    function setUp() public {
        string memory RPC_URL = vm.envString("POLYGON_URL");
        uint256 forkId = vm.createFork(RPC_URL);
        vm.selectFork(forkId);

        USDC_ADDRESS = C.usdc();
        carbonmark = C.carbonmark();
        MARKETPLACE_ADDRESS = C.carbonmark();

        // give the RETIRER some USDC to pay for the listing
        deal(USDC_ADDRESS, RETIRER, 10 ether);
    }

    function doUpgrade() public {
        // Set the calldata
        upgradeScript = new UpgradeInfinityForCMARK();
        data = upgradeScript.run();

        // Prank the owner of the Diamond
        vm.startPrank(DIAMOND_OWNER);
        (bool success,) = DIAMOND_ADDRESS.call(data);
        require(success, "Diamond upgrade failed");
        vm.stopPrank();
    }

    function transferCMARK(uint256 amount, address to) public {
        vm.prank(CMARK_FACTORY_OWNER);
        cmarkFactory = ICMARKCreditTokenFactory(CMARK_FACTORY_ADDRESS);
        cmarkFactory.issueCredits(CMARK_TOKEN_ID, amount, RETIRER);
        CMARK_ADDRESS = cmarkFactory.creditIdToAddress(CMARK_TOKEN_ID);
        assertNotEq(CMARK_ADDRESS, address(0));
        assertEq(IERC20(CMARK_ADDRESS).balanceOf(RETIRER), amount);
        vm.stopPrank();
    }

    /*
     * @notice Integration test to confirm that existing listings are still functional after upgrading
     * Takes the current codebase and upgrades the diamond on a fork of mainnet Polygon
     * Test should continue to pass even after the real upgrade is deployed on mainnet.
     */
    function test_cmark_retire_beforeAndAfterUpgrade() public {
        // create a listing before upgrade
        transferCMARK(AMOUNT, RETIRER);
        vm.startPrank(RETIRER);
        IERC20(CMARK_ADDRESS).approve(MARKETPLACE_ADDRESS, AMOUNT);
        IERC20(CMARK_ADDRESS).approve(DIAMOND_ADDRESS, AMOUNT);
        IERC20(USDC_ADDRESS).approve(DIAMOND_ADDRESS, AMOUNT);

        vm.warp(PREUPGRADE_BLOCK);

        ICarbonmark marketplace = ICarbonmark(MARKETPLACE_ADDRESS);
        RetireCarbonmarkFacet diamond = RetireCarbonmarkFacet(DIAMOND_ADDRESS);

        bytes32 cmarkListingId =
            marketplace.createListing(CMARK_ADDRESS, AMOUNT, unitPrice, minFillAmount, block.timestamp + 600);
        ICarbonmark.CreditListing memory listingStruct =
            ICarbonmark.CreditListing({
                id: cmarkListingId,
                account: ICarbonmark(carbonmark).getListingOwner(cmarkListingId),
                token: CMARK_ADDRESS,
                tokenId: 0,
                remainingAmount: ICarbonmark(carbonmark).getRemainingAmount(cmarkListingId),
                unitPrice: unitPrice
            });

        // LibRetire doesn't revert on unknown carbon,
        // so we will check that the filled order ends up in the Diamond contract itself
        uint256 cmarkRetireId = diamond.retireCarbonmarkListing(
            listingStruct, SOURCE_AMOUNT, AMOUNT/2, details, LibTransfer.From.EXTERNAL
        );

        assertEq(IERC20(CMARK_ADDRESS).balanceOf(RETIRER), AMOUNT/2);
        assertEq(IERC20(CMARK_ADDRESS).balanceOf(DIAMOND_ADDRESS), AMOUNT/2);
        vm.stopPrank();

        // upgrade the diamond
        doUpgrade();

        vm.startPrank(RETIRER);
        // confirm retirement functions after upgrade as well (without revert)
        uint256 cmarkRetireId2 = diamond.retireCarbonmarkListing(
            listingStruct, SOURCE_AMOUNT / 2, AMOUNT / 4, details, LibTransfer.From.EXTERNAL
        );

        assertEq(IERC20(CMARK_ADDRESS).balanceOf(RETIRER), AMOUNT/4);
        assertEq(IERC20(CMARK_ADDRESS).balanceOf(DIAMOND_ADDRESS), AMOUNT/2);
        assertEq(marketplace.getRemainingAmount(cmarkListingId), AMOUNT/4);

        RetireCMARKFacet rcmDiamond = RetireCMARKFacet(DIAMOND_ADDRESS);
        uint256 cmarkRetireId3 = rcmDiamond.cmarkRetireExactCarbon(
            CMARK_ADDRESS, AMOUNT/4, details, LibTransfer.From.EXTERNAL
        );
        assertEq(IERC20(CMARK_ADDRESS).balanceOf(RETIRER), 0);
        vm.stopPrank();

    }
}
