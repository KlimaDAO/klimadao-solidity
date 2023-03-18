// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "ozu/proxy/utils/Initializable.sol";
import "ozu/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "ozu/utils/ContextUpgradeable.sol";
import "ozu/access/OwnableUpgradeable.sol";

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/IStakingHelper.sol";
import "./interfaces/IwsKLIMA.sol";
import "./interfaces/IKlimaCarbonRetirements.sol";
import "./interfaces/IKlimaRetirementAggregator.sol";
import "./interfaces/IC3Pool.sol";
import "./interfaces/IC3ProjectToken.sol";
import "./interfaces/ITridentPool.sol";
import "./interfaces/ITridentRouter.sol";
import "./interfaces/IBentoBoxMinimal.sol";

contract RetireC3Carbon is Initializable, ContextUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function initialize() public initializer {
        __Ownable_init();
        __Context_init();
    }

    /** === State Variables and Mappings === */

    /// @notice feeAmount represents the fee to be bonded for KLIMA. 0.1% increments. 10 = 1%

    uint256 public feeAmount;
    address public masterAggregator;
    address public tridentRouter;
    address public bento;
    mapping(address => bool) public isPoolToken;
    mapping(address => address) public poolRouter;
    mapping(address => address) public tridentPool;

    /** === Event Setup === */

    event C3Retired(
        address indexed retiringAddress,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint256 retiredAmount
    );
    event PoolAdded(address indexed carbonPool, address indexed poolRouter, address indexed tridentPool);
    event PoolRemoved(address indexed carbonPool);
    event PoolRouterChanged(address indexed carbonPool, address indexed oldRouter, address indexed newRouter);
    event TridentChanged(
        address indexed oldBento,
        address indexed newBento,
        address indexed oldTrident,
        address newTrident
    );
    event FeeUpdated(uint256 oldFee, uint256 newFee);
    event MasterAggregatorUpdated(address indexed oldAddress, address indexed newAddress);

    /** === Free Redeem and Offset Functions === */

    /**
     * @notice This function transfers source tokens if needed, swaps to the C3
     * pool token, utilizes freeRedeem, then retires the redeemed C3T. Needed source
     * token amount is expected to be held by the caller to use.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _beneficiaryAddress Address of the beneficiary of the retirement.
     * @param _beneficiaryString String representing the beneficiary. A name perhaps.
     * @param _retirementMessage Specific message relating to this retirement event.
     * @param _retiree The original sender of the transaction.
     */
    function retireC3(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address _retiree
    ) public {
        require(isPoolToken[_poolToken], "Not a C3 Carbon Pool");

        // Transfer source tokens

        (uint256 sourceAmount, uint256 totalCarbon, uint256 fee) = _transferSourceTokens(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon,
            false
        );

        // Get the pool tokens

        if (_sourceToken != _poolToken) {
            // Swap the source to get pool
            if (_amountInCarbon) {
                // swapTokensForExactTokens
                _swapForExactCarbon(_sourceToken, _poolToken, totalCarbon, sourceAmount, _retiree);
            } else {
                // swapExactTokensForTokens
                (_amount, fee) = _swapExactForCarbon(_sourceToken, _poolToken, sourceAmount);
            }
        } else if (!_amountInCarbon) {
            // Calculate the fee and adjust if pool token is provided with false bool
            fee = (_amount * feeAmount) / 1000;
            _amount = _amount - fee;
        }

        // At this point _amount = the amount of carbon to retire

        // Retire the tokens
        _retireCarbon(_amount, _beneficiaryAddress, _beneficiaryString, _retirementMessage, _poolToken);

        // Send the fee to the treasury
        if (feeAmount > 0) {
            IERC20Upgradeable(_poolToken).safeTransfer(
                IKlimaRetirementAggregator(masterAggregator).treasury(),
                IERC20Upgradeable(_poolToken).balanceOf(address(this))
            );
        }
    }

    /**
     * @notice Redeems the pool and retires the C3T tokens on Polygon.
     *  Emits a retirement event and updates the KlimaCarbonRetirements contract with
     *  retirement details and amounts.
     * @param _totalAmount Total pool tokens being retired. Expected uint with 18 decimals.
     * @param _beneficiaryAddress Address of the beneficiary if different than sender. Value is set to _msgSender() if null is sent.
     * @param _beneficiaryString String that can be used to describe the beneficiary
     * @param _retirementMessage String for specific retirement message if needed.
     * @param _poolToken Address of pool token being used to retire.
     */
    function _retireCarbon(
        uint256 _totalAmount,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address _poolToken
    ) internal {
        // Assign default event values
        if (_beneficiaryAddress == address(0)) {
            _beneficiaryAddress = _msgSender();
        }

        address retirementStorage = IKlimaRetirementAggregator(masterAggregator).klimaRetirementStorage();

        address[] memory listC3T = IC3Pool(_poolToken).getFreeRedeemAddresses();

        // Redeem pool tokens
        IC3Pool(_poolToken).freeRedeem(_totalAmount);

        // Retire C3T
        for (uint256 i = 0; i < listC3T.length && _totalAmount > 0; i++) {
            // Get redeemed balance of free token addresses
            uint256 balance = IERC20Upgradeable(listC3T[i]).balanceOf(address(this));

            // Skip over any C3Ts returned that were not actually redeemed.
            if (balance == 0) {
                continue;
            }

            IC3ProjectToken(listC3T[i]).offsetFor(balance, _beneficiaryAddress, _beneficiaryString, _retirementMessage);
            IKlimaCarbonRetirements(retirementStorage).carbonRetired(
                _beneficiaryAddress,
                _poolToken,
                balance,
                _beneficiaryString,
                _retirementMessage
            );
            emit C3Retired(
                msg.sender,
                _beneficiaryAddress,
                _beneficiaryString,
                _retirementMessage,
                _poolToken,
                listC3T[i],
                balance
            );

            _totalAmount -= balance;
        }

        require(_totalAmount == 0, "Total Retired != To Desired");
    }

    /** === Taxed Redeem and Offset Functions === */

    /**
     * @notice This function transfers source tokens if needed, swaps to the C3
     * pool token, utilizes taxedRedeem, then retires the redeemed C3T. Needed source
     * token amount is expected to be held by the caller to use.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _beneficiaryAddress Address of the beneficiary of the retirement.
     * @param _beneficiaryString String representing the beneficiary. A name perhaps.
     * @param _retirementMessage Specific message relating to this retirement event.
     * @param _retiree The original sender of the transaction.
     * @param _carbonList List of C3Ts to redeem
     */
    function retireC3Specific(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address _retiree,
        address[] memory _carbonList
    ) public {
        require(isPoolToken[_poolToken], "Not a C3 Carbon Pool");

        // Transfer source tokens
        // After swapping _amount = the amount of carbon to retire

        uint256 fee;
        (_amount, fee) = _prepareRetireSpecific(_sourceToken, _poolToken, _amount, _amountInCarbon, _retiree);

        // Retire the tokens
        _retireCarbonSpecific(
            _amount,
            _beneficiaryAddress,
            _beneficiaryString,
            _retirementMessage,
            _poolToken,
            _carbonList
        );

        // Send the fee to the treasury
        if (feeAmount > 0) {
            IERC20Upgradeable(_poolToken).safeTransfer(
                IKlimaRetirementAggregator(masterAggregator).treasury(),
                IERC20Upgradeable(_poolToken).balanceOf(address(this))
            );
        }
    }

    /**
     * @notice This function is mainly used to avoid stack too deep. It performs the
     * initial transfer and swap to the pool token for a specific retirement.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _retiree The original sender of the transaction. To return trade dust.
     * @return (uint256, uint256) tuple for the amount to pass to redeem and retire,
     * and the aggregator fee.
     */
    function _prepareRetireSpecific(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _retiree
    ) internal returns (uint256, uint256) {
        (uint256 sourceAmount, uint256 totalCarbon, uint256 fee) = _transferSourceTokens(
            _sourceToken,
            _poolToken,
            _amount,
            _amountInCarbon,
            true
        );

        // Get the pool tokens

        if (_sourceToken != _poolToken) {
            // Swap the source to get pool
            if (_amountInCarbon) {
                // Add redemption fee to the total to redeem.
                totalCarbon += _getSpecificCarbonFee(_poolToken, _amount, _amountInCarbon);

                // swapTokensForExactTokens
                _swapForExactCarbon(_sourceToken, _poolToken, totalCarbon, sourceAmount, _retiree);
            } else {
                // swapExactTokensForTokens
                (_amount, fee) = _swapExactForCarbon(_sourceToken, _poolToken, sourceAmount);
            }
        }

        if (!_amountInCarbon) {
            // Calculate the fee and adjust if pool token is provided with false bool
            fee = (_amount * feeAmount) / 1000;
            _amount -= fee;
            _amount -= _getSpecificCarbonFee(_poolToken, _amount, _amountInCarbon);
        }

        return (_amount, fee);
    }

    /**
     * @notice Redeems the pool and retires the C3T tokens on Polygon.
     *  Emits a retirement event and updates the KlimaCarbonRetirements contract with
     *  retirement details and amounts.
     * @param _totalAmount Total pool tokens being retired. Expected uint with 18 decimals.
     * @param _beneficiaryAddress Address of the beneficiary if different than sender. Value is set to _msgSender() if null is sent.
     * @param _beneficiaryString String that can be used to describe the beneficiary
     * @param _retirementMessage String for specific retirement message if needed.
     * @param _poolToken Address of pool token being used to retire.
     * @param _carbonList List of C3T tokens to redeem
     */
    function _retireCarbonSpecific(
        uint256 _totalAmount,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address _poolToken,
        address[] memory _carbonList
    ) internal {
        // Assign default event values
        if (_beneficiaryAddress == address(0)) {
            _beneficiaryAddress = _msgSender();
        }

        address retirementStorage = IKlimaRetirementAggregator(masterAggregator).klimaRetirementStorage();

        // Redeem the pool tokens using the list provided.

        for (uint256 i = 0; i < _carbonList.length && _totalAmount > 0; i++) {
            // Get the pools balance of TCO2
            uint256 poolBalance = IERC20Upgradeable(_carbonList[i]).balanceOf(_poolToken);

            // Error check for possible 0 balance / stale lists
            if (poolBalance != 0) {
                address[] memory redeemERC20 = new address[](1);
                redeemERC20[0] = _carbonList[i];

                uint256[] memory redeemAmount = new uint256[](1);

                // Burn only pool balance if there are more pool tokens than available
                if (_totalAmount > poolBalance) {
                    redeemAmount[0] = poolBalance;
                } else {
                    redeemAmount[0] = _totalAmount;
                }

                // Redeem from pool
                IC3Pool(_poolToken).taxedRedeem(redeemERC20, redeemAmount);
                _totalAmount -= redeemAmount[0];

                // Retire C3T - Update balance to account for possible fee.
                redeemAmount[0] = IERC20Upgradeable(_carbonList[i]).balanceOf(address(this));

                IC3ProjectToken(_carbonList[i]).offsetFor(
                    redeemAmount[0],
                    _beneficiaryAddress,
                    _beneficiaryString,
                    _retirementMessage
                );
                IKlimaCarbonRetirements(retirementStorage).carbonRetired(
                    _beneficiaryAddress,
                    _poolToken,
                    redeemAmount[0],
                    _beneficiaryString,
                    _retirementMessage
                );
                emit C3Retired(
                    msg.sender,
                    _beneficiaryAddress,
                    _beneficiaryString,
                    _retirementMessage,
                    _poolToken,
                    _carbonList[i],
                    redeemAmount[0]
                );
            }
        }

        require(_totalAmount == 0, "Not all pool tokens were burned.");
    }

    /** === Internal helper functions === */

    /**
     * @notice Transfers the needed source tokens from the caller to perform any needed
     * swaps and then retire the tokens.
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     */
    function _transferSourceTokens(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        bool _specificRetire
    ) internal returns (uint256, uint256, uint256) {
        address sKLIMA = IKlimaRetirementAggregator(masterAggregator).sKLIMA();
        address wsKLIMA = IKlimaRetirementAggregator(masterAggregator).wsKLIMA();

        uint256 fee;
        uint256 sourceAmount;

        // If submitting the amount in carbon, add fee to transfer amount.
        if (_amountInCarbon) {
            (sourceAmount, fee) = getNeededBuyAmount(_sourceToken, _poolToken, _amount, _specificRetire);
        } else {
            sourceAmount = _amount;
        }

        if (_sourceToken == sKLIMA || _sourceToken == wsKLIMA) {
            sourceAmount = _stakedToUnstaked(_sourceToken, sourceAmount);
        } else {
            IERC20Upgradeable(_sourceToken).safeTransferFrom(_msgSender(), address(this), sourceAmount);
        }

        return (sourceAmount, _amount + fee, fee);
    }

    /**
     * @notice Unwraps/unstakes any KLIMA needed to regular KLIMA.
     * @param _klimaType Address of the KLIMA type being used.
     * @param _amountIn Amount of total KLIMA needed.
     * @return Returns the total number of KLIMA after unwrapping/unstaking.
     */
    function _stakedToUnstaked(address _klimaType, uint256 _amountIn) internal returns (uint256) {
        uint256 unwrappedKLIMA = _amountIn;

        // Get token addresses from master
        address sKLIMA = IKlimaRetirementAggregator(masterAggregator).sKLIMA();
        address wsKLIMA = IKlimaRetirementAggregator(masterAggregator).wsKLIMA();
        address staking = IKlimaRetirementAggregator(masterAggregator).staking();

        if (_klimaType == wsKLIMA) {
            // Get wsKLIMA needed, transfer and unwrap, unstake to KLIMA
            uint256 wsKLIMANeeded = IwsKLIMA(wsKLIMA).sKLIMATowKLIMA(_amountIn);

            IERC20Upgradeable(wsKLIMA).safeTransferFrom(_msgSender(), address(this), wsKLIMANeeded);
            IERC20Upgradeable(wsKLIMA).safeIncreaseAllowance(wsKLIMA, wsKLIMANeeded);
            unwrappedKLIMA = IwsKLIMA(wsKLIMA).unwrap(wsKLIMANeeded);
        }

        // If using sKLIMA, transfer in and unstake
        if (_klimaType == sKLIMA) {
            IERC20Upgradeable(sKLIMA).safeTransferFrom(_msgSender(), address(this), unwrappedKLIMA);
        }
        IERC20Upgradeable(sKLIMA).safeIncreaseAllowance(staking, unwrappedKLIMA);
        IStaking(staking).unstake(unwrappedKLIMA, false);

        return unwrappedKLIMA;
    }

    /**
     * @notice Swaps the source token for an exact number of carbon tokens, and
     * returns any dust to the initiator.
     *
     * @dev This is only called if the _amountInCarbon bool is set to true.
     *
     * @param _sourceToken Address of token being used to purchase the pool token.
     * @param _poolToken Address of pool token being used.
     * @param _carbonAmount Total carbon needed.
     * @param _amountIn Maximum amount of source tokens.
     * @param _retiree Initiator of the retirement to return any dust.
     */
    function _swapForExactCarbon(
        address _sourceToken,
        address _poolToken,
        uint256 _carbonAmount,
        uint256 _amountIn,
        address _retiree
    ) internal {
        address KLIMA = IKlimaRetirementAggregator(masterAggregator).KLIMA();
        address sKLIMA = IKlimaRetirementAggregator(masterAggregator).sKLIMA();
        address wsKLIMA = IKlimaRetirementAggregator(masterAggregator).wsKLIMA();

        uint256 klimaAmount = _amountIn;

        if (_sourceToken != KLIMA && _sourceToken != sKLIMA && _sourceToken != wsKLIMA) {
            bytes memory tridentInfo = abi.encode(_poolToken, _carbonAmount);
            klimaAmount = ITridentPool(tridentPool[_poolToken]).getAmountIn(tridentInfo);

            address[] memory path = getSwapPath(_sourceToken, _poolToken);

            IERC20Upgradeable(path[0]).safeIncreaseAllowance(poolRouter[_poolToken], _amountIn);

            uint256[] memory amounts = IUniswapV2Router02(poolRouter[_poolToken]).swapTokensForExactTokens(
                klimaAmount,
                _amountIn,
                path,
                address(this),
                block.timestamp
            );

            _returnTradeDust(amounts, _sourceToken, _amountIn, _retiree);
        }

        ITridentRouter.ExactInputSingleParams memory swapParams;
        swapParams.amountIn = klimaAmount;
        swapParams.amountOutMinimum = _carbonAmount;
        swapParams.pool = tridentPool[_poolToken];
        swapParams.tokenIn = KLIMA;
        swapParams.data = abi.encode(KLIMA, address(this), true);

        IERC20Upgradeable(KLIMA).safeIncreaseAllowance(bento, klimaAmount);

        ITridentRouter(tridentRouter).exactInputSingleWithNativeToken(swapParams);
    }

    /**
     * @notice Swaps an exact number of source tokens for carbon tokens.
     *
     * @dev This is only called if the _amountInCarbon bool is set to false.
     *
     * @param _sourceToken Address of token being used to purchase the pool token.
     * @param _poolToken Address of pool token being used.
     * @param _amountIn Total source tokens to swap.
     * @return Returns the resulting carbon amount to retire and the fee from the
     * results of the swap.
     */
    function _swapExactForCarbon(
        address _sourceToken,
        address _poolToken,
        uint256 _amountIn
    ) internal returns (uint256, uint256) {
        address KLIMA = IKlimaRetirementAggregator(masterAggregator).KLIMA();
        address sKLIMA = IKlimaRetirementAggregator(masterAggregator).sKLIMA();
        address wsKLIMA = IKlimaRetirementAggregator(masterAggregator).wsKLIMA();

        uint256 klimaAmount;
        uint256 totalCarbon;

        // Swap source to KLIMA if needed.
        if (_sourceToken != KLIMA && _sourceToken != sKLIMA && _sourceToken != wsKLIMA) {
            address[] memory path = getSwapPath(_sourceToken, _poolToken);

            uint256[] memory amountsOut = IUniswapV2Router02(poolRouter[_poolToken]).getAmountsOut(_amountIn, path);

            klimaAmount = amountsOut[path.length - 1];

            IERC20Upgradeable(_sourceToken).safeIncreaseAllowance(poolRouter[_poolToken], _amountIn);

            uint256[] memory amounts = IUniswapV2Router02(poolRouter[_poolToken]).swapExactTokensForTokens(
                _amountIn,
                (klimaAmount * 995) / 1000,
                path,
                address(this),
                block.timestamp
            );

            klimaAmount = amounts[amounts.length - 1] == 0 ? amounts[amounts.length - 2] : amounts[amounts.length - 1];
        } else {
            klimaAmount = _amountIn;
        }

        // Swap KLIMA for Pool on Trident
        bytes memory tridentInfo = abi.encode(_poolToken, klimaAmount);
        totalCarbon = ITridentPool(tridentPool[_poolToken]).getAmountOut(tridentInfo);

        ITridentRouter.ExactInputSingleParams memory swapParams;
        swapParams.amountIn = klimaAmount;
        swapParams.amountOutMinimum = totalCarbon;
        swapParams.pool = tridentPool[_poolToken];
        swapParams.tokenIn = KLIMA;
        swapParams.data = abi.encode(KLIMA, address(this), true);

        IERC20Upgradeable(KLIMA).safeIncreaseAllowance(bento, klimaAmount);

        totalCarbon = ITridentRouter(tridentRouter).exactInputSingleWithNativeToken(swapParams);

        uint256 fee = (totalCarbon * feeAmount) / 1000;

        return (totalCarbon - fee, fee);
    }

    /**
     * @notice Returns any trade dust to the designated address. If sKLIMA or
     * wsKLIMA was provided as a source token, it is re-staked and/or wrapped
     * before transferring back.
     *
     * @param _amounts The amounts resulting from the Uniswap tradeTokensForExactTokens.
     * @param _sourceToken Address of token being used to purchase the pool token.
     * @param _amountIn Total source tokens initially provided.
     * @param _retiree Address where to send the dust.
     */
    function _returnTradeDust(
        uint256[] memory _amounts,
        address _sourceToken,
        uint256 _amountIn,
        address _retiree
    ) internal {
        address KLIMA = IKlimaRetirementAggregator(masterAggregator).KLIMA();
        address sKLIMA = IKlimaRetirementAggregator(masterAggregator).sKLIMA();
        address wsKLIMA = IKlimaRetirementAggregator(masterAggregator).wsKLIMA();
        address stakingHelper = IKlimaRetirementAggregator(masterAggregator).stakingHelper();

        uint256 tradeDust = _amountIn - (_amounts[0] == 0 ? _amounts[1] : _amounts[0]);

        if (_sourceToken == sKLIMA || _sourceToken == wsKLIMA) {
            IERC20Upgradeable(KLIMA).safeIncreaseAllowance(stakingHelper, tradeDust);

            IStakingHelper(stakingHelper).stake(tradeDust);

            if (_sourceToken == sKLIMA) {
                IERC20Upgradeable(sKLIMA).safeTransfer(_retiree, tradeDust);
            } else if (_sourceToken == wsKLIMA) {
                IERC20Upgradeable(sKLIMA).safeIncreaseAllowance(wsKLIMA, tradeDust);
                uint256 wrappedDust = IwsKLIMA(wsKLIMA).wrap(tradeDust);
                IERC20Upgradeable(wsKLIMA).safeTransfer(_retiree, wrappedDust);
            }
        } else {
            IERC20Upgradeable(_sourceToken).safeTransfer(_retiree, tradeDust);
        }
    }

    /**
     * @notice Gets the fee amount for a carbon pool and returns the value.
     * @param _poolToken Address of pool token being used.
     * @param _poolAmount Amount of tokens being retired.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @return poolFeeAmount Fee amount for specificly redeeming a ton.
     */
    function _getSpecificCarbonFee(
        address _poolToken,
        uint256 _poolAmount,
        bool _amountInCarbon
    ) internal view returns (uint256) {
        uint256 poolFeeAmount;
        uint256 feeRedeem = IC3Pool(_poolToken).feeRedeem();
        uint256 feeDivider = 10000; // This is hardcoded in current C3 contract.

        if (_amountInCarbon) {
            poolFeeAmount = ((_poolAmount * feeDivider) / (feeDivider - feeRedeem)) - _poolAmount;
        } else {
            poolFeeAmount = _poolAmount - ((_poolAmount * feeDivider) / (feeDivider + feeRedeem));
        }
        return poolFeeAmount;
    }

    /** === External views and helpful functions === */

    /**
     * @notice Call the UniswapV2 routers for needed amounts on token being retired.
     * Also calculates and returns any fee needed in the pool token total.
     * @param _sourceToken Address of token being used to purchase the pool token.
     * @param _poolToken Address of pool token being used.
     * @param _poolAmount Amount of tokens being retired.
     * @return Tuple of the total pool amount needed, followed by the fee.
     */
    function getNeededBuyAmount(
        address _sourceToken,
        address _poolToken,
        uint256 _poolAmount,
        bool _specificRetire
    ) public view returns (uint256, uint256) {
        address KLIMA = IKlimaRetirementAggregator(masterAggregator).KLIMA();
        address sKLIMA = IKlimaRetirementAggregator(masterAggregator).sKLIMA();
        address wsKLIMA = IKlimaRetirementAggregator(masterAggregator).wsKLIMA();

        uint256 fee = (_poolAmount * feeAmount) / 1000;
        uint256 totalAmount = _poolAmount + fee;

        if (_specificRetire) {
            totalAmount = totalAmount + _getSpecificCarbonFee(_poolToken, _poolAmount, true);
        }

        if (_sourceToken != _poolToken) {
            bytes memory tridentInfo = abi.encode(_poolToken, totalAmount);
            uint256 klimaAmount = ITridentPool(tridentPool[_poolToken]).getAmountIn(tridentInfo);

            totalAmount = klimaAmount;

            if (_sourceToken != KLIMA && _sourceToken != sKLIMA && _sourceToken != wsKLIMA) {
                address[] memory path = getSwapPath(_sourceToken, _poolToken);

                uint256[] memory amountIn = IUniswapV2Router02(poolRouter[_poolToken]).getAmountsIn(klimaAmount, path);

                totalAmount = amountIn[0];
            } else if (_sourceToken == wsKLIMA) {
                totalAmount += 5; //account for any wsKLIMA rounding issues shorting amount needed for swap.
            }
        }

        return (totalAmount, fee);
    }

    /**
     * @notice This creates the path for UniswapV2 to get to KLIMA. A secondary
     * swap will be performed in Trident to get the pool token.
     *
     * @dev This function will produce an invalid path if the source token
     * does not have a direct USDC LP route on the pool's AMM. The resulting
     * transaction would revert.
     *
     * @param _sourceToken Address of token being used to purchase the pool token.
     * @param _poolToken Address of pool token being used.
     * @return Array of addresses to be used as the path for the swap.
     */
    function getSwapPath(address _sourceToken, address _poolToken) public view returns (address[] memory) {
        address[] memory path;

        // Get addresses from master.
        address KLIMA = IKlimaRetirementAggregator(masterAggregator).KLIMA();
        address USDC = IKlimaRetirementAggregator(masterAggregator).USDC();

        // Since this is the UniswapV2 path, end with KLIMA to use with Trident.
        _poolToken = KLIMA;

        // If the source is KLIMA or USDC do a direct swap, else route through USDC.
        if (_sourceToken == USDC) {
            path = new address[](2);
            path[0] = _sourceToken;
            path[1] = _poolToken;
        } else {
            path = new address[](3);
            path[0] = _sourceToken;
            path[1] = USDC;
            path[2] = _poolToken;
        }

        return path;
    }

    /** === Admin Functions === */

    /**
        @notice Set the fee for the helper
        @param _amount New fee amount, in .1% increments. 10 = 1%
        @return bool
     */
    function setFeeAmount(uint256 _amount) external onlyOwner returns (bool) {
        uint256 oldFee = feeAmount;
        feeAmount = _amount;

        emit FeeUpdated(oldFee, feeAmount);
        return true;
    }

    /**
        @notice Update the router for an existing pool
        @param _poolToken Pool being updated
        @param _router New router address
        @return bool
     */
    function setPoolRouter(address _poolToken, address _router) external onlyOwner returns (bool) {
        require(isPoolToken[_poolToken], "Pool not added");

        address oldRouter = poolRouter[_poolToken];
        poolRouter[_poolToken] = _router;

        emit PoolRouterChanged(_poolToken, oldRouter, poolRouter[_poolToken]);
        return true;
    }

    /**
        @notice Add a new carbon pool to retire with helper contract
        @param _poolToken Pool being added
        @param _router UniswapV2 router to route trades through for non-pool retirements
        @return bool
     */
    function addPool(address _poolToken, address _router, address _tridentPool) external onlyOwner returns (bool) {
        require(!isPoolToken[_poolToken], "Pool already added");
        require(_poolToken != address(0), "Pool cannot be zero address");

        isPoolToken[_poolToken] = true;
        poolRouter[_poolToken] = _router;
        tridentPool[_poolToken] = _tridentPool;

        emit PoolAdded(_poolToken, _router, _tridentPool);
        return true;
    }

    /**
        @notice Remove a carbon pool to retire with helper contract
        @param _poolToken Pool being removed
        @return bool
     */
    function removePool(address _poolToken) external onlyOwner returns (bool) {
        require(isPoolToken[_poolToken], "Pool not added");

        isPoolToken[_poolToken] = false;

        emit PoolRemoved(_poolToken);
        return true;
    }

    /**
        @notice Allow withdrawal of any tokens sent in error
        @param _token Address of token to transfer
        @param _recipient Address where to send tokens.
     */
    function feeWithdraw(address _token, address _recipient) public onlyOwner returns (bool) {
        IERC20Upgradeable(_token).safeTransfer(_recipient, IERC20Upgradeable(_token).balanceOf(address(this)));

        return true;
    }

    /**
        @notice Allow the contract owner to update the master aggregator proxy address used.
        @param _newAddress New address for contract needing to be updated.
        @return bool
     */
    function setMasterAggregator(address _newAddress) external onlyOwner returns (bool) {
        address oldAddress = masterAggregator;
        masterAggregator = _newAddress;

        emit MasterAggregatorUpdated(oldAddress, _newAddress);

        return true;
    }

    /**
     * @notice Allow the contract owner to update the SushiSwap Trident AMM addresses.
     * @param _tridentRouter New address for Trident router.
     * @param _bento New address for Bento Box.
     */
    function setTrident(address _tridentRouter, address _bento) external onlyOwner {
        address oldTrident = tridentRouter;
        tridentRouter = _tridentRouter;

        address oldBento = bento;
        bento = _bento;

        IBentoBoxMinimal(bento).setMasterContractApproval(address(this), tridentRouter, true, 0, 0, 0);

        emit TridentChanged(oldBento, _bento, oldTrident, _tridentRouter);
    }
}
