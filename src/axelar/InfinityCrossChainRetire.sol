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

    event RetireSuccess(bytes32 indexed commandId, uint256 klimaAmount);

    event RetireFailed(bytes32 indexed commandId, uint256 amount, address refundAddress);

    constructor(address gateway_, address gasReceiver_) InterchainTokenExecutable(gateway_) Ownable(msg.sender) {
        gasReceiver = IAxelarGasService(gasReceiver_);
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
            return _refund(commandId, klimaAmount, fallbackRecipient);
        }

        uint256 remainingKlima = KLIMA.balanceOf(address(this));

        if (remainingKlima > 0) KLIMA.safeTransfer(DAO, remainingKlima);

        emit RetireSuccess(commandId, klimaAmount);
    }

    function emergencyWithdrawal(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    // function defaultRetirementWithKlima(
    //     string memory destinationChain,
    //     uint256 klimaAmount,
    //     uint256 retireAmount,
    //     bytes memory retirementData,
    //     bytes32 traceId,
    //     address fallbackRecipient
    // ) external payable isValidChain(destinationChain) {
    //     string memory symbol = "KLIMA";
    //     address tokenAddress = gateway.tokenAddresses(symbol);

    //     // Check that the sender has enough balance and has allowed the contract to spend the amount.
    //     // require(IERC20(tokenAddress).balanceOf(msg.sender) >= klimaAmount, "Insufficient balance");
    //     // require(IERC20(tokenAddress).allowance(msg.sender, address(this)) >= klimaAmount, "Insufficient allowance");

    //     klima.transferFrom(msg.sender, address(this), klimaAmount);
    //     klima.approve(address(gateway), klimaAmount);

    //     bytes memory payload = abi.encode(retirementData, klimaAmount, retireAmount, traceId, fallbackRecipient);

    //     // (bytes memory retireData,,,,) = abi.decode(payload, (bytes, uint256, uint256, bytes32, address));

    //     _payGasAndCallContractWithToken(destinationChain, payload, msg.value, symbol, klimaAmount);

    //     emit RetirePending(traceId, keccak256(payload), destinationChain, payload);
    // }

    // function _payGasAndCallContractWithToken(
    //     string memory destinationChain,
    //     bytes memory payload,
    //     uint256 fee,
    //     string memory symbol,
    //     uint256 amount
    // ) private {
    //     gasReceiver.payNativeGasForContractCallWithToken{value: fee}(
    //         msg.sender,
    //         destinationChain,
    //         AddressToString.toString(this.siblings(destinationChain)),
    //         payload,
    //         symbol,
    //         amount,
    //         msg.sender
    //     );

    //     gateway.callContractWithToken(
    //         destinationChain, AddressToString.toString(this.siblings(destinationChain)), payload, symbol, amount
    //     );
    // }

    // function _executeWithToken(string calldata sourceChain, string calldata sourceAddress, bytes calldata payload)
    //     internal
    //     virtual
    // {
    //     // Decode payload
    //     (bytes memory retireData, uint256 klimaAmount, uint256 retireAmount, bytes32 traceId, address fallbackRecipient)
    //     = abi.decode(payload, (bytes, uint256, uint256, bytes32, address));

    //     klima.safeIncreaseAllowance(INFINITY, klimaAmount);

    //     (bool retireSuccess,) = INFINITY.call(retireData);

    //     if (!retireSuccess) {
    //         return _refund(traceId, klimaAmount, fallbackRecipient);
    //     }

    //     uint256 remainingKlima = klima.balanceOf(address(this));

    //     if (remainingKlima > 0) klima.safeTransfer(DAO, remainingKlima);

    //     emit RetireSuccess(traceId, klimaAmount, retireAmount);
    // }
}
