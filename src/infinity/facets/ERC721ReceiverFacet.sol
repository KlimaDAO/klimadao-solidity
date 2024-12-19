// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../interfaces/IERC721Receiver.sol";
import "../ReentrancyGuard.sol";

contract ERC721ReceiverFacet is ReentrancyGuard, IERC721Receiver {
    function onERC721Received(address, address, uint256 tokenId, bytes memory)
        external
        virtual
        override
        returns (bytes4)
    {
        // Update the last tokenId received so it can be transferred.
        s.lastERC721Received = tokenId;

        return this.onERC721Received.selector;
    }
}
