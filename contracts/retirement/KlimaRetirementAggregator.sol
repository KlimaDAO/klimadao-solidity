// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/IUniswapV2Router02.sol";
import "../interfaces/IwsKLIMA.sol";
import "../interfaces/IRetireBridgeCommon.sol";
import "../interfaces/IRetireMossCarbon.sol";
import "../interfaces/IRetireToucanCarbon.sol";

/**
 * @title KlimaRetirementAggregator
 * @author KlimaDAO
 *
 * @notice This is the master aggregator contract for the Klima retirement utility.
 *
 * This allows a user to provide a source token and an approved carbon pool token to retire.
 * If the source is different than the pool, it will attempt to swap to that pool then retire.
 */
contract KlimaRetirementAggregator is
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function initialize() public initializer {
        __Ownable_init();
        __Context_init();
    }

    /** === State Variables and Mappings === */
    address public KLIMA;
    address public sKLIMA;
    address public wsKLIMA;
    address public USDC;
    address public staking;
    address public stakingHelper;
    address public treasury;
    address public klimaRetirementStorage;

    mapping(address => bool) public isPoolToken;
    mapping(address => uint256) public poolBridge;
    mapping(uint256 => address) public bridgeHelper;

    /** === Event Setup === */
    event AddressUpdated(
        uint256 addressIndex,
        address indexed oldAddress,
        address indexed newAddress
    );
    event PoolAdded(address poolToken, uint256 bridge);
    event PoolRemoved(address poolToken);
    event BridgeHelperUpdated(uint256 bridgeID, address helper);

    /** === Non Specific Auto Retirements */

    /**
     * @notice This function will retire a carbon pool token that is held
     * in the caller's wallet. Depending on the pool provided the appropriate
     * retirement helper will be used as defined in the bridgeHelper mapping.
     * If a token other than the pool is provided then the helper will attempt
     * to swap to the appropriate pool and then retire.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _beneficiaryAddress Address of the beneficiary of the retirement.
     * @param _beneficiaryString String representing the beneficiary. A name perhaps.
     * @param _retirementMessage Specific message relating to this retirement event.
     */
    function retireCarbon(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage
    ) public {
        require(isPoolToken[_poolToken], "Pool Token Not Accepted.");

        (uint256 sourceAmount, ) = getSourceAmount(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon
        );

        IERC20Upgradeable(_sourceToken).safeTransferFrom(
            _msgSender(),
            address(this),
            sourceAmount
        );

        _retireCarbon(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon,
            _beneficiaryAddress,
            _beneficiaryString,
            _retirementMessage,
            _msgSender()
        );
    }

    /**
     * @notice This function will retire a carbon pool token that has been
     * transferred to this contract. Useful when an intermediary contract has
     * approval to transfer the source tokens from the initiator.
     * Depending on the pool provided the appropriate retirement helper will
     * be used as defined in the bridgeHelper mapping. If a token other than
     * the pool is provided then the helper will attempt to swap to the
     * appropriate pool and then retire.
     *
     * @param _initiator The original sender of the transaction.
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _beneficiaryAddress Address of the beneficiary of the retirement.
     * @param _beneficiaryString String representing the beneficiary. A name perhaps.
     * @param _retirementMessage Specific message relating to this retirement event.
     */
    function retireCarbonFrom(
        address _initiator,
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage
    ) public {
        require(isPoolToken[_poolToken], "Pool Token Not Accepted.");

        _retireCarbon(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon,
            _beneficiaryAddress,
            _beneficiaryString,
            _retirementMessage,
            _initiator
        );
    }

    /**
     * @notice Internal function that checks to make sure the needed source tokens
     * have been transferred to this contract, then calls the retirement function
     * on the bridge's specific helper contract.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _beneficiaryAddress Address of the beneficiary of the retirement.
     * @param _beneficiaryString String representing the beneficiary. A name perhaps.
     * @param _retirementMessage Specific message relating to this retirement event.
     * @param _retiree Address of the initiator where source tokens originated.
     */
    function _retireCarbon(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address _retiree
    ) internal {
        (uint256 sourceAmount, ) = getSourceAmount(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon
        );

        require(
            IERC20Upgradeable(_sourceToken).balanceOf(address(this)) ==
                sourceAmount,
            "Source tokens not transferred."
        );

        IERC20Upgradeable(_sourceToken).safeIncreaseAllowance(
            bridgeHelper[poolBridge[_poolToken]],
            sourceAmount
        );

        if (poolBridge[_poolToken] == 0) {
            IRetireMossCarbon(bridgeHelper[0]).retireMoss(
                _sourceToken,
                _poolToken,
                _amount,
                _amountInCarbon,
                _beneficiaryAddress,
                _beneficiaryString,
                _retirementMessage,
                _retiree
            );
        } else if (poolBridge[_poolToken] == 1) {
            IRetireToucanCarbon(bridgeHelper[1]).retireToucan(
                _sourceToken,
                _poolToken,
                _amount,
                _amountInCarbon,
                _beneficiaryAddress,
                _beneficiaryString,
                _retirementMessage,
                _retiree
            );
        }
    }

    /** === Specific offset selection retirements === */

    /**
     * @notice This function will retire a carbon pool token that is held
     * in the caller's wallet. Depending on the pool provided the appropriate
     * retirement helper will be used as defined in the bridgeHelper mapping.
     * If a token other than the pool is provided then the helper will attempt
     * to swap to the appropriate pool and then retire.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _beneficiaryAddress Address of the beneficiary of the retirement.
     * @param _beneficiaryString String representing the beneficiary. A name perhaps.
     * @param _retirementMessage Specific message relating to this retirement event.
     */
    function retireCarbonSpecific(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address[] memory _carbonList
    ) public {
        //require(isPoolToken[_poolToken], "Pool Token Not Accepted.");

        (uint256 sourceAmount, ) = getSourceAmountSpecific(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon
        );

        IERC20Upgradeable(_sourceToken).safeTransferFrom(
            _msgSender(),
            address(this),
            sourceAmount
        );

        _retireCarbonSpecific(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon,
            _beneficiaryAddress,
            _beneficiaryString,
            _retirementMessage,
            _msgSender(),
            _carbonList
        );
    }

    function retireCarbonSpecificFrom(
        address _initiator,
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address[] memory _carbonList
    ) public {
        address retiree = _initiator;

        _retireCarbonSpecific(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon,
            _beneficiaryAddress,
            _beneficiaryString,
            _retirementMessage,
            retiree,
            _carbonList
        );
    }

    /**
     * @notice Internal function that checks to make sure the needed source tokens
     * have been transferred to this contract, then calls the retirement function
     * on the bridge's specific helper contract.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _beneficiaryAddress Address of the beneficiary of the retirement.
     * @param _beneficiaryString String representing the beneficiary. A name perhaps.
     * @param _retirementMessage Specific message relating to this retirement event.
     * @param _retiree Address of the initiator where source tokens originated.
     */
    function _retireCarbonSpecific(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address _retiree,
        address[] memory _carbonList
    ) internal {
        require(isPoolToken[_poolToken], "Pool Token Not Accepted.");
        // Only Toucan and C3 currently allow specific retirement.
        require(
            poolBridge[_poolToken] == 1 || poolBridge[_poolToken] == 2,
            "Pool does not allow specific."
        );

        _prepareRetireSpecific(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon
        );

        if (poolBridge[_poolToken] == 0) {
            // Reserve for possible future use.
        } else if (poolBridge[_poolToken] == 1) {
            IRetireToucanCarbon(bridgeHelper[1]).retireToucanSpecific(
                _sourceToken,
                _poolToken,
                _amount,
                _amountInCarbon,
                _beneficiaryAddress,
                _beneficiaryString,
                _retirementMessage,
                _retiree,
                _carbonList
            );
        }
    }

    function _prepareRetireSpecific(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon
    ) internal {
        (uint256 sourceAmount, ) = getSourceAmountSpecific(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon
        );

        require(
            IERC20Upgradeable(_sourceToken).balanceOf(address(this)) ==
                sourceAmount,
            "Source tokens not transferred."
        );

        IERC20Upgradeable(_sourceToken).safeIncreaseAllowance(
            bridgeHelper[poolBridge[_poolToken]],
            sourceAmount
        );
    }

    /** === External views and helpful functions === */

    /**
     * @notice This function calls the appropriate helper for a pool token and
     * returns the total amount in source tokens needed to perform the transaction.
     * Any swap slippage buffers and fees are included in the return value.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @return Returns both the source amount and carbon amount as a result of swaps.
     */
    function getSourceAmount(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon
    ) public view returns (uint256, uint256) {
        uint256 sourceAmount;
        uint256 carbonAmount = _amount;

        if (_amountInCarbon) {
            (sourceAmount, ) = IRetireBridgeCommon(
                bridgeHelper[poolBridge[_poolToken]]
            ).getNeededBuyAmount(_sourceToken, _poolToken, _amount, false);
            if (_sourceToken == wsKLIMA) {
                sourceAmount = IwsKLIMA(wsKLIMA).sKLIMATowKLIMA(sourceAmount);
            }
        } else {
            sourceAmount = _amount;

            address poolRouter = IRetireBridgeCommon(
                bridgeHelper[poolBridge[_poolToken]]
            ).poolRouter(_poolToken);

            address[] memory path = IRetireBridgeCommon(
                bridgeHelper[poolBridge[_poolToken]]
            ).getSwapPath(_sourceToken, _poolToken);

            uint256[] memory amountsOut = IUniswapV2Router02(poolRouter)
                .getAmountsOut(_amount, path);

            carbonAmount = amountsOut[path.length - 1];
        }

        return (sourceAmount, carbonAmount);
    }

    /**
     * @notice Same as getSourceAmount, but factors in the redemption fee
     * for specific retirements.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @return Returns both the source amount and carbon amount as a result of swaps.
     */
    function getSourceAmountSpecific(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon
    ) public view returns (uint256, uint256) {
        uint256 sourceAmount;
        uint256 carbonAmount = _amount;

        if (_amountInCarbon) {
            (sourceAmount, ) = IRetireBridgeCommon(
                bridgeHelper[poolBridge[_poolToken]]
            ).getNeededBuyAmount(_sourceToken, _poolToken, _amount, true);
            if (_sourceToken == wsKLIMA) {
                sourceAmount = IwsKLIMA(wsKLIMA).sKLIMATowKLIMA(sourceAmount);
            }
        } else {
            sourceAmount = _amount;

            address poolRouter = IRetireBridgeCommon(
                bridgeHelper[poolBridge[_poolToken]]
            ).poolRouter(_poolToken);

            address[] memory path = IRetireBridgeCommon(
                bridgeHelper[poolBridge[_poolToken]]
            ).getSwapPath(_sourceToken, _poolToken);

            uint256[] memory amountsOut = IUniswapV2Router02(poolRouter)
                .getAmountsOut(_amount, path);

            carbonAmount = amountsOut[path.length - 1];
        }

        return (sourceAmount, carbonAmount);
    }

    /**
     * @notice Allow the contract owner to update Klima protocol addresses
     * resulting from possible migrations.
     * @param _selection Int to indicate which address is being updated.
     * @param _newAddress New address for contract needing to be updated.
     * @return bool
     */
    function setAddress(uint256 _selection, address _newAddress)
        external
        onlyOwner
        returns (bool)
    {
        address oldAddress;
        if (_selection == 0) {
            oldAddress = KLIMA;
            KLIMA = _newAddress; // 0; Set new KLIMA address
        } else if (_selection == 1) {
            oldAddress = sKLIMA;
            sKLIMA = _newAddress; // 1; Set new sKLIMA address
        } else if (_selection == 2) {
            oldAddress = wsKLIMA;
            wsKLIMA = _newAddress; // 2; Set new wsKLIMA address
        } else if (_selection == 3) {
            oldAddress = USDC;
            USDC = _newAddress; // 3; Set new USDC address
        } else if (_selection == 4) {
            oldAddress = staking;
            staking = _newAddress; // 4; Set new staking address
        } else if (_selection == 5) {
            oldAddress = stakingHelper;
            stakingHelper = _newAddress; // 5; Set new stakingHelper address
        } else if (_selection == 6) {
            oldAddress = treasury;
            treasury = _newAddress; // 6; Set new treasury address
        } else if (_selection == 7) {
            oldAddress = klimaRetirementStorage;
            klimaRetirementStorage = _newAddress; // 7; Set new storage address
        } else {
            return false;
        }

        emit AddressUpdated(_selection, oldAddress, _newAddress);

        return true;
    }

    /**
     * @notice Add a new carbon pool to retire with helper contract.
     * @param _poolToken Pool being added.
     * @param _poolBridge Int ID of the bridge used for this token.
     * @return bool
     */
    function addPool(address _poolToken, uint256 _poolBridge)
        external
        onlyOwner
        returns (bool)
    {
        require(!isPoolToken[_poolToken], "Pool already added");
        require(_poolToken != address(0), "Pool cannot be zero address");

        isPoolToken[_poolToken] = true;
        poolBridge[_poolToken] = _poolBridge;

        emit PoolAdded(_poolToken, _poolBridge);
        return true;
    }

    /**
        @notice Remove a carbon pool to retire.
        @param _poolToken Pool being removed.
        @return bool
     */
    function removePool(address _poolToken) external onlyOwner returns (bool) {
        require(isPoolToken[_poolToken], "Pool not added");

        isPoolToken[_poolToken] = false;

        emit PoolRemoved(_poolToken);
        return true;
    }

    /**
        @notice Set the helper contract to be used with a carbon bridge.
        @param _bridgeID Int ID of the bridge.
        @param _helper Helper contract to use with this bridge.
        @return bool
     */
    function setBridgeHelper(uint256 _bridgeID, address _helper)
        external
        onlyOwner
        returns (bool)
    {
        require(_helper != address(0), "Helper cannot be zero address");

        bridgeHelper[_bridgeID] = _helper;

        emit BridgeHelperUpdated(_bridgeID, _helper);
        return true;
    }

    /**
        @notice Allow withdrawal of any tokens sent in error
        @param _token Address of token to transfer
     */
    function feeWithdraw(address _token, address _recipient)
        external
        onlyOwner
        returns (bool)
    {
        IERC20Upgradeable(_token).safeTransfer(
            _recipient,
            IERC20Upgradeable(_token).balanceOf(address(this))
        );

        return true;
    }
}
