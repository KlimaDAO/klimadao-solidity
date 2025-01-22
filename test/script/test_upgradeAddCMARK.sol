// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeInfinityForCMARK } from "../../script/4_upgradeInfinityForCMARK.s.sol";
import { IDiamond } from "../../src/interfaces/IDiamond.sol";
import { Test } from "forge-std/Test.sol";
import { C } from "../../src/C.sol";
import { IERC20 } from "@openzeppelin/token/ERC20/IERC20.sol";
import { ICMARKCreditTokenFactory } from "../../src/infinity/interfaces.ICMARKCredit.sol";

contract DeployMarketplaceFacetTest is Test {
    address constant DIAMOND_OWNER = 0x843dE2e99449834cd6C6456Bd35894d0B157B947; // mainnet multisig
    address constant DIAMOND_ADDRESS = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8; // mainnet RA diamond
    address constant MARKETPLACE_ADDRESS = 0x7B51dBc2A8fD98Fe0924416E628D5755f57eB821; // mainnet marketplace diamond

    address constant CMARK_FACTORY_OWNER = 0xc51Cc27d3BB611DB27f26F617E1c15483A8790Cf;
    address constant CMARK_FACTORY_ADDRESS = 0xEeE3abDD638E219261e061c06C0798Fd5C05B5D3;
    address constant CMARK_HOLDER = 0xAb5B7b5849784279280188b556AF3c179F31Dc5B; // atmos dev wallet that has CMARK in it, may need to be done on fork
    string constant CMARK_TOKEN_ID = 'CMARK-1-2025';

    uint256 constant PREUPGRADE_BLOCK = 67015013;

    bytes data;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    function setUp() public {
        string memory RPC_URL = vm.envString("POLYGON_URL");
        uint256 forkId = vm.createFork(RPC_URL);
        vm.selectFork(forkId);
        // Deploy the new facet on the fork and set the calldata
        DeployFacet deployScript = new UpgradeInfinityForCMARK();
        data = deployScript.run();
    }

    function doUpgrade() public {
        // Prank the owner of the Diamond
        vm.startPrank(DIAMOND_OWNER);
        (bool success,) = DIAMOND_ADDRESS.call(data);
        require(success, "Diamond upgrade failed");
        vm.stopPrank();
    }

    function transferCMARK(uint256 amount, address to) public {
        vm.prank(CMARK_HOLDER);
        // TODO: need to do a local fork issuance first
        // Use this to impersonate owner of CMARK factory:
        // cast rpc anvil_impersonateAccount ${CMARK_TOKEN_HOLDER} --rpc-url ${RPC_URL}
        // Then issue tokens on the local fork from a separate script (Makefile)
        ICMARKCreditTokenFactory(CMARK_FACTORY_ADDRESS).issueCredits(CMARK_TOKEN_ID, amount, CMARK_HOLDER);
    }

    /*
     * @notice Integration test to confirm that existing listings are still functional after upgrading
     * Takes the current codebase and upgrades the diamond on a fork of mainnet Polygon
     * Test should continue to pass even after the real upgrade is deployed on mainnet.
     */
    function test_createListing_beforeAndAfterUpgrade() public {
        // create a listing before upgrade
        uint256 amount = 1 ether;
        address RETIRER = vm.addr(1);
        transferCMARK(amount, RETIRER);
        vm.startPrank(RETIRER);
        IERC20(CMARK_ADDRESS).approve(DIAMOND_ADDRESS, amount);
        bytes32 cmarkListingId =
            marketplace.createListing(CMARK_ADDRESS, amount, 1_000_000_000, 1 ether, block.timestamp + 600);

        // TODO: expect the call to revert since we have warped to a block before the upgrade
        vm.warp(PREUPGRADE_BLOCK);
        expectRevert();
        bytes32 cmarkRetireId =
        // TODO: fill in all retirement parameters for this test
            diamond.retireCarbonmarkListing(CMARK_ADDRESS, amount, );
        // TODO: rewrite this assert to check the retirement (fails if not upgraded, succeeds if so)
        // MAKE SURE IT STILL PASSES AFTER UPGRADE!

        // do expect revert here
        // set an arbitrary block (e.g. current block) to warp to before the upgrade to make sure this test still passes
        assertEq(marketplace.getRemainingAmount(cmarkListingId), amount);
        vm.stopPrank();

        // upgrade the diamond
        doUpgrade();

        // confirm retirement functions after upgrade as well (without revert)
        diamond.retire(CMARK_ADDRESS, amount, );
        assertEq(marketplace.getRemainingAmount(c3tListingId), amount);

    }
}
