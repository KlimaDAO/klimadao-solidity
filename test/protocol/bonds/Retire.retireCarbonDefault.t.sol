// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../helpers/AssertionHelper.sol";
import "../helpers/DeploymentHelper.sol";
import "../helpers/TestHelper.sol";

import {CarbonRetirementBondDepository} from "../../../src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "../../../src/protocol/allocators/RetirementBondAllocator.sol";
import {KlimaTreasury} from "../../../src/protocol/staking/utils/KlimaTreasury.sol";
import {IC3Pool} from "../../../src/infinity/interfaces/IC3.sol";

contract RetireBondRetireCarbonDefaultTest is AssertionHelper, DeploymentHelper, TestHelper {
    CarbonRetirementBondDepository retireBond;
    RetirementBondAllocator allocator;
    KlimaTreasury treasury;

    event CarbonBonded(address pool, uint256 poolAmount);
    event KlimaBonded(uint256 daoFee, uint256 klimaBurned);

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");

    address infinityDiamond = vm.envAddress("INFINITY_ADDRESS");
    address deployedRetireBonds = 0xa595f0d598DaF144e5a7ca91E6D9A5bAA09dDeD0;
    address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
    address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;
    address MCO2 = 0xAa7DbD1598251f856C12f63557A4C4397c253Cea;
    address UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
    address NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;
    address KLIMA = vm.envAddress("KLIMA_ERC20_ADDRESS");
    address SUSHI_LP = vm.envAddress("SUSHI_BCT_LP");
    address STAKING = 0x25d28a24Ceb6F81015bB0b2007D795ACAc411b4d;
    address DEFAULT_PROJECT_UBO;
    address DEFAULT_PROJECT_NBO;

    function setUp() public {
        (address retireBondAddress, address allocatorAddress) = deployRetirementBondWithAllocator();
        retireBond = CarbonRetirementBondDepository(retireBondAddress);
        allocator = RetirementBondAllocator(allocatorAddress);

        toggleRetirementBondAllocatorWithTreasury(allocatorAddress);

        vm.startPrank(vm.envAddress("POLICY_MSIG"));

        retireBond.setPoolReference(BCT, vm.envAddress("SUSHI_BCT_LP"));
        retireBond.updateMaxSlippage(BCT, 200);
        retireBond.updateDaoFee(BCT, 3000);

        retireBond.setPoolReference(NCT, vm.envAddress("SUSHI_NCT_LP"));
        retireBond.updateMaxSlippage(NCT, 200);
        retireBond.updateDaoFee(NCT, 3000);

        retireBond.setPoolReference(MCO2, vm.envAddress("MCO2_QUICKSWAP"));
        retireBond.updateMaxSlippage(MCO2, 200);
        retireBond.updateDaoFee(MCO2, 3000);

        retireBond.setPoolReference(UBO, vm.envAddress("TRIDENT_UBO_LP"));
        retireBond.updateMaxSlippage(UBO, 200);
        retireBond.updateDaoFee(UBO, 3000);

        retireBond.setPoolReference(NBO, vm.envAddress("TRIDENT_NBO_LP"));
        retireBond.updateMaxSlippage(NBO, 200);
        retireBond.updateDaoFee(NBO, 3000);

        allocator.fundBonds(BCT, maxBondAmount(BCT, address(allocator)));
        allocator.fundBonds(NCT, maxBondAmount(NCT, address(allocator)));
        allocator.fundBonds(MCO2, maxBondAmount(MCO2, address(allocator)));
        allocator.fundBonds(UBO, maxBondAmount(UBO, address(allocator)));
        allocator.fundBonds(NBO, maxBondAmount(NBO, address(allocator)));
        vm.stopPrank();

        DEFAULT_PROJECT_UBO = IC3Pool(UBO).getFreeRedeemAddresses()[0];
        DEFAULT_PROJECT_NBO = IC3Pool(NBO).getFreeRedeemAddresses()[0];
    }

    function test_protocol_retireBond_retireCarbonDefault_BCT_fuzz(uint256 retireAmount) public {
        vm.assume(retireAmount <= IERC20(BCT).totalSupply());
        vm.assume(retireAmount < (IERC20(BCT).balanceOf(vm.envAddress("SUSHI_BCT_LP")) * 50) / 100);

        getKlima();

        if (retireAmount == 0) {
            vm.expectRevert("Cannot retire zero tokens");
        } else if (retireAmount > IERC20(BCT).balanceOf(address(retireBond))) {
            vm.expectRevert("Not enough pool tokens to retire");
        } else {
            uint256 klimaAmount = retireBond.getKlimaAmount((retireAmount * 101) / 100, BCT);
            uint256 daoFee = (klimaAmount * 3000) / 10_000;
            vm.expectEmit(true, true, true, true);
            emit KlimaBonded(daoFee, klimaAmount - daoFee);

            vm.expectEmit(true, true, true, true);
            emit CarbonBonded(BCT, (retireAmount * 101) / 100);
        }

        retireBond.retireCarbonDefault(BCT, retireAmount, entity, beneficiaryAddress, beneficiary, message);
    }

    function test_protocol_retireBond_retireCarbonDefault_NCT_fuzz(uint256 retireAmount) public {
        vm.assume(retireAmount <= IERC20(NCT).totalSupply());

        getKlima();

        if (retireAmount == 0) {
            vm.expectRevert("Cannot retire zero tokens");
        } else if (retireAmount > IERC20(NCT).balanceOf(address(retireBond))) {
            vm.expectRevert("Not enough pool tokens to retire");
        } else {
            uint256 klimaAmount = retireBond.getKlimaAmount((retireAmount * 101) / 100, NCT);
            uint256 daoFee = (klimaAmount * 3000) / 10_000;
            vm.expectEmit(true, true, true, true);
            emit KlimaBonded(daoFee, klimaAmount - daoFee);

            vm.expectEmit(true, true, true, true);
            emit CarbonBonded(NCT, (retireAmount * 101) / 100);
        }

        retireBond.retireCarbonDefault(NCT, retireAmount, entity, beneficiaryAddress, beneficiary, message);
    }

    function test_protocol_retireBond_retireCarbonDefault_MCO2_fuzz(uint256 retireAmount) public {
        vm.assume(retireAmount <= IERC20(MCO2).totalSupply());

        // Policy wouldn't allocate more than the amount of tokens available in the LP supply
        vm.assume(retireAmount < (IERC20(MCO2).balanceOf(vm.envAddress("MCO2_QUICKSWAP")) * 90) / 100);

        getKlima();

        if (retireAmount == 0) {
            vm.expectRevert("Cannot retire zero tokens");
        } else if (retireAmount > IERC20(MCO2).balanceOf(address(retireBond))) {
            vm.expectRevert("Not enough pool tokens to retire");
        } else {
            uint256 klimaAmount = retireBond.getKlimaAmount((retireAmount * 101) / 100, MCO2);
            uint256 daoFee = (klimaAmount * 3000) / 10_000;
            vm.expectEmit(true, true, true, true);
            emit KlimaBonded(daoFee, klimaAmount - daoFee);

            vm.expectEmit(true, true, true, true);
            emit CarbonBonded(MCO2, (retireAmount * 101) / 100);
        }

        retireBond.retireCarbonDefault(MCO2, retireAmount, entity, beneficiaryAddress, beneficiary, message);
    }

    function test_protocol_retireBond_retireCarbonDefault_UBO_fuzz(uint256 retireAmount) public {
        vm.assume(retireAmount <= IERC20(UBO).totalSupply());

        getKlima();

        if (retireAmount == 0) {
            vm.expectRevert("Cannot retire zero tokens");
        } else if (retireAmount > IERC20(UBO).balanceOf(address(retireBond))) {
            vm.expectRevert("Not enough pool tokens to retire");
        } else if (retireAmount > IERC20(DEFAULT_PROJECT_UBO).balanceOf(UBO)) {
            vm.expectRevert("Amount exceeds available tokens");
        } else {
            uint256 klimaAmount = retireBond.getKlimaAmount((retireAmount * 101) / 100, UBO);
            uint256 daoFee = (klimaAmount * 3000) / 10_000;
            vm.expectEmit(true, true, true, true);
            emit KlimaBonded(daoFee, klimaAmount - daoFee);

            vm.expectEmit(true, true, true, true);
            emit CarbonBonded(UBO, (retireAmount * 101) / 100);
        }

        retireBond.retireCarbonDefault(UBO, retireAmount, entity, beneficiaryAddress, beneficiary, message);
    }

    function test_protocol_retireBond_retireCarbonDefault_NBO_fuzz(uint256 retireAmount) public {
        vm.assume(retireAmount <= IERC20(NBO).totalSupply());

        getKlima();

        if (retireAmount == 0) {
            vm.expectRevert("Cannot retire zero tokens");
        } else if (retireAmount > IERC20(NBO).balanceOf(address(retireBond))) {
            vm.expectRevert("Not enough pool tokens to retire");
        } else if (retireAmount > IERC20(DEFAULT_PROJECT_NBO).balanceOf(NBO)) {
            vm.expectRevert("Amount exceeds available tokens");
        } else {
            uint256 klimaAmount = retireBond.getKlimaAmount((retireAmount * 101) / 100, NBO);
            uint256 daoFee = (klimaAmount * 3000) / 10_000;
            vm.expectEmit(true, true, true, true);
            emit KlimaBonded(daoFee, klimaAmount - daoFee);

            vm.expectEmit(true, true, true, true);
            emit CarbonBonded(NBO, (retireAmount * 101) / 100);
        }

        retireBond.retireCarbonDefault(NBO, retireAmount, entity, beneficiaryAddress, beneficiary, message);
    }

    function getKlima() internal {
        vm.prank(STAKING);
        IERC20(KLIMA).approve(address(this), 1_000_000 * 1e9);
        IERC20(KLIMA).transferFrom(STAKING, address(this), 1_000_000 * 1e9);
        IERC20(KLIMA).approve(address(retireBond), 1_000_000 * 1e9);
    }
}
