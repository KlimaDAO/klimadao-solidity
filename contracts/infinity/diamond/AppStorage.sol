// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../libraries/LibRetire.sol";

/**
 * @author Cujo
 * @title App Storage defines the state object for Klima Infinity
 */

contract Account {
    struct Retirement {
        address poolTokenAddress; // Pool token used
        address projectTokenAddress; // Fractionalized ERC-20 address for project/vintage
        address beneficiaryAddress; // Address of the beneficiary
        string beneficiary; // Retirement beneficiary
        string retirementMessage; // Specific message going along with this retirement
        uint256 amount; // Amount of carbon retired
        uint256 pledgeID; // The ID of the pledge this retirement is associated with.
    }

    struct State {
        mapping(uint256 => Retirement) retirements;
        mapping(address => uint256) totalPoolRetired;
        mapping(address => uint256) totalProjectRetired;
        uint256 totalRetirements;
        uint256 totalCarbonRetired;
        uint256 totalRewardsClaimed;
    }
}

contract Storage {
    struct CarbonBridge {
        string name;
        address defaultRouter;
        uint8 routerType;
    }

    struct DefaultSwap {
        uint8[] swapDexes;
        address[] ammRouters;
        mapping(uint8 => address[]) swapPaths;
    }
}

struct AppStorage {
    mapping(uint256 => Storage.CarbonBridge) bridges; // Details for current carbon bridges
    mapping(address => bool) isPoolToken;
    mapping(address => LibRetire.CarbonBridge) poolBridge; // Mapping of pool token address to the carbon bridge
    mapping(address => mapping(address => Storage.DefaultSwap)) swap; // Mapping of pool token to default swap behavior.
    mapping(address => Account.State) a; // Mapping of a user address to account state.
    uint256 lastERC721Received; // Last ERC721 Toucan Retirement Certificate received.
    uint256 fee; // Aggregator fee charged on all retirements to 3 decimals. 1000 = 1%
    uint256 daoFeeShare; // Share of 'fee' for the DAO wallet, per KIP-33. 3 decimals. 1000 = 1%
    uint256 reentrantStatus; // An intra-transaction state variable to protect against reentrance.
    // Internal Balances
    mapping(address => mapping(IERC20 => uint256)) internalTokenBalance; // A mapping from Klimate address to Token address to Internal Balance. It stores the amount of the Token that the Klimate has stored as an Internal Balance in Klima Infinity.
    // Meta tx items
    mapping(address => uint256) metaNonces;
    bytes32 domainSeparator;
    // Swap routing
    mapping(address => mapping(address => address)) tridentPool; // Trident pool to use for getting swap info
}
