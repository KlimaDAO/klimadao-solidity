# ERC1155ReceiverFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/facets/ERC1155ReceiverFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md), [IERC1155Receiver](/src/infinity/interfaces/IERC1155Receiver.sol/interface.IERC1155Receiver.md)


## Functions
### onERC1155Received


```solidity
function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data)
    external
    virtual
    override
    returns (bytes4);
```

### onERC1155BatchReceived


```solidity
function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
) external virtual override returns (bytes4);
```

