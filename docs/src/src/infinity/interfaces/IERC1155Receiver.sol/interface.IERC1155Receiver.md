# IERC1155Receiver
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/interfaces/IERC1155Receiver.sol)


## Functions
### onERC1155Received

*Handles the receipt of a single ERC1155 token type. This function is
called at the end of a `safeTransferFrom` after the balance has been updated.
NOTE: To accept the transfer, this must return
`bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
(i.e. 0xf23a6e61, or its own function selector).*


```solidity
function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data)
    external
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|The address which initiated the transfer (i.e. msg.sender)|
|`from`|`address`|The address which previously owned the token|
|`id`|`uint256`|The ID of the token being transferred|
|`value`|`uint256`|The amount of tokens being transferred|
|`data`|`bytes`|Additional data with no specified format|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|`bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed|


### onERC1155BatchReceived

*Handles the receipt of a multiple ERC1155 token types. This function
is called at the end of a `safeBatchTransferFrom` after the balances have
been updated.
NOTE: To accept the transfer(s), this must return
`bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
(i.e. 0xbc197c81, or its own function selector).*


```solidity
function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
) external returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`|The address which initiated the batch transfer (i.e. msg.sender)|
|`from`|`address`|The address which previously owned the token|
|`ids`|`uint256[]`|An array containing ids of each token being transferred (order and length must match values array)|
|`values`|`uint256[]`|An array containing amounts of each token being transferred (order and length must match ids array)|
|`data`|`bytes`|Additional data with no specified format|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|`bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed|


