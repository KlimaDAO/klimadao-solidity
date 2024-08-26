// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Test, console, stdError} from "forge-std/Test.sol";
import {stdMath} from "forge-std/StdMath.sol";
import {Strings} from "oz/utils/Strings.sol";

import {Users} from "test/helpers/Users.sol";

import "src/retirement_v1/interfaces/IKlimaCarbonRetirements.sol";

// Diamond Deployment
import "../../src/infinity/interfaces/IDiamondCut.sol";
import {Diamond} from "src/infinity/Diamond.sol";
import "src/infinity/facets/DiamondCutFacet.sol";
import "src/infinity/facets/DiamondLoupeFacet.sol";
import {OwnershipFacet} from "src/infinity/facets/OwnershipFacet.sol";
import {RedeemC3PoolFacet} from "src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";
import {RetireC3C3TFacet} from "src/infinity/facets/Bridges/C3/RetireC3C3TFacet.sol";
import {RetireICRFacet} from "src/infinity/facets/Bridges/ICR/RetireICRFacet.sol";
import {RedeemToucanPoolFacet} from "src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol";
import {RetireToucanTCO2Facet} from "src/infinity/facets/Bridges/Toucan/RetireToucanTCO2Facet.sol";
import {RetireCarbonFacet} from "src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetireCarbonmarkFacet} from "src/infinity/facets/Retire/RetireCarbonmarkFacet.sol";
import {RetireInfoFacet} from "src/infinity/facets/Retire/RetireInfoFacet.sol";
import {RetireSourceFacet} from "src/infinity/facets/Retire/RetireSourceFacet.sol";
import {RetirementQuoter} from "src/infinity/facets/RetirementQuoter.sol";
import {ERC1155ReceiverFacet} from "src/infinity/facets/ERC1155ReceiverFacet.sol";
import {DiamondInit} from "src/infinity/init/DiamondInit.sol";
import {ConstantsGetter} from "src/infinity/mocks/ConstantsGetter.sol";
import {DustFacet} from "src/infinity/facets/DustFacet.sol";
import {C3SushiInit} from "src/infinity/init/C3SushiInit.sol";
import {DiamondInitCoorest} from "../src/infinity/init/DiamondInitCoorest.sol";
import {IKlimaTreasury, IKlimaRetirementBond, IRetirementBondAllocator} from "src/protocol/interfaces/IKLIMA.sol";
import {ICRProject} from "./interfaces/ICR.sol";
import {IC3Pool} from "src/infinity/interfaces/IC3.sol";
import {IToucanPool} from "src/infinity/interfaces/IToucan.sol";
import {IwsKLIMA} from "src/infinity/interfaces/IKlima.sol";
import "./HelperContract.sol";

abstract contract TestHelper is Test, HelperContract {
    using Strings for uint256;

    enum TransactionType {
        EXACT_SOURCE,
        DEFAULT_REDEEM,
        SPECIFIC_REDEEM,
        DEFAULT_RETIRE,
        SPECIFIC_RETIRE
    }

    // Users
    Users users;
    address user;
    address user2;

    // Diamond deployment public key
    address deployerAddress = vm.envAddress("PUBLIC_KEY");

    DiamondCutFacet dCutF;
    DiamondLoupeFacet dLoupeF;
    OwnershipFacet ownerF;
    RedeemC3PoolFacet c3RedeemF;
    RetireC3C3TFacet c3RetireF;
    RedeemToucanPoolFacet toucanRedeemF;
    RetireToucanTCO2Facet toucanRetireF;
    RetireCarbonFacet retireCarbonF;
    RetireInfoFacet retireInfoF;
    RetireSourceFacet retireSourceF;
    RetirementQuoter retirementQuoterF;
    RetireCarbonmarkFacet retireCarbonmarkF;
    RetireICRFacet retireICRF;
    ERC1155ReceiverFacet erc1155ReceiverF;

    function setupInfinity() internal returns (address) {
        //deploy facets and init contract
        dCutF = new DiamondCutFacet();
        dLoupeF = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        c3RedeemF = new RedeemC3PoolFacet();
        c3RetireF = new RetireC3C3TFacet();
        toucanRedeemF = new RedeemToucanPoolFacet();
        toucanRetireF = new RetireToucanTCO2Facet();
        retireCarbonF = new RetireCarbonFacet();
        retireInfoF = new RetireInfoFacet();
        retireSourceF = new RetireSourceFacet();
        retirementQuoterF = new RetirementQuoter();

        DiamondInit diamondInit = new DiamondInit();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](10);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(dLoupeF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(ownerF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        // Klima Infinity specific facets

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(c3RedeemF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RedeemC3PoolFacet")
            })
        );

        cut[3] = (
            IDiamondCut.FacetCut({
                facetAddress: address(c3RetireF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireC3C3TFacet")
            })
        );

        cut[4] = (
            IDiamondCut.FacetCut({
                facetAddress: address(toucanRedeemF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RedeemToucanPoolFacet")
            })
        );

        cut[5] = (
            IDiamondCut.FacetCut({
                facetAddress: address(toucanRetireF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireToucanTCO2Facet")
            })
        );

        cut[6] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cut[7] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireInfoF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireSourceFacet")
            })
        );

        cut[8] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireSourceF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetireInfoFacet")
            })
        );

        cut[9] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retirementQuoterF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );

        // deploy diamond and perform diamondCut
        Diamond diamond = new Diamond(deployerAddress, address(dCutF));
        IDiamondCut(address(diamond)).diamondCut(cut, address(diamondInit), abi.encodeWithSignature("init()"));

        return address(diamond);
    }

    function addConstantsGetter(address infinityDiamond) internal {
        ownerF = OwnershipFacet(infinityDiamond);

        vm.startPrank(ownerF.owner());

        ConstantsGetter constantF = new ConstantsGetter();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(constantF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("ConstantsGetter")
            })
        );

        IDiamondCut(infinityDiamond).diamondCut(cut, address(0), "");
        vm.stopPrank();
    }

    function upgradeCurrentDiamond(address infinityDiamond) internal {
        ownerF = OwnershipFacet(infinityDiamond);

        vm.startPrank(ownerF.owner());

        //deploy facets and init contract
        // c3RedeemF = new RedeemC3PoolFacet();
        // toucanRedeemF = new RedeemToucanPoolFacet();
        // retirementQuoterF = new RetirementQuoter();
        // retireCarbonF = new RetireCarbonFacet();
        // retireSourceF = new RetireSourceFacet();
        // retireCarbonmarkF = new RetireCarbonmarkFacet();
        // retireICRF = new RetireICRFacet();
        // erc1155ReceiverF = new ERC1155ReceiverFacet();
        // toucanRetireF = new RetireToucanTCO2Facet();

        DiamondInitCoorest initCoorestF = new DiamondInitCoorest();
        C3SushiInit init = new C3SushiInit();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);
        IDiamondCut.FacetCut[] memory emptyCut = new IDiamondCut.FacetCut[](0);

        // // Klima Infinity specific facets

        // bytes4[] memory replace = new bytes4[](2);
        // bytes4[] memory add = new bytes4[](1);

        // replace[0] = 0x1fd1a6ac;
        // replace[1] = 0x01e85bd2;
        // add[0] = 0xdadd9192;

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireCarbonF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retirementQuoterF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(retireSourceFacet),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireSourceFacet")
            })
        );

        // deploy diamond and perform diamondCut
        // IDiamondCut(infinityDiamond).diamondCut(cut, address(0), "");

        // Init Contract Only
        IDiamondCut(infinityDiamond).diamondCut(cut, address(initCoorestF), abi.encodeWithSignature("init()"));
        IDiamondCut(infinityDiamond).diamondCut(emptyCut, address(init), abi.encodeWithSignature("init()"));
        vm.stopPrank();
    }

    function sendDustToTreasury(address infinityDiamond) internal {
        ownerF = OwnershipFacet(infinityDiamond);

        vm.startPrank(ownerF.owner());

        DustFacet dustF = new DustFacet();

        // FacetCut array which contains the three standard facets to be added
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(dustF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("DustFacet")
            })
        );

        IDiamondCut(infinityDiamond).diamondCut(cut, address(0), "");
        DustFacet wrappedDust = DustFacet(infinityDiamond);
        wrappedDust.sendDust();
        vm.stopPrank();
    }

    function initUser() internal {
        users = new Users();
        address[] memory _user = new address[](2);
        _user = users.createUsers(2);
        user = _user[0];
        user2 = _user[1];
    }

    function fundRetirementBonds(address retirementBonds) internal {
        // Assuming mainnet fork testing for the moment
        address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
        address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;
        address MCO2 = 0xAa7DbD1598251f856C12f63557A4C4397c253Cea;
        address UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
        address NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;

        address owner = IKlimaRetirementBond(retirementBonds).owner();
        address allocator = IKlimaRetirementBond(retirementBonds).allocatorContract();

        if (!IKlimaTreasury(IKlimaRetirementBond(retirementBonds).TREASURY()).isReserveManager(allocator)) {
            vm.startPrank(IKlimaRetirementBond(retirementBonds).DAO());

            IRetirementBondAllocator(allocator).updateMaxReservePercent(500);

            if (!IKlimaTreasury(IKlimaRetirementBond(retirementBonds).TREASURY()).isReserveManager(allocator)) {
                IKlimaTreasury(IKlimaRetirementBond(retirementBonds).TREASURY()).queue(3, allocator);

                vm.roll(IKlimaTreasury(IKlimaRetirementBond(retirementBonds).TREASURY()).ReserveManagerQueue(allocator));

                IKlimaTreasury(IKlimaRetirementBond(retirementBonds).TREASURY()).toggle(3, allocator, address(0));
            }

            vm.stopPrank();
        }
        vm.startPrank(owner);

        IKlimaRetirementBond(retirementBonds).setPoolReference(BCT, vm.envAddress("SUSHI_BCT_LP"));
        IKlimaRetirementBond(retirementBonds).updateMaxSlippage(BCT, 200);
        IKlimaRetirementBond(retirementBonds).updateDaoFee(BCT, 3000);

        IKlimaRetirementBond(retirementBonds).setPoolReference(NCT, vm.envAddress("SUSHI_NCT_LP"));
        IKlimaRetirementBond(retirementBonds).updateMaxSlippage(NCT, 200);
        IKlimaRetirementBond(retirementBonds).updateDaoFee(NCT, 3000);

        IKlimaRetirementBond(retirementBonds).setPoolReference(MCO2, vm.envAddress("MCO2_QUICKSWAP"));
        IKlimaRetirementBond(retirementBonds).updateMaxSlippage(MCO2, 200);
        IKlimaRetirementBond(retirementBonds).updateDaoFee(MCO2, 3000);

        IKlimaRetirementBond(retirementBonds).setPoolReference(UBO, vm.envAddress("TRIDENT_UBO_LP"));
        IKlimaRetirementBond(retirementBonds).updateMaxSlippage(UBO, 200);
        IKlimaRetirementBond(retirementBonds).updateDaoFee(UBO, 3000);

        IKlimaRetirementBond(retirementBonds).setPoolReference(NBO, vm.envAddress("TRIDENT_NBO_LP"));
        IKlimaRetirementBond(retirementBonds).updateMaxSlippage(NBO, 200);
        IKlimaRetirementBond(retirementBonds).updateDaoFee(NBO, 3000);

        IRetirementBondAllocator(allocator).fundBonds(BCT, maxBondAmount(BCT, allocator));
        IRetirementBondAllocator(allocator).fundBonds(NCT, maxBondAmount(NCT, allocator));
        IRetirementBondAllocator(allocator).fundBonds(MCO2, maxBondAmount(MCO2, allocator));
        IRetirementBondAllocator(allocator).fundBonds(UBO, maxBondAmount(UBO, allocator));
        IRetirementBondAllocator(allocator).fundBonds(NBO, maxBondAmount(NBO, allocator));

        vm.stopPrank();
    }

    function closeRetirementBonds(address retirementBonds) internal {
        // Assuming mainnet fork testing for the moment
        address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
        address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;
        address MCO2 = 0xAa7DbD1598251f856C12f63557A4C4397c253Cea;
        address UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
        address NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;

        address allocator = IKlimaRetirementBond(retirementBonds).allocatorContract();

        address owner = IRetirementBondAllocator(allocator).owner();

        vm.startPrank(owner);

        IRetirementBondAllocator(allocator).closeBonds(BCT);
        IRetirementBondAllocator(allocator).closeBonds(NCT);
        IRetirementBondAllocator(allocator).closeBonds(MCO2);
        IRetirementBondAllocator(allocator).closeBonds(UBO);
        IRetirementBondAllocator(allocator).closeBonds(NBO);

        vm.stopPrank();
    }

    function maxBondAmount(address token, address allocator) internal returns (uint256 maxAmount) {
        address treasury = vm.envAddress("KLIMA_TREASURY_ADDRESS");
        uint256 maxReserve = IRetirementBondAllocator(allocator).maxReservePercent();
        uint256 maxDivisor = IRetirementBondAllocator(allocator).PERCENT_DIVISOR();

        uint256 currentExcessReserves = IKlimaTreasury(treasury).excessReserves() * 1e9;
        uint256 maxExcessReserves = (currentExcessReserves * maxReserve) / maxDivisor;
        uint256 maxTreasuryHoldings = (IERC20(token).balanceOf(treasury) * maxReserve) / maxDivisor;

        maxAmount = maxExcessReserves >= maxTreasuryHoldings ? maxTreasuryHoldings : maxExcessReserves;
    }

    function getSourceTokens(
        TransactionType txType,
        address diamond,
        address sourceToken,
        address pool,
        uint256 amountOut
    ) internal returns (uint256 sourceAmount) {
        ConstantsGetter constantsFacet = ConstantsGetter(diamond);
        address USDC_BRIDGED_HOLDER = vm.envAddress("USDC_BRIDGED_HOLDER");
        address WSKLIMA_HOLDER = vm.envAddress("WSKLIMA_HOLDER");

        RetirementQuoter quoterFacet = RetirementQuoter(diamond);
        if (txType == TransactionType.EXACT_SOURCE) {
            sourceAmount = amountOut;
        } else if (txType == TransactionType.DEFAULT_REDEEM) {
            sourceAmount = quoterFacet.getSourceAmountDefaultRedeem(sourceToken, pool, amountOut);
        } else if (txType == TransactionType.SPECIFIC_REDEEM) {
            uint256[] memory amounts = new uint256[](1);
            amounts[0] = amountOut;
            sourceAmount = quoterFacet.getSourceAmountSpecificRedeem(sourceToken, pool, amounts);
        } else if (txType == TransactionType.DEFAULT_RETIRE) {
            sourceAmount = quoterFacet.getSourceAmountDefaultRetirement(sourceToken, pool, amountOut);
        } else if (txType == TransactionType.SPECIFIC_RETIRE) {
            sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, pool, amountOut);
        }

        address sourceTarget;

        if (sourceToken == constantsFacet.usdc()) {
            sourceTarget = USDC_BRIDGED_HOLDER;
        } else if (sourceToken == constantsFacet.klima() || sourceToken == constantsFacet.sKlima()) {
            sourceTarget = constantsFacet.staking();

            // Ensure that any sKLIMA pulled can succesfully be unstaked
            uint256 stakingBalance = IERC20(constantsFacet.klima()).balanceOf(constantsFacet.sKlima());
            vm.assume(sourceAmount < stakingBalance / 2);
        } else if (sourceToken == constantsFacet.wsKlima()) {
            sourceTarget = WSKLIMA_HOLDER;
        } else {
            sourceTarget = constantsFacet.treasury();
        }

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    //////////// EVM Helpers ////////////

    function increaseTime(uint256 _seconds) internal {
        vm.warp(block.timestamp + _seconds);
    }

    modifier prank(address from) {
        vm.startPrank(from);
        _;
        vm.stopPrank();
    }

    //////////// Other Helpers ////////////

    function randomish(uint256 maxValue) internal view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp)));
        return (seed % (maxValue));
    }

    function mintERC1155Tokens(address token, uint256 tokenId, uint256 amount, address recipient) internal {
        ICRProject project = ICRProject(token);

        // address minter = project.owner();

        vm.prank(0xA0022c05501007281acAE55B94AdE4Fc3dd59ec3);
        project.verifyAndMintExPost(recipient, tokenId, amount, 0, 3_124_224_000, 3_124_224_000, "testing");
    }

    function getDefaultC3Project(address pool) internal view returns (address) {
        address[] memory projects = IC3Pool(pool).getFreeRedeemAddresses();

        for (uint256 i; i < projects.length; ++i) {
            uint256 balance = IERC20(projects[i]).balanceOf(pool);
            if (balance > 0) return projects[i];
        }
    }

    function getDefaultToucanProject(address pool) internal view returns (address) {
        address[] memory projects = IToucanPool(pool).getScoredTCO2s();

        for (uint256 i; i < projects.length; ++i) {
            uint256 balance = IERC20(projects[i]).balanceOf(pool);
            if (balance > 0) return projects[i];
        }
    }
}
