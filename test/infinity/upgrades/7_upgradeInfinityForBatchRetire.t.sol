// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UpgradeInfinityForBatchRetire } from "../../../script/7_upgradeInfinityForBatchRetire.s.sol";
import { TestHelper } from "../../infinity/TestHelper.sol";

import "../TestHelper.sol";

contract UpgradeInfinityForBatchRetireTest is TestHelper {
   
    function setUp() public {
        // Start fork
        string memory RPC_URL = vm.envString("POLYGON_URL");
        uint256 forkId = vm.createFork(RPC_URL);
        vm.selectFork(forkId);
    }

    function test_upgrade() public {
        address DIAMOND_OWNER = vm.envAddress("INFINITY_OWNER"); // multisig
        address DIAMOND_ADDRESS = vm.envAddress("INFINITY_ADDRESS");

        // Set the calldata
        UpgradeInfinityForBatchRetire upgradeScript = new UpgradeInfinityForBatchRetire();
        bytes memory data = upgradeScript.run();

        // Prank the owner of the Diamond
        vm.startPrank(DIAMOND_OWNER);
        (bool success,) = DIAMOND_ADDRESS.call(data);
        require(success, "Diamond upgrade failed");
        vm.stopPrank();
    }
}
