/**
 *Submitted for verification at Etherscan.io on 2021-12-11
*/

// SPDX-License-Identifier: AGPL-3.0-or-later

// File: interfaces/IKlimaAuthority.sol


pragma solidity =0.7.5;

interface IKlimaAuthority {
    /* ========== EVENTS ========== */

    event GovernorPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event GuardianPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event PolicyPushed(address indexed from, address indexed to, bool _effectiveImmediately);
    event VaultPushed(address indexed from, address indexed to, bool _effectiveImmediately);

    event GovernorPulled(address indexed from, address indexed to);
    event GuardianPulled(address indexed from, address indexed to);
    event PolicyPulled(address indexed from, address indexed to);
    event VaultPulled(address indexed from, address indexed to);

    /* ========== VIEW ========== */

    function governor() external view returns (address);
    function guardian() external view returns (address);
    function policy() external view returns (address);
    function vault() external view returns (address);
}
// File: types/KlimaAccessControlled.sol


pragma solidity >=0.7.5;


abstract contract KlimaAccessControlled {

    /* ========== EVENTS ========== */

    event AuthorityUpdated(IKlimaAuthority indexed authority);

    string UNAUTHORIZED = "UNAUTHORIZED"; // save gas

    /* ========== STATE VARIABLES ========== */

    IKlimaAuthority public authority;


    /* ========== Constructor ========== */

    constructor(IKlimaAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }


    /* ========== MODIFIERS ========== */

    modifier onlyGovernor() {
        require(msg.sender == authority.governor(), UNAUTHORIZED);
        _;
    }

    modifier onlyGuardian() {
        require(msg.sender == authority.guardian(), UNAUTHORIZED);
        _;
    }

    modifier onlyPolicy() {
        require(msg.sender == authority.policy(), UNAUTHORIZED);
        _;
    }

    modifier onlyVault() {
        require(msg.sender == authority.vault(), UNAUTHORIZED);
        _;
    }

    /* ========== GOV ONLY ========== */

    function setAuthority(IKlimaAuthority _newAuthority) external onlyGovernor {
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }
}

// File: interfaces/ITreasury.sol


pragma solidity >=0.7.5;

interface ITreasury {
    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external returns (uint256);

    function withdraw(uint256 _amount, address _token) external;

    function tokenValue(address _token, uint256 _amount) external view returns (uint256 value_);

    function mint(address _recipient, uint256 _amount) external;

    function manage(address _token, uint256 _amount) external;

    function incurDebt(uint256 amount_, address token_) external;

    function repayDebtWithReserve(uint256 amount_, address token_) external;

    function excessReserves() external view returns (uint256);

    function baseSupply() external view returns (uint256);
}

// File: interfaces/IBondingCalculator.sol


pragma solidity >=0.7.5;

interface IBondingCalculator {
    function markdown( address _LP ) external view returns ( uint );

    function valuation( address pair_, uint amount_ ) external view returns ( uint _value );
}
// File: interfaces/IOwnable.sol


pragma solidity >=0.7.5;


interface IOwnable {
    function owner() external view returns (address);

    function renounceManagement() external;

    function pushManagement( address newOwner_ ) external;

    function pullManagement() external;
}
// File: interfaces/IERC20.sol


pragma solidity >=0.7.5;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
   */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: interfaces/IsKLIMA.sol


pragma solidity >=0.7.5;


interface IsKLIMA is IERC20 {
    function rebase( uint256 klimaProfit_, uint epoch_) external returns (uint256);

    function circulatingSupply() external view returns (uint256);

    function gonsForBalance( uint amount ) external view returns ( uint );

    function balanceForGons( uint gons ) external view returns ( uint );

    function index() external view returns ( uint );

    function toG(uint amount) external view returns (uint);

    function fromG(uint amount) external view returns (uint);

    function changeDebt(
        uint256 amount,
        address debtor,
        bool add
    ) external;

    function debtBalances(address _address) external view returns (uint256);

}

// File: interfaces/IKLIMA.sol


pragma solidity >=0.7.5;


interface IKLIMA is IERC20 {
    function mint(address account_, uint256 amount_) external;

    function burn(uint256 amount) external;

    function burnFrom(address account_, uint256 amount_) external;
}

// File: interfaces/IERC20Metadata.sol


pragma solidity >=0.7.5;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
// File: libraries/SafeERC20.sol


pragma solidity >=0.7.5;


/// @notice Safe IERC20 and ETH transfer library that safely handles missing return values.
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/libraries/TransferHelper.sol)
/// Taken from Solmate
library SafeERC20 {
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "TRANSFER_FAILED");
    }

    function safeApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(IERC20.approve.selector, to, amount)
        );

        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }

    function safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}(new bytes(0));

        require(success, "ETH_TRANSFER_FAILED");
    }
}
// File: libraries/SafeMath.sol


pragma solidity ^0.7.5;


// TODO(zx): Replace all instances of SafeMath with OZ implementation
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    // Only used in the  BondingCalculator.sol
    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }

}
// File: Treasury.sol


pragma solidity ^0.7.5;


contract OlympusTreasury is KlimaAccessControlled, ITreasury {
    /* ========== DEPENDENCIES ========== */

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== EVENTS ========== */

    event Deposit(address indexed token, uint256 amount, uint256 value);
    event Withdrawal(address indexed token, uint256 amount, uint256 value);
    event CreateDebt(address indexed debtor, address indexed token, uint256 amount, uint256 value);
    event RepayDebt(address indexed debtor, address indexed token, uint256 amount, uint256 value);
    event Managed(address indexed token, uint256 amount);
    event ReservesAudited(uint256 indexed totalReserves);
    event Minted(address indexed caller, address indexed recipient, uint256 amount);
    event PermissionQueued(STATUS indexed status, address queued);
    event Permissioned(address addr, STATUS indexed status, bool result);

    /* ========== DATA STRUCTURES ========== */

    enum STATUS {
        RESERVEDEPOSITOR,
        RESERVESPENDER,
        RESERVETOKEN,
        RESERVEMANAGER,
        LIQUIDITYDEPOSITOR,
        LIQUIDITYTOKEN,
        LIQUIDITYMANAGER,
        RESERVEDEBTOR,
        REWARDMANAGER,
        SKLIMA,
        KLIMADEBTOR
    }

    struct Queue {
        STATUS managing;
        address toPermit;
        address calculator;
        uint256 timelockEnd;
        bool nullify;
        bool executed;
    }

    /* ========== STATE VARIABLES ========== */

    IKLIMA public immutable KLIMA;
    IsKLIMA public sKLIMA;

    mapping(STATUS => address[]) public registry;
    mapping(STATUS => mapping(address => bool)) public permissions;
    mapping(address => address) public bondCalculator;

    mapping(address => uint256) public debtLimit;

    uint256 public totalReserves;
    uint256 public totalDebt;
    uint256 public klimaDebt;

    Queue[] public permissionQueue;
    uint256 public immutable blocksNeededForQueue;

    bool public timelockEnabled;
    bool public initialized;

    uint256 public onChainGovernanceTimelock;

    string internal notAccepted = "Treasury: not accepted";
    string internal notApproved = "Treasury: not approved";
    string internal invalidToken = "Treasury: invalid token";
    string internal insufficientReserves = "Treasury: insufficient reserves";

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _klima,
        uint256 _timelock,
        address _authority
    ) KlimaAccessControlled(IKlimaAuthority(_authority)) {
        require(_klima != address(0), "Zero address: KLIMA");
        KLIMA = IKLIMA(_klima);

        timelockEnabled = false;
        initialized = false;
        blocksNeededForQueue = _timelock;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @notice allow approved address to deposit an asset for KLIMA
     * @param _amount uint256
     * @param _token address
     * @param _profit uint256
     * @return send_ uint256
     */
    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external override returns (uint256 send_) {
        if (permissions[STATUS.RESERVETOKEN][_token]) {
            require(permissions[STATUS.RESERVEDEPOSITOR][msg.sender], notApproved);
        } else if (permissions[STATUS.LIQUIDITYTOKEN][_token]) {
            require(permissions[STATUS.LIQUIDITYDEPOSITOR][msg.sender], notApproved);
        } else {
            revert(invalidToken);
        }

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        uint256 value = tokenValue(_token, _amount);
        // mint KLIMA needed and store amount of rewards for distribution
        send_ = value.sub(_profit);
        KLIMA.mint(msg.sender, send_);

        totalReserves = totalReserves.add(value);

        emit Deposit(_token, _amount, value);
    }

    /**
     * @notice allow approved address to burn KLIMA for reserves
     * @param _amount uint256
     * @param _token address
     */
    function withdraw(uint256 _amount, address _token) external override {
        require(permissions[STATUS.RESERVETOKEN][_token], notAccepted); // Only reserves can be used for redemptions
        require(permissions[STATUS.RESERVESPENDER][msg.sender], notApproved);

        uint256 value = tokenValue(_token, _amount);
        KLIMA.burnFrom(msg.sender, value);

        totalReserves = totalReserves.sub(value);

        IERC20(_token).safeTransfer(msg.sender, _amount);

        emit Withdrawal(_token, _amount, value);
    }

    /**
     * @notice allow approved address to withdraw assets
     * @param _token address
     * @param _amount uint256
     */
    function manage(address _token, uint256 _amount) external override {
        if (permissions[STATUS.LIQUIDITYTOKEN][_token]) {
            require(permissions[STATUS.LIQUIDITYMANAGER][msg.sender], notApproved);
        } else {
            require(permissions[STATUS.RESERVEMANAGER][msg.sender], notApproved);
        }
        if (permissions[STATUS.RESERVETOKEN][_token] || permissions[STATUS.LIQUIDITYTOKEN][_token]) {
            uint256 value = tokenValue(_token, _amount);
            require(value <= excessReserves(), insufficientReserves);
            totalReserves = totalReserves.sub(value);
        }
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit Managed(_token, _amount);
    }

    /**
     * @notice mint new KLIMA using excess reserves
     * @param _recipient address
     * @param _amount uint256
     */
    function mint(address _recipient, uint256 _amount) external override {
        require(permissions[STATUS.REWARDMANAGER][msg.sender], notApproved);
        require(_amount <= excessReserves(), insufficientReserves);
        KLIMA.mint(_recipient, _amount);
        emit Minted(msg.sender, _recipient, _amount);
    }

    /**
     * DEBT: The debt functions allow approved addresses to borrow treasury assets
     * or KLIMA from the treasury, using sKLIMA as collateral. This might allow an
     * sKLIMA holder to provide KLIMA liquidity without taking on the opportunity cost
     * of unstaking, or alter their backing without imposing risk onto the treasury.
     * Many of these use cases are yet to be defined, but they appear promising.
     * However, we urge the community to think critically and move slowly upon
     * proposals to acquire these permissions.
     */

    /**
     * @notice allow approved address to borrow reserves
     * @param _amount uint256
     * @param _token address
     */
    function incurDebt(uint256 _amount, address _token) external override {
        uint256 value;
        if (_token == address(KLIMA)) {
            require(permissions[STATUS.KLIMADEBTOR][msg.sender], notApproved);
            value = _amount;
        } else {
            require(permissions[STATUS.RESERVEDEBTOR][msg.sender], notApproved);
            require(permissions[STATUS.RESERVETOKEN][_token], notAccepted);
            value = tokenValue(_token, _amount);
        }
        require(value != 0, invalidToken);

        sKLIMA.changeDebt(value, msg.sender, true);
        require(sKLIMA.debtBalances(msg.sender) <= debtLimit[msg.sender], "Treasury: exceeds limit");
        totalDebt = totalDebt.add(value);

        if (_token == address(KLIMA)) {
            KLIMA.mint(msg.sender, value);
            klimaDebt = klimaDebt.add(value);
        } else {
            totalReserves = totalReserves.sub(value);
            IERC20(_token).safeTransfer(msg.sender, _amount);
        }
        emit CreateDebt(msg.sender, _token, _amount, value);
    }

    /**
     * @notice allow approved address to repay borrowed reserves with reserves
     * @param _amount uint256
     * @param _token address
     */
    function repayDebtWithReserve(uint256 _amount, address _token) external override {
        require(permissions[STATUS.RESERVEDEBTOR][msg.sender], notApproved);
        require(permissions[STATUS.RESERVETOKEN][_token], notAccepted);
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 value = tokenValue(_token, _amount);
        sKLIMA.changeDebt(value, msg.sender, false);
        totalDebt = totalDebt.sub(value);
        totalReserves = totalReserves.add(value);
        emit RepayDebt(msg.sender, _token, _amount, value);
    }

    /**
     * @notice allow approved address to repay borrowed reserves with KLIMA
     * @param _amount uint256
     */
    function repayDebtWithKLIMA(uint256 _amount) external {
        require(permissions[STATUS.RESERVEDEBTOR][msg.sender] || permissions[STATUS.KLIMADEBTOR][msg.sender], notApproved);
        KLIMA.burnFrom(msg.sender, _amount);
        sKLIMA.changeDebt(_amount, msg.sender, false);
        totalDebt = totalDebt.sub(_amount);
        klimaDebt = klimaDebt.sub(_amount);
        emit RepayDebt(msg.sender, address(KLIMA), _amount, _amount);
    }

    /* ========== MANAGERIAL FUNCTIONS ========== */

    /**
     * @notice takes inventory of all tracked assets
     * @notice always consolidate to recognized reserves before audit
     */
    function auditReserves() external onlyGovernor {
        uint256 reserves;
        address[] memory reserveToken = registry[STATUS.RESERVETOKEN];
        for (uint256 i = 0; i < reserveToken.length; i++) {
            if (permissions[STATUS.RESERVETOKEN][reserveToken[i]]) {
                reserves = reserves.add(tokenValue(reserveToken[i], IERC20(reserveToken[i]).balanceOf(address(this))));
            }
        }
        address[] memory liquidityToken = registry[STATUS.LIQUIDITYTOKEN];
        for (uint256 i = 0; i < liquidityToken.length; i++) {
            if (permissions[STATUS.LIQUIDITYTOKEN][liquidityToken[i]]) {
                reserves = reserves.add(tokenValue(liquidityToken[i], IERC20(liquidityToken[i]).balanceOf(address(this))));
            }
        }
        totalReserves = reserves;
        emit ReservesAudited(reserves);
    }

    /**
     * @notice set max debt for address
     * @param _address address
     * @param _limit uint256
     */
    function setDebtLimit(address _address, uint256 _limit) external onlyGovernor {
        debtLimit[_address] = _limit;
    }

    /**
     * @notice enable permission from queue
     * @param _status STATUS
     * @param _address address
     * @param _calculator address
     */
    function enable(
        STATUS _status,
        address _address,
        address _calculator
    ) external onlyGovernor {
        require(timelockEnabled == false, "Use queueTimelock");
        if (_status == STATUS.SKLIMA) {
            sKLIMA = IsKLIMA(_address);
        } else {
            permissions[_status][_address] = true;

            if (_status == STATUS.LIQUIDITYTOKEN) {
                bondCalculator[_address] = _calculator;
            }

            (bool registered, ) = indexInRegistry(_address, _status);
            if (!registered) {
                registry[_status].push(_address);

                if (_status == STATUS.LIQUIDITYTOKEN || _status == STATUS.RESERVETOKEN) {
                    (bool reg, uint256 index) = indexInRegistry(_address, _status);
                    if (reg) {
                        delete registry[_status][index];
                    }
                }
            }
        }
        emit Permissioned(_address, _status, true);
    }

    /**
     *  @notice disable permission from address
     *  @param _status STATUS
     *  @param _toDisable address
     */
    function disable(STATUS _status, address _toDisable) external {
        require(msg.sender == authority.governor() || msg.sender == authority.guardian(), "Only governor or guardian");
        permissions[_status][_toDisable] = false;
        emit Permissioned(_toDisable, _status, false);
    }

    /**
     * @notice check if registry contains address
     * @return (bool, uint256)
     */
    function indexInRegistry(address _address, STATUS _status) public view returns (bool, uint256) {
        address[] memory entries = registry[_status];
        for (uint256 i = 0; i < entries.length; i++) {
            if (_address == entries[i]) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    /* ========== TIMELOCKED FUNCTIONS ========== */

    // functions are used prior to enabling on-chain governance

    /**
     * @notice queue address to receive permission
     * @param _status STATUS
     * @param _address address
     * @param _calculator address
     */
    function queueTimelock(
        STATUS _status,
        address _address,
        address _calculator
    ) external onlyGovernor {
        require(_address != address(0));
        require(timelockEnabled == true, "Timelock is disabled, use enable");

        uint256 timelock = block.number.add(blocksNeededForQueue);
        if (_status == STATUS.RESERVEMANAGER || _status == STATUS.LIQUIDITYMANAGER) {
            timelock = block.number.add(blocksNeededForQueue.mul(2));
        }
        permissionQueue.push(
            Queue({managing: _status, toPermit: _address, calculator: _calculator, timelockEnd: timelock, nullify: false, executed: false})
        );
        emit PermissionQueued(_status, _address);
    }

    /**
     *  @notice enable queued permission
     *  @param _index uint256
     */
    function execute(uint256 _index) external {
        require(timelockEnabled == true, "Timelock is disabled, use enable");

        Queue memory info = permissionQueue[_index];

        require(!info.nullify, "Action has been nullified");
        require(!info.executed, "Action has already been executed");
        require(block.number >= info.timelockEnd, "Timelock not complete");

        if (info.managing == STATUS.SKLIMA) {
            // 9
            sKLIMA = IsKLIMA(info.toPermit);
        } else {
            permissions[info.managing][info.toPermit] = true;

            if (info.managing == STATUS.LIQUIDITYTOKEN) {
                bondCalculator[info.toPermit] = info.calculator;
            }
            (bool registered, ) = indexInRegistry(info.toPermit, info.managing);
            if (!registered) {
                registry[info.managing].push(info.toPermit);

                if (info.managing == STATUS.LIQUIDITYTOKEN) {
                    (bool reg, uint256 index) = indexInRegistry(info.toPermit, STATUS.RESERVETOKEN);
                    if (reg) {
                        delete registry[STATUS.RESERVETOKEN][index];
                    }
                } else if (info.managing == STATUS.RESERVETOKEN) {
                    (bool reg, uint256 index) = indexInRegistry(info.toPermit, STATUS.LIQUIDITYTOKEN);
                    if (reg) {
                        delete registry[STATUS.LIQUIDITYTOKEN][index];
                    }
                }
            }
        }
        permissionQueue[_index].executed = true;
        emit Permissioned(info.toPermit, info.managing, true);
    }

    /**
     * @notice cancel timelocked action
     * @param _index uint256
     */
    function nullify(uint256 _index) external onlyGovernor {
        permissionQueue[_index].nullify = true;
    }

    /**
     * @notice disables timelocked functions
     */
    function disableTimelock() external onlyGovernor {
        require(timelockEnabled == true, "timelock already disabled");
        if (onChainGovernanceTimelock != 0 && onChainGovernanceTimelock <= block.number) {
            timelockEnabled = false;
        } else {
            onChainGovernanceTimelock = block.number.add(blocksNeededForQueue.mul(7)); // 7-day timelock
        }
    }

    /**
     * @notice enables timelocks after initilization
     */
    function initialize() external onlyGovernor {
        require(initialized == false, "Already initialized");
        timelockEnabled = true;
        initialized = true;
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice returns excess reserves not backing tokens
     * @return uint
     */
    function excessReserves() public view override returns (uint256) {
        return totalReserves.sub(KLIMA.totalSupply().sub(totalDebt));
    }

    /**
     * @notice returns KLIMA valuation of asset
     * @param _token address
     * @param _amount uint256
     * @return value_ uint256
     */
    function tokenValue(address _token, uint256 _amount) public view override returns (uint256 value_) {
        value_ = _amount.mul(10**IERC20Metadata(address(KLIMA)).decimals()).div(10**IERC20Metadata(_token).decimals());

        if (permissions[STATUS.LIQUIDITYTOKEN][_token]) {
            value_ = IBondingCalculator(bondCalculator[_token]).valuation(_token, _amount);
        }
    }

    /**
     * @notice returns supply metric that cannot be manipulated by debt
     * @dev use this any time you need to query supply
     * @return uint256
     */
    function baseSupply() external view override returns (uint256) {
        return KLIMA.totalSupply() - klimaDebt;
    }
}