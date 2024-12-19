// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

/**
 * \
 * Authors: Cujo <rawr@cujowolf.dev>
 *
 * Script to deploy the Klima protocol contracts
 * /*****************************************************************************
 */
import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {console} from "forge-std/console.sol";

import {KlimaStaking} from "../src/protocol/staking/regular/KlimaStaking_v2.sol";
import {StakingHelper} from "../src/protocol/staking/regular/StakingHelper.sol";
import {StakingWarmup} from "../src/protocol/staking/regular/StakingWarmup.sol";
import {Distributor} from "../src/protocol/staking/regular/KlimaStakingDistributor_v4.sol";

contract DeployKlimaStaking is Script {
    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address klimaAddress = vm.envAddress("KLIMA_ERC20_ADDRESS");
        address sKlimaAddress = vm.envAddress("KLIMA_ERC20_ADDRESS");
        address treasuryAddress = vm.envAddress("KLIMA_ERC20_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // epoch length in blocks
        uint256 epochLength = 11_520;
        // first epoch number
        uint256 firstEpochNumber = 0;
        // first epoch block
        uint256 firstEpochBlock = block.number;

        KlimaStaking klimaStaking =
            new KlimaStaking(klimaAddress, sKlimaAddress, epochLength, firstEpochNumber, firstEpochBlock);
        console.log("Klima Staking deployed at: ", address(klimaStaking));

        StakingHelper stakingHelper = new StakingHelper(address(klimaStaking), klimaAddress);
        console.log("Staking Helper deployed at: ", address(stakingHelper));

        StakingWarmup stakingWarmup = new StakingWarmup(address(klimaStaking), sKlimaAddress);
        console.log("Staking Warmup deployed at: ", address(stakingWarmup));

        Distributor klimaDistributor = new Distributor(treasuryAddress, klimaAddress, epochLength, firstEpochBlock);
        console.log("Klima Distributor deployed at: ", address(klimaDistributor));

        vm.stopBroadcast();
    }
}
