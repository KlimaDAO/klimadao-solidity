pragma solidity ^0.8.16;

import "../HelperContract.sol";
import {RetireICRFacet} from "../../../src/infinity/facets/Bridges/ICR/RetireICRFacet.sol";
import {RetirementQuoter} from "../../../src/infinity/facets/RetirementQuoter.sol";
import {LibRetire} from "../../../src/infinity/libraries/LibRetire.sol";
import {LibTransfer} from "../../../src/infinity/libraries/Token/LibTransfer.sol";
import {IERC1155} from "oz/token/ERC1155/IERC1155.sol";

import {console2} from "../../../lib/forge-std/src/console2.sol";

import "../TestHelper.sol";
import "../../helpers/AssertionHelper.sol";

contract RetireICRICCFacetTest is TestHelper, AssertionHelper {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint256 tokenId,
        uint256 retiredAmount
    );

    RetireICRFacet retireICRFacet;
    RetirementQuoter quoterFacet;
    ConstantsGetter constantsFacet;

    uint256 defaultCarbonRetireAmount = 5 * 1e18;
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";

    address diamond = vm.envAddress("INFINITY_ADDRESS");
    address beneficiaryAddress = vm.envAddress("BENEFICIARY_ADDRESS");

    address ICC = 0xaE63fBD056512fC4B1D15B58A98F9Aaea44b18a9;

    function setUp() public {
        addConstantsGetter(diamond);
        constantsFacet = ConstantsGetter(diamond);
        retireICRFacet = RetireICRFacet(diamond);
        quoterFacet = RetirementQuoter(diamond);

        upgradeCurrentDiamond(diamond);
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data)
        external
        returns (bytes4)
    {
        return this.onERC1155Received.selector;
    }

    function test_infinity_icrRetireExactICC() public {
        uint256 tokenId = 48;
        uint256 retireAmount = 100e18;
        mintERC1155Tokens(ICC, tokenId, retireAmount, address(this));

        // swipeERC20Tokens(DEFAULT_PROJECT, defaultCarbonRetireAmount, UBO, address(this));

        IERC1155(ICC).setApprovalForAll(diamond, true);

        uint256 currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint256 currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint256 expectedRetirements = currentRetirements + 1;
        uint256 expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;

        // Set up expectEmit
        vm.expectEmit(true, true, true, true);

        // Emit expected CarbonRetired event
        emit CarbonRetired(
            LibRetire.CarbonBridge.ICR,
            address(this),
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            address(0),
            ICC,
            tokenId,
            defaultCarbonRetireAmount
        );

        uint256 retirementIndex = retireICRFacet.icrRetireExactCarbon(
            ICC,
            tokenId,
            defaultCarbonRetireAmount,
            entity,
            beneficiaryAddress,
            beneficiary,
            message,
            LibTransfer.From.EXTERNAL
        );

        // No tokens left in contract
        // assertZeroTokenBalance(carbonToken, diamond);

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(retirementIndex, expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);
    }
}
