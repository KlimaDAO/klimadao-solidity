//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface ICarbonChain {
    function offsetCarbon(uint _carbonTon, string calldata _transactionInfo, string calldata _onBehalfOf) external;
}
