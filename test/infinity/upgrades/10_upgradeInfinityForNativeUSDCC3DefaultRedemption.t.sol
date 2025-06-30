// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UpgradeInfinityForNativeUSDCC3DefaultRedemption} from
    "../../../script/10_upgradeInfinityForNativeUSDCC3DefaultRedemption.s.sol";
import {TestHelper} from "../../infinity/TestHelper.sol";

import "../TestHelper.sol";

contract UpgradeInfinityForNativeUSDCC3DefaultRedemptionTest is TestHelper {
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
        UpgradeInfinityForNativeUSDCC3DefaultRedemption upgradeScript =
            new UpgradeInfinityForNativeUSDCC3DefaultRedemption();
        console2.log("Upgrade script address");
        console2.logAddress(address(upgradeScript));
        bytes memory data = upgradeScript.run();

        // Prank the owner of the Diamond
        vm.startPrank(DIAMOND_OWNER);
        (bool success,) = DIAMOND_ADDRESS.call(data);
        require(success, "Diamond upgrade failed");
        vm.stopPrank();
    }
}
