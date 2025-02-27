// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeInfinityForBatchRetire } from "../../../script/7_upgradeInfinityForBatchRetire.s.sol";
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
import { RetireCarbonmarkFacet } from "../../../src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";

contract UpgradeInfinityForBatchRetireTest is TestHelper, AssertionHelper, ListingsHelper {
    UpgradeInfinityForBatchRetire upgradeScript;
    address constant DIAMOND_OWNER = 0x843dE2e99449834cd6C6456Bd35894d0B157B947; // mainnet multisig
    address constant DIAMOND_ADDRESS = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8; // mainnet RA diamond
    bytes data;
    
    function setUp() public {
        string memory RPC_URL = vm.envString("POLYGON_URL");
        uint256 forkId = vm.createFork(RPC_URL);
        vm.selectFork(forkId);
    }

    function doUpgrade() public {
        // Set the calldata
        upgradeScript = new UpgradeInfinityForBatchRetire();
        data = upgradeScript.run();

        // Prank the owner of the Diamond
        vm.startPrank(DIAMOND_OWNER);
        (bool success,) = DIAMOND_ADDRESS.call(data);
        require(success, "Diamond upgrade failed");
        vm.stopPrank();
    }

    function test_upgrade() public {
        doUpgrade();
    }
}
