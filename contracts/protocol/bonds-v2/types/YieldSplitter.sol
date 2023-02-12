// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.10;

import {IERC20} from "../interfaces/IERC20.sol";
import {IwsKLIMA} from "../../interfaces/IwsKLIMA.sol";
import {SafeERC20} from "../libraries/SafeERC20.sol";
import {KlimaAccessControlledV2, IKlimaAuthority} from "../types/KlimaAccessControlledV2.sol";

/**
    @title IKLIMAIndexWrapper
    @notice This interface is used to wrap cross-chain oracles to feed an index without needing IsKLIMA,
    while also being able to use sKLIMA on mainnet.
 */
interface IKLIMAIndexWrapper {
    function index() external view returns (uint256 index);
}

/**
    @title IYieldSplitter
    @notice This interface will be used to access common functions between yieldsplitter implementations.
    This will allow certain operations to be done regardless of implementation details.
 */
 interface IYieldSplitter {

    function redeemYieldOnBehalfOf(uint256 id_) external returns (uint256);

    function redeemAllYieldOnBehalfOf(address recipient_) external returns (uint256);

    function givePermissionToRedeem(address address_) external;

    function revokePermissionToRedeem(address address_) external;

    function redeemableBalance(uint256 depositId_) external view returns (uint256);

    function totalRedeemableBalance(address recipient_) external view returns (uint256);

    function getDepositorIds(address donor_) external view returns (uint256[] memory);
}

error YieldSplitter_NotYourDeposit();

/**
    @title YieldSplitter
    @notice Abstract contract that allows users to create deposits for their wsKLIMA and have
            their yield claimable by the specified recipient party. This contract's functions
            are designed to be as generic as possible. This contract's responsibility is
            the accounting of the yield splitting and some error handling. All other logic such as
            emergency controls, sending and recieving wsKLIMA is up to the implementation of
            this abstract contract to handle.
 */
abstract contract YieldSplitter is KlimaAccessControlledV2, IYieldSplitter {
    using SafeERC20 for IERC20;

    IKLIMAIndexWrapper public immutable indexWrapper;

    struct DepositInfo {
        uint256 id;
        address depositor;
        uint256 principalAmount; // Total amount of sOhm deposited as principal, 9 decimals.
        uint256 agnosticAmount; // Total amount deposited priced in wsKlima. 18 decimals.
    }

    uint256 public idCount;
    mapping(uint256 => DepositInfo) public depositInfo; // depositId -> DepositInfo
    mapping(address => uint256[]) public depositorIds; // address -> Array of the deposit id's deposited by user
    mapping(address => bool) public hasPermissionToRedeem; // keep track of which contracts can redeem deposits on behalf of users

    /**
        @notice Constructor
        @param indexWrapper_ Address of contract that will return the sKLIMA to wsKLIMA index.
                             On mainnet this will be sKLIMA but on other chains can be an oracle wrapper.
    */
    constructor(address indexWrapper_, address authority_) KlimaAccessControlledV2(IKlimaAuthority(authority_)) {
        indexWrapper = IKLIMAIndexWrapper(indexWrapper_);
    }

    /**
        @notice Create a deposit.
        @param depositor_ Address of depositor
        @param amount_ Amount in wsKlima. 18 decimals.
    */
    function _deposit(address depositor_, uint256 amount_) internal returns (uint256 depositId) {
        depositorIds[depositor_].push(idCount);

        depositInfo[idCount] = DepositInfo({
            id: idCount,
            depositor: depositor_,
            principalAmount: _fromAgnostic(amount_),
            agnosticAmount: amount_
        });

        depositId = idCount;
        idCount++;
    }

    /**
        @notice Add more wsKlima to the depositor's principal deposit.
        @param id_ Id of the deposit.
        @param amount_ Amount of wsKlima to add. 18 decimals.
    */
    function _addToDeposit(
        uint256 id_,
        uint256 amount_,
        address depositorAddress
    ) internal {
        if (depositInfo[id_].depositor != depositorAddress) revert YieldSplitter_NotYourDeposit();

        DepositInfo storage userDeposit = depositInfo[id_];
        userDeposit.principalAmount += _fromAgnostic(amount_);
        userDeposit.agnosticAmount += amount_;
    }

    /**
        @notice Withdraw part of the principal amount deposited.
        @param id_ Id of the deposit.
        @param amount_ Amount of wsKLIMA to withdraw.
    */
    function _withdrawPrincipal(
        uint256 id_,
        uint256 amount_,
        address depositorAddress
    ) internal {
        if (depositInfo[id_].depositor != depositorAddress) revert YieldSplitter_NotYourDeposit();

        DepositInfo storage userDeposit = depositInfo[id_];
        userDeposit.principalAmount -= _fromAgnostic(amount_); // Reverts if amount > principal due to underflow
        userDeposit.agnosticAmount -= amount_;
    }

    /**
        @notice Withdraw all of the principal amount deposited.
        @param id_ Id of the deposit.
        @return amountWithdrawn : amount of wsKLIMA withdrawn. 18 decimals.
    */
    function _withdrawAllPrincipal(uint256 id_, address depositorAddress) internal returns (uint256 amountWithdrawn) {
        if (depositInfo[id_].depositor != depositorAddress) revert YieldSplitter_NotYourDeposit();

        DepositInfo storage userDeposit = depositInfo[id_];
        amountWithdrawn = _toAgnostic(userDeposit.principalAmount);
        userDeposit.principalAmount = 0;
        userDeposit.agnosticAmount -= amountWithdrawn;
    }

    /**
        @notice Redeem excess yield from your deposit in sKLIMA.
        @param id_ Id of the deposit.
        @return amountRedeemed : amount of yield redeemed in wsKLIMA. 18 decimals.
    */
    function _redeemYield(uint256 id_) internal returns (uint256 amountRedeemed) {
        DepositInfo storage userDeposit = depositInfo[id_];

        amountRedeemed = _getOutstandingYield(userDeposit.principalAmount, userDeposit.agnosticAmount);
        userDeposit.agnosticAmount = userDeposit.agnosticAmount - amountRedeemed;
    }

    /**
        @notice Close a deposit. Remove all information in both the deposit info, depositorIds and recipientIds.
        @param id_ Id of the deposit.
        @dev Internally for accounting reasons principal amount is stored in 9 decimal KLIMA terms.
        Since most implementations will work will wsKLIMA, principal here is returned externally in 18 decimal wsKLIMA terms.
        @return principal : amount of principal that was deleted. in wsKLIMA. 18 decimals.
        @return agnosticAmount : total amount of wsKLIMA deleted. Principal + Yield. 18 decimals.
    */
    function _closeDeposit(uint256 id_, address depositorAddress)
        internal
        returns (uint256 principal, uint256 agnosticAmount)
    {
        address depositorAddressToClose = depositInfo[id_].depositor;
        if (depositorAddressToClose != depositorAddress) revert YieldSplitter_NotYourDeposit();

        principal = _toAgnostic(depositInfo[id_].principalAmount);
        agnosticAmount = depositInfo[id_].agnosticAmount;

        uint256[] storage depositorIdsArray = depositorIds[depositorAddressToClose];
        for (uint256 i = 0; i < depositorIdsArray.length; i++) {
            if (depositorIdsArray[i] == id_) {
                // Remove id from depositor's ids array
                depositorIdsArray[i] = depositorIdsArray[depositorIdsArray.length - 1]; // Delete integer from array by swapping with last element and calling pop()
                depositorIdsArray.pop();
                break;
            }
        }

        delete depositInfo[id_];
    }

    /**
        @notice Redeems yield from a deposit and sends it to the recipient
        @param id_ Id of the deposit.
    */
    function redeemYieldOnBehalfOf(uint256 id_) external virtual returns (uint256) {}

    /**
        @notice Redeems all yield tied to a recipient and sends it to the recipient
        @param recipient_ recipient address.
    */
    function redeemAllYieldOnBehalfOf(address recipient_) external virtual returns (uint256) {}

    /**
        @notice Get redeemable wsKLIMA balance of a specific deposit
        @param depositId_ Deposit ID for this donation
    */
    function redeemableBalance(uint256 depositId_) public view virtual returns (uint256) {}

    /**
        @notice Get redeemable wsKLIMA balance of a recipient address
        @param recipient_ Address of user receiving donated yield
     */
    function totalRedeemableBalance(address recipient_) external view virtual returns (uint256) {}

    /**
        @notice Gives a contract permission to redeem yield on behalf of users
        @param address_ Id of the deposit.
    */
    function givePermissionToRedeem(address address_) external {
        _onlyGuardian();
        hasPermissionToRedeem[address_] = true;
    }

    /**
        @notice Revokes a contract permission to redeem yield on behalf of users
        @param address_ Id of the deposit.
    */
    function revokePermissionToRedeem(address address_) external {
        _onlyGuardian();
        hasPermissionToRedeem[address_] = false;
    }

    /**
        @notice Returns the array of deposit id's belonging to the depositor
        @return uint256[] array of depositor Id's
     */
    function getDepositorIds(address donor_) external view returns (uint256[] memory) {
        return depositorIds[donor_];
    }

    /**
        @notice Calculate outstanding yield redeemable based on principal and agnosticAmount.
        @return uint256 amount of yield in wsKLIMA. 18 decimals.
     */
    function _getOutstandingYield(uint256 principal_, uint256 agnosticAmount_) internal view returns (uint256) {
        // agnosticAmount must be greater than or equal to _toAgnostic(principal_) since agnosticAmount_
        // is the sum of principal_ and the yield. Thus this can be unchecked.
        unchecked { return agnosticAmount_ - _toAgnostic(principal_); }
    }

    /**
        @notice Convert flat sKLIMA value to agnostic wsKLIMA value at current index
        @dev Agnostic value earns rebases. Agnostic value is amount / rebase_index.
             1e18 is because sKLIMA has 9 decimals, wsKLIMA has 18 and index has 9.
     */
    function _toAgnostic(uint256 amount_) internal view returns (uint256) {
        return (amount_ * 1e18) / (indexWrapper.index());
    }

    /**
        @notice Convert agnostic wsKLIMA value at current index to flat sKLIMA value
        @dev Agnostic value earns rebases. sKLIMA amount is wsKLIMAamount * rebase_index.
             1e18 is because sKLIMA has 9 decimals, wsKLIMA has 18 and index has 9.
     */
    function _fromAgnostic(uint256 amount_) internal view returns (uint256) {
        return (amount_ * (indexWrapper.index())) / 1e18;
    }
}
