# ERC721ReceiverFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/infinity/facets/ERC721ReceiverFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md), [IERC721Receiver](/src/infinity/interfaces/IERC721Receiver.sol/interface.IERC721Receiver.md)


## Functions
### onERC721Received


```solidity
function onERC721Received(address, address, uint256 tokenId, bytes memory) external virtual override returns (bytes4);
```

