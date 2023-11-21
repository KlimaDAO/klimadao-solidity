// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "src/infinity/interfaces/IERC1155Receiver.sol";
import {ReentrancyGuard} from "src/infinity/ReentrancyGuard.sol";

contract ERC1155ReceiverFacet is ReentrancyGuard, IERC1155Receiver {
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data)
        external
        virtual
        override
        returns (bytes4)
    {
        // Update the last tokenId received so it can be transferred.
        s.lastERC1155Received.tokenId = id;
        s.lastERC1155Received.value = value;

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external virtual override returns (bytes4) {
        // Update the last tokenId received so it can be transferred.

        s.lastERC1155Received.ids = ids;
        s.lastERC1155Received.values = values;

        return this.onERC1155BatchReceived.selector;
    }
}
