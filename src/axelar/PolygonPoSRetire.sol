// //SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
// import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
// import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
// import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';

// // TODO: import Retirement Aggregator contract abi
// import { IKlimaInfinity } from 'src/protocol/interfaces/IKlimaInfinity.sol';

// contract DefaultRetirementExecutable is AxelarExecutable {
//     /// @notice address of the Klima Infinity contract on Polygon PoS.
//     address public constant INFINITY = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;

//     IAxelarGasService public immutable gasService;

//     // struct to hold RA params
//     struct RetireDefaultParams {
//         address poolToken;
//         uint retireAmount;
//         string retiringEntityString;
//         address beneficiaryAddress;
//         string beneficiaryString;
//         string retirementMessage;
//     }

//     constructor(address gateway_, address gasReceiver_, string destinationChain_) AxelarExecutable(gateway_) {
//         gasService = IAxelarGasService(gasReceiver_);
//         destinationChain = destinationChain_;
//     }

//     function retireDefaultViaPolygonPoS(
//         string memory destinationAddress,
//         address poolToken,
//         uint retireAmount,
//         string memory retiringEntityString,
//         address beneficiaryAddress,
//         string memory beneficiaryString,
//         string memory retirementMessage,
//         string memory symbol,
//         uint256 amount
//     ) external payable {
//         require(msg.value > 0, 'Gas payment is required');

//         // TODO: check if this looks up native USDC or USDC.e only
//         address tokenAddress = gateway.tokenAddresses(symbol);

//         IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
//         IERC20(tokenAddress).approve(address(gateway), amount);

//         // pack appropriate params provided into a payload
//         bytes memory payload = abi.encode(
//             RetireDefaultParams(
//                 poolToken,
//                 retireAmount,
//                 retiringEntityString,
//                 beneficiaryAddress,
//                 beneficiaryString,
//                 retirementMessage
//             )
//         );
//         gasService.payNativeGasForContractCallWithToken{ value: msg.value }(
//             address(this),
//             destinationChain,
//             destinationAddress,
//             payload,
//             symbol,
//             amount,
//             msg.sender
//         );
//         gateway.callContractWithToken(destinationChain, destinationAddress, payload, symbol, amount);
//     }

//     function _executeWithToken(
//         string calldata,
//         string calldata,
//         bytes calldata payload,
//         string calldata tokenSymbol,
//         uint256 amount
//     ) internal override {

//         // unpack all params from the payload
//         RetireDefaultParams memory params = abi.decode(payload, (RetireDefaultParams));

//         // look up token to be used as sourceToken address -
//         // could be hard-coded since we know this is invoked only on Polygon PoS
//         address tokenAddress = gateway.tokenAddresses(tokenSymbol);

//         // initialize the RA ABI and invoke the retire function with unpacked params
//         IKlimaInfinity(INFINITY).retireExactCarbonDefault(
//             tokenAddress,
//             params.poolToken,
//             amount,
//             params.retireAmount,
//             params.retiringEntityString,
//             params.beneficiaryAddress,
//             params.beneficiaryString,
//             params.retirementMessage,
//             0
//         );
//     }
// Default}
