// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../helpers/AssertionHelper.sol";
import "../helpers/DeploymentHelper.sol";
import "../helpers/TestHelper.sol";

import {CarbonRetirementBondDepository} from "../../../src/protocol/bonds/CarbonRetirementBondDepository.sol";
import {RetirementBondAllocator} from "../../../src/protocol/allocators/RetirementBondAllocator.sol";
import {KlimaTreasury} from "../../../src/protocol/staking/utils/KlimaTreasury.sol";
import {IC3Pool} from "../../../src/infinity/interfaces/IC3.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";

contract RetireBondRetireCarbonDefaultTest is AssertionHelper, DeploymentHelper, TestHelper {
    CarbonRetirementBondDepository retireBond;
    RetirementBondAllocator allocator;
    KlimaTreasury treasury;

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
    address[] projectsUbo;
    address[] projectsNbo;
    address[] projectsBct;
    address[] projectsNct;

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

        projectsUbo = IC3Pool(UBO).getERC20Tokens();
        projectsNbo = IC3Pool(NBO).getERC20Tokens();
        projectsBct = IToucanPool(BCT).getScoredTCO2s();
        projectsNct = IToucanPool(NCT).getScoredTCO2s();
    }

    function test_protocol_retireBond_retireCarbonSpecific_BCT_fuzz(uint256 retireAmount) public {
        vm.assume(retireAmount <= IERC20(BCT).totalSupply());

        getKlima();

        uint256 poolBalance = IERC20(projectsBct[1]).balanceOf(BCT);

        if (retireAmount == 0) {
            vm.expectRevert("Cannot retire zero tokens");
        } else if ((retireAmount * 13_333) / 10_000 > IERC20(BCT).balanceOf(address(retireBond))) {
            vm.expectRevert("Not enough pool tokens to retire");
        } else if (retireAmount > poolBalance) {
            vm.expectRevert();
        }

        retireBond.retireCarbonSpecific(
            BCT, projectsBct[1], retireAmount, entity, beneficiaryAddress, beneficiary, message
        );
    }

    function test_protocol_retireBond_retireCarbonSpecific_NCT_fuzz(uint256 retireAmount) public {
        vm.assume(retireAmount <= IERC20(NCT).totalSupply());

        getKlima();

        uint256 poolBalance = IERC20(projectsNct[1]).balanceOf(NCT);

        if (retireAmount == 0) {
            vm.expectRevert("Cannot retire zero tokens");
        } else if ((retireAmount * 11_211) / 10_000 > IERC20(NCT).balanceOf(address(retireBond))) {
            vm.expectRevert("Not enough pool tokens to retire");
        } else if (retireAmount > poolBalance) {
            vm.expectRevert();
        }

        retireBond.retireCarbonSpecific(
            NCT, projectsNct[1], retireAmount, entity, beneficiaryAddress, beneficiary, message
        );
    }

    function test_protocol_retireBond_retireCarbonSpecific_MCO2() public {
        getKlima();

        uint256 retireAmount = 1e18;

        vm.expectRevert("Specific redeem not supported.");
        retireBond.retireCarbonSpecific(
            MCO2, address(0), retireAmount, entity, beneficiaryAddress, beneficiary, message
        );
    }

    function test_protocol_retireBond_retireCarbonSpecific_UBO_fuzz(uint256 retireAmount) public {
        vm.assume(retireAmount <= IERC20(UBO).totalSupply());

        getKlima();

        if (retireAmount == 0) {
            vm.expectRevert("Cannot retire zero tokens");
        } else if ((retireAmount * 10_225) / 10_000 > IERC20(UBO).balanceOf(address(retireBond))) {
            vm.expectRevert("Not enough pool tokens to retire");
        } else if (retireAmount > IERC20(projectsUbo[1]).balanceOf(UBO)) {
            vm.expectRevert("Not enough amount");
        }

        retireBond.retireCarbonSpecific(
            UBO, projectsUbo[1], retireAmount, entity, beneficiaryAddress, beneficiary, message
        );
    }

    function test_protocol_retireBond_retireCarbonSpecific_NBO_fuzz(uint256 retireAmount) public {
        vm.assume(retireAmount <= IERC20(NBO).totalSupply());

        getKlima();

        if (retireAmount == 0) {
            vm.expectRevert("Cannot retire zero tokens");
        } else if ((retireAmount * 10_225) / 10_000 > IERC20(NBO).balanceOf(address(retireBond))) {
            vm.expectRevert("Not enough pool tokens to retire");
        } else if (retireAmount > IERC20(projectsNbo[1]).balanceOf(NBO)) {
            vm.expectRevert("Not enough amount");
        }

        retireBond.retireCarbonSpecific(
            NBO, projectsNbo[1], retireAmount, entity, beneficiaryAddress, beneficiary, message
        );
    }

    function getKlima() internal {
        vm.prank(STAKING);
        IERC20(KLIMA).approve(address(this), 1_000_000 * 1e9);
        IERC20(KLIMA).transferFrom(STAKING, address(this), 1_000_000 * 1e9);
        IERC20(KLIMA).approve(address(retireBond), 1_000_000 * 1e9);
    }
}
