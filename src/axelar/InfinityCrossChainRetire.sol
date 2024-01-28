pragma solidity =0.8.16;

import {AxelarExecutable} from "axelar-gmp/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "axelar-gmp/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "axelar-gmp/interfaces/IAxelarGasService.sol";
import {ITokenMessenger} from "src/interfaces/ITokenMessenger.sol";

import {IKlimaInfinity} from "src/protocol/interfaces/IKlimaInfinity.sol";

import {IERC20} from "oz/token/ERC20/IERC20.sol";
import {SafeERC20} from "oz/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "oz/access/Ownable.sol";
import "./StringAddressUtils.sol";

contract InfinityCrossChainRetire is AxelarExecutable, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public usdc;
    ITokenMessenger public tokenMessenger;
    IAxelarGasService immutable gasReceiver;

    // Polygon permanent addresses
    address public constant DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;
    address public constant INFINITY = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;

    // mapping chain name => domain number;
    mapping(string => uint32) public circleDestinationDomains;
    // mapping destination chain name => destination contract address
    mapping(string => address) public siblings;
    mapping(string => address) public escrows;

    event RetireSuccess(bytes32 indexed traceId, uint256 amount);

    event RetireFailed(bytes32 indexed traceId, uint256 amount, address refundAddress);

    event RetirePending(bytes32 indexed traceId, bytes32 indexed payloadHash, string destinationChain, bytes payload);

    constructor(address gateway_, address usdc_, address tokenMessenger_, address gasReceiver_)
        AxelarExecutable(gateway_)
    {
        usdc = IERC20(usdc_);
        tokenMessenger = ITokenMessenger(tokenMessenger_);
        gasReceiver = IAxelarGasService(gasReceiver_);

        circleDestinationDomains["polygon"] = 7;
    }

    modifier isValidChain(string memory destinationChain) {
        require(siblings[destinationChain] != address(0), "Invalid chain");
        _;
    }

    // Set address for this contract that deployed at another chain
    function addSibling(string memory chain_, address address_, address escrow_) external onlyOwner {
        siblings[chain_] = address_;
        escrows[chain_] = escrow_;
    }

    function nativeUsdcDefaultRetirement(
        string memory destinationChain,
        uint256 usdcAmount,
        bytes memory retirementData,
        bytes32 traceId,
        address fallbackRecipient
    ) external payable isValidChain(destinationChain) {
        ///TODO: Utilize escrow contract.
        _sendViaCCTP(usdcAmount, destinationChain, this.siblings(destinationChain));

        bytes memory payload = abi.encode(retirementData, usdcAmount, traceId, fallbackRecipient);

        (bytes memory retireData,,,) = abi.decode(payload, (bytes, uint256, bytes32, address));

        _payGasAndCallContract(destinationChain, payload, msg.value);

        emit RetirePending(traceId, keccak256(payload), destinationChain, payload);
    }

    function _payGasAndCallContract(string memory destinationChain, bytes memory payload, uint256 fee) private {
        gasReceiver.payNativeGasForContractCall{value: fee}(
            address(this),
            destinationChain,
            AddressToString.toString(this.siblings(destinationChain)),
            payload,
            msg.sender
        );

        // Send all information to AxelarGateway contract.
        gateway.callContract(destinationChain, AddressToString.toString(this.siblings(destinationChain)), payload);
    }

    function _sendViaCCTP(uint256 amount, string memory destinationChain, address recipient)
        private
        isValidChain(destinationChain)
    {
        IERC20(address(usdc)).transferFrom(msg.sender, address(this), amount);
        IERC20(address(usdc)).approve(address(tokenMessenger), amount);

        tokenMessenger.depositForBurn(
            amount, this.circleDestinationDomains(destinationChain), bytes32(uint256(uint160(recipient))), address(usdc)
        );
    }

    function _refund(bytes32 traceId, uint256 amount, address recipient) internal {
        SafeERC20.safeTransfer(IERC20(address(usdc)), recipient, amount);
        emit RetireFailed(traceId, amount, recipient);
    }

    function _execute(
        string calldata, //sourceChain
        string calldata, //sourceAddress
        bytes calldata payload
    ) internal override {
        // Decode payload
        (bytes memory retireData, uint256 usdcAmount, bytes32 traceId, address fallbackRecipient) =
            abi.decode(payload, (bytes, uint256, bytes32, address));

        ///TODO: Utilize escrow contract for payment
        usdc.safeIncreaseAllowance(INFINITY, usdcAmount);

        (bool retireSuccess,) = INFINITY.call(retireData);

        if (!retireSuccess) {
            return _refund(traceId, usdcAmount, fallbackRecipient);
        }

        uint256 remainingUsdc = usdc.balanceOf(address(this));

        if (remainingUsdc > 0) usdc.safeTransfer(DAO, remainingUsdc);

        emit RetireSuccess(traceId, usdcAmount);
    }
}
