pragma solidity ^0.8.16;

import {RetireCarbonFacet} from "../../../src/infinity/facets/Retire/RetireCarbonFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibCoorestCarbon} from "../../../src/infinity/libraries/Bridges/LibCoorestCarbon.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IToucanPool} from "../../../src/infinity/interfaces/IToucan.sol";
import {OwnershipFacet} from "../../../src/infinity/facets/OwnershipFacet.sol";
import {DiamondInitCoorest} from "../../../src/infinity/init/DiamondInitCoorest.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

contract RetireExactCarbonSpecificCoorest is TestHelper, AssertionHelper {
    RetireCarbonFacet retireCarbonFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    // Retirement details
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    // Addresses defined in .env
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");
    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address USDC_HOLDER = vm.envAddress("USDC_HOLDER");
    address SUSHI_LP = vm.envAddress("SUSHI_CCO2_LP");
    address CCO2 = vm.envAddress("COOREST_TOKEN");

    // Addresses pulled from current diamond constants
    address KLIMA_TREASURY;
    address USDC;

    function upgradeDiamond(address infinityDiamond) internal {
        ownerF = OwnershipFacet(infinityDiamond);

        vm.startPrank(ownerF.owner());

        RetirementQuoter _retirementQuoterF = new RetirementQuoter();
        RetireCarbonFacet _retireCarbonF = new RetireCarbonFacet();
        DiamondInitCoorest _diamondInitCoorest = new DiamondInitCoorest();

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(_retireCarbonF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetireCarbonFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(_retirementQuoterF),
                action: IDiamondCut.FacetCutAction.Replace,
                functionSelectors: generateSelectors("RetirementQuoter")
            })
        );

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(_diamondInitCoorest),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondInitCoorest")
            })
        );

        IDiamondCut(address(diamond)).diamondCut(cut, address(_diamondInitCoorest), abi.encodeWithSignature("init()"));

        vm.stopPrank();
    }

    // Works with BlockNo : 60542813, Network Polygon.
    function setUp() public {
        addConstantsGetter(diamond);
        upgradeDiamond(diamond);

        retireCarbonFacet = RetireCarbonFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);
        constantsFacet = ConstantsGetter(diamond);

        KLIMA_TREASURY = constantsFacet.treasury();
        USDC = constantsFacet.usdc();

        // sendDustToTreasury(diamond);
        // fundRetirementBonds(constantsFacet.klimaRetirementBond()); // Can be removed ....
    }

    function test_infinity_retireExactCarbonSpecific_CCO2_USDC() public {
        retireExactCCO2(USDC, 100e18); // We want to retire
    }

    // NOTE: Check who might have USDC ..
    function getSourceTokens(address sourceToken, uint retireAmount) internal returns (uint sourceAmount) {
        /// @dev getting trade amount on zero output will revert => PUT THIS BACK
        // if (retireAmount == 0 && sourceToken != NCT) vm.expectRevert();

        sourceAmount = quoterFacet.getSourceAmountSpecificRetirement(sourceToken, CCO2, retireAmount); // retireAmount ==> How much CCO2 We want to retire.. :)

        address sourceTarget;

        if (sourceToken == USDC) sourceTarget = USDC_HOLDER;

        vm.assume(sourceAmount <= IERC20(sourceToken).balanceOf(sourceTarget));

        swipeERC20Tokens(sourceToken, sourceAmount, sourceTarget, address(this));
        IERC20(sourceToken).approve(diamond, sourceAmount);
    }

    function retireExactCCO2(address sourceToken, uint retireAmount) public {
        uint sourceAmount = getSourceTokens(sourceToken, retireAmount);

        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit LibCoorestCarbon.CarbonRetired(
            LibRetire.CarbonBridge.COOREST,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            CCO2,
            address(0),
            retireAmount
        );

        uint256 retirementIndex = retireCarbonFacet.retireExactCarbonSpecific(
            sourceToken,
            CCO2,
            CCO2,
            sourceAmount,
            retireAmount,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        // assertZeroTokenBalance(sourceToken, diamond);
        // assertZeroTokenBalance(CCO2, diamond);
        // assertZeroTokenBalance(projectToken, diamond);

        // Return value matches
        // assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), retirementIndex);

        // // Account state values updated
        // assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), currentRetirements + 1);
        // assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), currentTotalCarbon + retireAmount);
        // }
    }
}
