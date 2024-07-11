// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {InterchainTokenExecutable} from "axelar-its/executable/InterchainTokenExecutable.sol";
import {IAxelarGateway} from "axelar-gmp/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "axelar-gmp/interfaces/IAxelarGasService.sol";

import {IKlimaInfinity} from "src/protocol/interfaces/IKlimaInfinity.sol";

import {IERC20} from "oz/token/ERC20/IERC20.sol";
import {SafeERC20} from "oz/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "oz/access/Ownable.sol";
import "./StringAddressUtils.sol";

contract InfinityCrossChainRetire is InterchainTokenExecutable, Ownable {
    using SafeERC20 for IERC20;

    IAxelarGasService immutable gasReceiver;

    // Polygon permanent addresses
    address public constant DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;
    address public constant INFINITY = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;
    IERC20 public constant KLIMA = IERC20(0x4e78011Ce80ee02d2c3e649Fb657E45898257815);

    struct PendingRetire {
        bytes32 commandId;
        bytes retireData;
        uint256 klimaAmount;
        address refundAddress;
    }

    PendingRetire[] public pendingRetires;

    event RetireSuccess(bytes32 indexed commandId, uint256 klimaAmount);

    event RetirePending(bytes32 indexed commandId, uint256 klimaAmount, address refundAddress);

    event RetireFailed(bytes32 indexed commandId, uint256 klimaAmount, address refundAddress);

    constructor(address gateway_, address gasReceiver_) InterchainTokenExecutable(gateway_) Ownable(msg.sender) {
        gasReceiver = IAxelarGasService(gasReceiver_);
    }

    function processAllPending() external {
        for (uint256 i = pendingRetires.length - 1; i >= 0; i--) {
            (bool retireSuccess,) = INFINITY.call(pendingRetires[i].retireData);

            if (!retireSuccess) {
                return
                    _refund(pendingRetires[i].commandId, pendingRetires[i].klimaAmount, pendingRetires[i].refundAddress);
            }

            emit RetireSuccess(pendingRetires[i].commandId, pendingRetires[i].klimaAmount);

            pendingRetires.pop();
        }

        uint256 remainingKlima = KLIMA.balanceOf(address(this));

        if (remainingKlima > 0) KLIMA.safeTransfer(DAO, remainingKlima);
    }

    function processLastPending() external {
        uint256 i = pendingRetires.length - 1;
        (bool retireSuccess,) = INFINITY.call(pendingRetires[i].retireData);

        if (!retireSuccess) {
            _refund(pendingRetires[i].commandId, pendingRetires[i].klimaAmount, pendingRetires[i].refundAddress);
            pendingRetires.pop();
            return;
        }

        emit RetireSuccess(pendingRetires[i].commandId, pendingRetires[i].klimaAmount);

        pendingRetires.pop();
    }

    function _pendingRetire(bytes32 commandId, bytes memory retireData, uint256 amount, address refundAddress)
        internal
    {
        pendingRetires.push(
            PendingRetire({
                commandId: commandId,
                retireData: retireData,
                klimaAmount: amount,
                refundAddress: refundAddress
            })
        );
        emit RetirePending(commandId, amount, refundAddress);
    }

    function _refund(bytes32 commandId, uint256 amount, address recipient) internal {
        SafeERC20.safeTransfer(KLIMA, recipient, amount);
        emit RetireFailed(commandId, amount, recipient);
    }

    function _executeWithInterchainToken(
        bytes32 commandId,
        string calldata sourceChain,
        bytes calldata sourceAddress,
        bytes calldata data,
        bytes32 tokenId,
        address token,
        uint256 amount
    ) internal override {
        // Decode payload
        (bytes memory retireData, uint256 klimaAmount, address fallbackRecipient) =
            abi.decode(data, (bytes, uint256, address));

        KLIMA.safeIncreaseAllowance(INFINITY, klimaAmount);

        (bool retireSuccess,) = INFINITY.call(retireData);

        if (!retireSuccess) {
            return _pendingRetire(commandId, retireData, amount, fallbackRecipient);
        }

        uint256 remainingKlima = KLIMA.balanceOf(address(this));

        if (remainingKlima > 0) KLIMA.safeTransfer(DAO, remainingKlima);

        emit RetireSuccess(commandId, klimaAmount);
    }

    function emergencyWithdrawal(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
}
