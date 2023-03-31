pragma solidity ^0.8.16;

import "./HelperContract.sol";
import "../../src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol";

import {console} from "../../lib/forge-std/src/console.sol";


interface IRetirementQuoter {
    function getSourceAmountSwapOnly(address sourceToken, address carbonToken, uint amountOut)
        external
        view
        returns (uint amountIn);

    function getSourceAmountDefaultRetirement(address sourceToken, address carbonToken, uint retireAmount)
        external
        view
        returns (uint amountIn);

    function getSourceAmountSpecificRetirement(address sourceToken, address carbonToken, uint retireAmount)
        external
        view
        returns (uint amountIn);

    function getSourceAmountDefaultRedeem(address sourceToken, address carbonToken, uint redeemAmount)
        external
        view
        returns (uint amountIn);

    function getSourceAmountSpecificRedeem(address sourceToken, address carbonToken, uint[] memory redeemAmounts)
        external
        view
        returns (uint amountIn);
}

interface IRetireC3C3TFacet {

    function c3RetireExactC3T(
        address carbonToken,
        uint amount,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external returns (uint retirementIndex);

    function c3RetireExactC3TWithEntity(
        address carbonToken,
        uint amount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external returns (uint retirementIndex);

}

contract RedeemC3PoolFacetTest is HelperContract {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint retiredAmount
    );

    IRetireC3C3TFacet retireC3C3TFacet;
    IRetirementQuoter quoterFacet;

    address uboDefaultProjectAddress = 0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA;
    address nboDefaultProjectAddress = 0xb6eA7a53FC048D6d3B80b968D696E39482B7e578;
    address uboSpecificProjectAddress = 0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA;
    address nboSpecificProjectAddress = 0xD28DFEBa8fB9e44B715156162C8b6076d7a95Ad1;

    uint defaultCarbonRetireAmount = 100 * 1e18;
    string beneficiary = "Test Beneficiary";
    string message = "Test Message";
    string entity = "Test Entity";
    address beneficiaryAddress = 0x000000000000000000000000000000000000dEaD;
    address diamond = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;
    address KlimaTreasury = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
    address KlimaStaking = 0x25d28a24Ceb6F81015bB0b2007D795ACAc411b4d;
    address wsKLIMA_holder = 0xe02efadA566Af74c92b6659d03BAaCb4c06Cc856; // C3 wsKLIMA gauge

    address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
    address SKLIMA = 0xb0C22d8D350C67420f06F48936654f567C73E8C8;
    address WSKLIMA = 0x6f370dba99E32A3cAD959b341120DB3C9E280bA6;
    
    address UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
    address NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;

    function setUp() public {
        retireC3C3TFacet = IRetireC3C3TFacet(diamond);
        quoterFacet = IRetirementQuoter(diamond);
    }

    function test_c3RetireExactC3T() public {
        address sourceToken = uboDefaultProjectAddress;
        address carbonToken = uboDefaultProjectAddress;
        swipeERC20Tokens(uboDefaultProjectAddress, defaultCarbonRetireAmount, UBO, address(this));
        IERC20(sourceToken).approve(diamond, defaultCarbonRetireAmount);

        uint initialBalance = IERC20(carbonToken).balanceOf(address(this));
        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;
        uint expectedBalance = initialBalance - defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

        uint retirementIndex = retireC3C3TFacet.c3RetireExactC3T(carbonToken, defaultCarbonRetireAmount, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[5].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(expectedBalance, IERC20(carbonToken).balanceOf(address(this)));

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);


        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[5].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[5].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[5].topics[3]))); 

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[5].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(2, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq("KlimaDAO Retirement Aggregator", retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(address(0), emitted_carbonPool); // no pool for direct C3T retirement
        assertEq(uboDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }

    function test_c3RetireExactC3TWithEntity() public {
        address sourceToken = uboDefaultProjectAddress;
        address carbonToken = uboDefaultProjectAddress;
        swipeERC20Tokens(uboDefaultProjectAddress, defaultCarbonRetireAmount, UBO, address(this));
        IERC20(sourceToken).approve(diamond, defaultCarbonRetireAmount);

        uint initialBalance = IERC20(carbonToken).balanceOf(address(this));
        uint currentRetirements = LibRetire.getTotalRetirements(beneficiaryAddress);
        uint currentTotalCarbon = LibRetire.getTotalCarbonRetired(beneficiaryAddress);

        uint expectedRetirements = currentRetirements +1;
        uint expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount;
        uint expectedBalance = initialBalance - defaultCarbonRetireAmount;

        // Start recording logs
        vm.recordLogs();

        uint retirementIndex = retireC3C3TFacet.c3RetireExactC3TWithEntity(carbonToken, defaultCarbonRetireAmount, entity, beneficiaryAddress, beneficiary, message, LibTransfer.From.EXTERNAL);

        // Get the recorded logs
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Verify the CarbonRetired event emitted
        assertEq(entries[5].topics[0], keccak256("CarbonRetired(uint8,address,string,address,string,string,address,address,uint256)"));

        // No tokens left in contract
        assertEq(expectedBalance, IERC20(carbonToken).balanceOf(address(this)));

        // Account state values updated
        assertEq(LibRetire.getTotalRetirements(beneficiaryAddress), expectedRetirements);
        assertEq(LibRetire.getTotalCarbonRetired(beneficiaryAddress), expectedCarbonRetired);


        // Read indexed parameters from topics
        address retiringAddress = address(uint160(uint256(entries[5].topics[1])));
        address emitted_BeneficiaryAddr = address(uint160(uint256(entries[5].topics[2])));
        address emitted_carbonPool = address(uint160(uint256(entries[5].topics[3]))); 

        // Decode non-indexed parameters from data
        (LibRetire.CarbonBridge carbonBridge, string memory retiringEntityString, string memory beneficiaryString, string memory retirementMessage, address carbonTokenRetired, uint256 retiredAmount) = abi.decode(entries[5].data, (LibRetire.CarbonBridge, string, string, string, address, uint256));

        // verify details of CarbonRetired event emitted
        assertEq(2, uint8(carbonBridge));
        assertEq(address(this), retiringAddress);
        assertEq(entity, retiringEntityString);
        assertEq(beneficiaryAddress, emitted_BeneficiaryAddr);
        assertEq(address(0), emitted_carbonPool); // no pool for direct C3T retirement
        assertEq(uboDefaultProjectAddress, carbonTokenRetired);
        assertEq(defaultCarbonRetireAmount, retiredAmount, "Incorrect amount retired");
        assertEq(retirementIndex, LibRetire.getTotalRetirements(beneficiaryAddress));
        assertEq(beneficiary, beneficiaryString);
        assertEq(message, retirementMessage);

    }





}
