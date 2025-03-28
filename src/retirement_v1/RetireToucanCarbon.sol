// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "ozu/proxy/utils/Initializable.sol";
import "ozu/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "ozu/utils/ContextUpgradeable.sol";
import "ozu/access/OwnableUpgradeable.sol";
import "ozu/token/ERC721/IERC721Upgradeable.sol";
import "ozu/token/ERC721/IERC721ReceiverUpgradeable.sol";

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/IStakingHelper.sol";
import "./interfaces/IwsKLIMA.sol";
import "./interfaces/IKlimaCarbonRetirements.sol";
import "./interfaces/IToucanContractRegistry.sol";
import "./interfaces/IToucanPool.sol";
import "./interfaces/IToucanCarbonOffsets.sol";
import "./interfaces/IKlimaRetirementAggregator.sol";

contract RetireToucanCarbon is Initializable, ContextUpgradeable, OwnableUpgradeable, IERC721ReceiverUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function initialize() public initializer {
        __Ownable_init();
        __Context_init();
    }

    /**
     * === State Variables and Mappings ===
     */

    /// @notice feeAmount represents the fee to be bonded for KLIMA. 0.1% increments. 10 = 1%

    uint256 public feeAmount;
    address public masterAggregator;
    mapping(address => bool) public isPoolToken;
    mapping(address => address) public poolRouter;
    address public toucanRegistry;
    uint256 public lastTokenId;

    /**
     * === Event Setup ===
     */
    event ToucanRetired(
        address indexed retiringAddress,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint256 retiredAmount
    );
    event PoolAdded(address indexed carbonPool, address indexed poolRouter);
    event PoolRemoved(address indexed carbonPool);
    event PoolRouterChanged(address indexed carbonPool, address indexed oldRouter, address indexed newRouter);
    event FeeUpdated(uint256 oldFee, uint256 newFee);
    event MasterAggregatorUpdated(address indexed oldAddress, address indexed newAddress);
    event RegistryUpdated(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice This function transfers source tokens if needed, swaps to the Toucan
     * pool token, utilizes redeemAuto, then retires the redeemed TCO2. Needed source
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
    function retireToucan(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        string memory _retireEntityString,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address _retiree
    ) public {
        require(isPoolToken[_poolToken], "Not a Toucan Carbon Token");

        uint256 fee;
        (_amount, fee) = _prepareRetire(_sourceToken, _poolToken, _amount, _amountInCarbon, _retiree);

        // At this point _amount = the amount of carbon to retire

        // Retire the tokens
        _retireCarbon(
            _amount, _retireEntityString, _beneficiaryAddress, _beneficiaryString, _retirementMessage, _poolToken
        );

        // Send the fee to the treasury
        if (feeAmount > 0) {
            IERC20Upgradeable(_poolToken).safeTransfer(IKlimaRetirementAggregator(masterAggregator).treasury(), fee);
        }
    }

    /**
     * @notice This function transfers source tokens if needed, swaps to the Toucan
     * pool token and the returns the resulting values to be retired.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _retiree The original sender of the transaction.
     */
    function _prepareRetire(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _retiree
    ) internal returns (uint256, uint256) {
        // Transfer source tokens
        (uint256 sourceAmount, uint256 totalCarbon, uint256 fee) =
            _transferSourceTokens(_sourceToken, _poolToken, _amount, _amountInCarbon, false);

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
        return (_amount, fee);
    }

    /**
     * @notice This function transfers source tokens if needed, swaps to the Toucan
     * pool token, utilizes redeemMany, then retires the redeemed TCO2. Needed source
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
     * @param _carbonList List of TCO2s to redeem
     */
    function retireToucanSpecific(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        string memory _retireEntityString,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address _retiree,
        address[] memory _carbonList
    ) public {
        require(isPoolToken[_poolToken], "Not a Toucan Carbon Token");

        // Transfer source tokens
        // After swapping _amount = the amount of carbon to retire

        uint256 fee;
        (_amount, fee) = _prepareRetireSpecific(_sourceToken, _poolToken, _amount, _amountInCarbon, _retiree);

        // Retire the tokens
        _retireCarbonSpecific(
            _amount,
            _retireEntityString,
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
     * @notice This function transfers source tokens if needed, swaps to the Toucan
     * pool token and the returns the resulting values to be retired.
     *
     * @param _sourceToken The contract address of the token being supplied.
     * @param _poolToken The contract address of the pool token being retired.
     * @param _amount The amount being supplied. Expressed in either the total
     *          carbon to offset or the total source to spend. See _amountInCarbon.
     * @param _amountInCarbon Bool indicating if _amount is in carbon or source.
     * @param _retiree The original sender of the transaction.
     */
    function _prepareRetireSpecific(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _retiree
    ) internal returns (uint256, uint256) {
        (uint256 sourceAmount, uint256 totalCarbon, uint256 fee) =
            _transferSourceTokens(_sourceToken, _poolToken, _amount, _amountInCarbon, true);

        // Get the pool tokens

        if (_sourceToken != _poolToken) {
            // Swap the source to get pool
            if (_amountInCarbon) {
                // Add redemption fee to the total to redeem.
                totalCarbon += _getSpecificCarbonFee(_poolToken, _amount);
                _amount += _getSpecificCarbonFee(_poolToken, _amount);

                // swapTokensForExactTokens
                _swapForExactCarbon(_sourceToken, _poolToken, totalCarbon, sourceAmount, _retiree);
            } else {
                // swapExactTokensForTokens
                (_amount, fee) = _swapExactForCarbon(_sourceToken, _poolToken, sourceAmount);
            }
        } else {
            _amount = sourceAmount - fee;
        }

        if (!_amountInCarbon) {
            // Calculate the fee and adjust if pool token is provided with false bool
            fee = (_amount * feeAmount) / 1000;
            _amount = totalCarbon - fee;
        }

        return (_amount, fee);
    }

    /**
     * @notice Redeems the pool and retires the TCO2 tokens on Polygon.
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
        string memory _retireEntityString,
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

        // Redeem pool tokens
        (address[] memory listTCO2, uint256[] memory amounts) = IToucanPool(_poolToken).redeemAuto2(_totalAmount);

        // Retire TCO2
        for (uint256 i = 0; i < listTCO2.length; i++) {
            // Skip over any TCO2s returned that were not actually redeemed.
            if (IERC20Upgradeable(listTCO2[i]).balanceOf(address(this)) == 0) {
                continue;
            }

            //IToucanCarbonOffsets(listTCO2[i]).retire(amounts[i]);
            IToucanCarbonOffsets(listTCO2[i]).retireAndMintCertificate(
                _retireEntityString, _beneficiaryAddress, _beneficiaryString, _retirementMessage, amounts[i]
            );

            // Send the Certificate
            _sendRetireCert(_beneficiaryAddress);

            // Save retirement in Klima storage
            IKlimaCarbonRetirements(retirementStorage).carbonRetired(
                _beneficiaryAddress, _poolToken, amounts[i], _beneficiaryString, _retirementMessage
            );
            emit ToucanRetired(
                msg.sender,
                _beneficiaryAddress,
                _beneficiaryString,
                _retirementMessage,
                _poolToken,
                listTCO2[i],
                amounts[i]
            );

            _totalAmount -= amounts[i];
        }

        require(_totalAmount == 0, "Total Retired != To Desired");
    }

    /**
     * @notice Redeems the pool and retires the TCO2 tokens on Polygon.
     *  Emits a retirement event and updates the KlimaCarbonRetirements contract with
     *  retirement details and amounts.
     * @param _totalAmount Total pool tokens being retired. Expected uint with 18 decimals.
     * @param _beneficiaryAddress Address of the beneficiary if different than sender. Value is set to _msgSender() if null is sent.
     * @param _beneficiaryString String that can be used to describe the beneficiary
     * @param _retirementMessage String for specific retirement message if needed.
     * @param _poolToken Address of pool token being used to retire.
     * @param _carbonList List of TCO2 tokens to redeem
     */
    function _retireCarbonSpecific(
        uint256 _totalAmount,
        string memory _retireEntityString,
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
                IToucanPool(_poolToken).redeemMany(redeemERC20, redeemAmount);
                _totalAmount -= redeemAmount[0];

                // Retire TCO2 - Update balance to account for possible fee.
                redeemAmount[0] = IERC20Upgradeable(_carbonList[i]).balanceOf(address(this));

                //IToucanCarbonOffsets(_carbonList[i]).retire(redeemAmount[0]);
                IToucanCarbonOffsets(_carbonList[i]).retireAndMintCertificate(
                    _retireEntityString, _beneficiaryAddress, _beneficiaryString, _retirementMessage, redeemAmount[0]
                );

                // Send the Certificate
                _sendRetireCert(_beneficiaryAddress);

                // Save retirement in Klima storage
                IKlimaCarbonRetirements(retirementStorage).carbonRetired(
                    _beneficiaryAddress, _poolToken, redeemAmount[0], _beneficiaryString, _retirementMessage
                );
                emit ToucanRetired(
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
     * @notice Call the UniswapV2 routers for needed amounts on token being retired.
     * Also calculates and returns any fee needed in the pool token total.
     * @param _sourceToken Address of token being used to purchase the pool token.
     * @param _poolToken Address of pool token being used.
     * @param _poolAmount Amount of tokens being retired.
     * @return Tuple of the total pool amount needed, followed by the fee.
     */
    function getNeededBuyAmount(address _sourceToken, address _poolToken, uint256 _poolAmount, bool _specificRetire)
        public
        view
        returns (uint256, uint256)
    {
        uint256 fee = (_poolAmount * feeAmount) / 1000;
        uint256 totalAmount = _poolAmount + fee;

        if (_specificRetire) {
            totalAmount = totalAmount + _getSpecificCarbonFee(_poolToken, _poolAmount);
        }

        if (_sourceToken != _poolToken) {
            address[] memory path = getSwapPath(_sourceToken, _poolToken);

            uint256[] memory amountIn = IUniswapV2Router02(poolRouter[_poolToken]).getAmountsIn(totalAmount, path);

            // Account for .1% default AMM slippage.
            totalAmount = (amountIn[0] * 1001) / 1000;
        }

        return (totalAmount, fee);
    }

    function _getSpecificCarbonFee(address _poolToken, uint256 _poolAmount) internal view returns (uint256) {
        uint256 poolFeeAmount;
        bool feeExempt;

        try IToucanPool(_poolToken).redeemFeeExemptedAddresses(address(this)) returns (bool result) {
            feeExempt = result;
        } catch {
            feeExempt = false;
        }

        if (feeExempt) {
            poolFeeAmount = 0;
        } else {
            uint256 feeRedeemBp = IToucanPool(_poolToken).feeRedeemPercentageInBase();
            uint256 feeRedeemDivider = IToucanPool(_poolToken).feeRedeemDivider();
            poolFeeAmount = ((_poolAmount * feeRedeemDivider) / (feeRedeemDivider - feeRedeemBp)) - _poolAmount;
        }

        return poolFeeAmount;
    }

    /**
     * @notice Creates an array of addresses to use in performing any needed
     * swaps to receive the pool token from the source token.
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
        address sKLIMA = IKlimaRetirementAggregator(masterAggregator).sKLIMA();
        address wsKLIMA = IKlimaRetirementAggregator(masterAggregator).wsKLIMA();
        address USDC = IKlimaRetirementAggregator(masterAggregator).USDC();

        // Account for sKLIMA and wsKLIMA source tokens - swapping with KLIMA
        if (_sourceToken == sKLIMA || _sourceToken == wsKLIMA) {
            _sourceToken = KLIMA;
        }

        // If the source is KLIMA or USDC do a direct swap, else route through USDC.
        if (_sourceToken == KLIMA || _sourceToken == USDC) {
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
        address[] memory path = getSwapPath(_sourceToken, _poolToken);

        IERC20Upgradeable(path[0]).safeIncreaseAllowance(poolRouter[_poolToken], _amountIn);

        uint256[] memory amounts = IUniswapV2Router02(poolRouter[_poolToken]).swapTokensForExactTokens(
            _carbonAmount, _amountIn, path, address(this), block.timestamp
        );

        _returnTradeDust(amounts, _sourceToken, _amountIn, _retiree);
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
    function _swapExactForCarbon(address _sourceToken, address _poolToken, uint256 _amountIn)
        internal
        returns (uint256, uint256)
    {
        address[] memory path = getSwapPath(_sourceToken, _poolToken);

        uint256[] memory amountsOut = IUniswapV2Router02(poolRouter[_poolToken]).getAmountsOut(_amountIn, path);

        uint256 totalCarbon = amountsOut[path.length - 1];

        IERC20Upgradeable(_sourceToken).safeIncreaseAllowance(poolRouter[_poolToken], _amountIn);

        uint256[] memory amounts = IUniswapV2Router02(poolRouter[_poolToken]).swapExactTokensForTokens(
            _amountIn, (totalCarbon * 995) / 1000, path, address(this), block.timestamp
        );

        totalCarbon = amounts[amounts.length - 1] == 0 ? amounts[amounts.length - 2] : amounts[amounts.length - 1];

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
    function _returnTradeDust(uint256[] memory _amounts, address _sourceToken, uint256 _amountIn, address _retiree)
        internal
    {
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
     * === Toucan Certificate Functions ===
     */
    function onERC721Received(address, address, uint256 tokenId, bytes memory)
        external
        virtual
        override
        returns (bytes4)
    {
        // Update the last tokenId received so it can be transferred.
        lastTokenId = tokenId;

        return this.onERC721Received.selector;
    }

    function _sendRetireCert(address _beneficiary) internal {
        address retireCert = IToucanContractRegistry(toucanRegistry).carbonOffsetBadgesAddress();

        // Transfer the latest ERC721 retirement token to the beneficiary
        IERC721Upgradeable(retireCert).safeTransferFrom(address(this), _beneficiary, lastTokenId);
    }

    /**
     * === Admin Functions ===
     */

    /**
     * @notice Set the fee for the helper
     *     @param _amount New fee amount, in .1% increments. 10 = 1%
     *     @return bool
     */
    function setFeeAmount(uint256 _amount) external onlyOwner returns (bool) {
        uint256 oldFee = feeAmount;
        feeAmount = _amount;

        emit FeeUpdated(oldFee, feeAmount);
        return true;
    }

    /**
     * @notice Update the router for an existing pool
     *     @param _poolToken Pool being updated
     *     @param _router New router address
     *     @return bool
     */
    function setPoolRouter(address _poolToken, address _router) external onlyOwner returns (bool) {
        require(isPoolToken[_poolToken], "Pool not added");

        address oldRouter = poolRouter[_poolToken];
        poolRouter[_poolToken] = _router;
        emit PoolRouterChanged(_poolToken, oldRouter, poolRouter[_poolToken]);
        return true;
    }

    /**
     * @notice Update the Toucan Contract Registry
     *     @param _registry New Registry Address
     */
    function setToucanRegistry(address _registry) external onlyOwner {
        require(_registry != address(0), "Registry cannot be zero");

        address oldRegistry = toucanRegistry;
        toucanRegistry = _registry;
        emit RegistryUpdated(oldRegistry, _registry);
    }

    /**
     * @notice Add a new carbon pool to retire with helper contract
     *     @param _poolToken Pool being added
     *     @param _router UniswapV2 router to route trades through for non-pool retirements
     *     @return bool
     */
    function addPool(address _poolToken, address _router) external onlyOwner returns (bool) {
        require(!isPoolToken[_poolToken], "Pool already added");
        require(_poolToken != address(0), "Pool cannot be zero address");

        isPoolToken[_poolToken] = true;
        poolRouter[_poolToken] = _router;

        emit PoolAdded(_poolToken, _router);
        return true;
    }

    /**
     * @notice Remove a carbon pool to retire with helper contract
     *     @param _poolToken Pool being removed
     *     @return bool
     */
    function removePool(address _poolToken) external onlyOwner returns (bool) {
        require(isPoolToken[_poolToken], "Pool not added");

        isPoolToken[_poolToken] = false;

        emit PoolRemoved(_poolToken);
        return true;
    }

    /**
     * @notice Allow withdrawal of any tokens sent in error
     *     @param _token Address of token to transfer
     *     @param _recipient Address where to send tokens.
     */
    function feeWithdraw(address _token, address _recipient) public onlyOwner returns (bool) {
        IERC20Upgradeable(_token).safeTransfer(_recipient, IERC20Upgradeable(_token).balanceOf(address(this)));

        return true;
    }

    /**
     * @notice Allow the contract owner to update the master aggregator proxy address used.
     *     @param _newAddress New address for contract needing to be updated.
     *     @return bool
     */
    function setMasterAggregator(address _newAddress) external onlyOwner returns (bool) {
        address oldAddress = masterAggregator;
        masterAggregator = _newAddress;

        emit MasterAggregatorUpdated(oldAddress, _newAddress);

        return true;
    }

    function mintToucanCertificate(address _beneficiary, uint256 _index, address _carbonToken) external onlyOwner {
        address retirementStorage = IKlimaRetirementAggregator(masterAggregator).klimaRetirementStorage();

        // Get the message info from the prior retirement.
        (, uint256 amount, string memory beneficiaryString, string memory retirementMessage) =
            IKlimaCarbonRetirements(retirementStorage).getRetirementIndexInfo(_beneficiary, _index);

        // Mint the legacy certificate
        IToucanCarbonOffsets(_carbonToken).mintCertificateLegacy(
            "KlimaDAO Aggregator", _beneficiary, beneficiaryString, retirementMessage, amount
        );

        // Transfer to beneficiary
        _sendRetireCert(_beneficiary);
    }
}
