# ERC721ReceiverFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/facets/ERC721ReceiverFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md), [IERC721Receiver](/src/infinity/interfaces/IERC721Receiver.sol/interface.IERC721Receiver.md)


## Functions
### onERC721Received


```solidity
function onERC721Received(address, address, uint256 tokenId, bytes memory) external virtual override returns (bytes4);
```

