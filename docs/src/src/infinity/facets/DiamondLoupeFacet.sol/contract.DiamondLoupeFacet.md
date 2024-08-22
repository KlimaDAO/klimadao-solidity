# DiamondLoupeFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/facets/DiamondLoupeFacet.sol)

**Inherits:**
[IDiamondLoupe](/src/infinity/interfaces/IDiamondLoupe.sol/interface.IDiamondLoupe.md), [IERC165](/src/infinity/interfaces/IERC165.sol/interface.IERC165.md)

\
Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/*****************************************************************************


## Functions
### facets

These functions are expected to be called frequently by tools.

Gets all facets and their selectors.


```solidity
function facets() external view override returns (Facet[] memory facets_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facets_`|`Facet[]`|Facet|


### facetFunctionSelectors

Gets all the function selectors provided by a facet.


```solidity
function facetFunctionSelectors(address _facet)
    external
    view
    override
    returns (bytes4[] memory facetFunctionSelectors_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_facet`|`address`|The facet address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetFunctionSelectors_`|`bytes4[]`|facetFunctionSelectors_|


### facetAddresses

Get all the facet addresses used by a diamond.


```solidity
function facetAddresses() external view override returns (address[] memory facetAddresses_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddresses_`|`address[]`|facetAddresses_|


### facetAddress

Gets the facet that supports the given selector.

*If facet is not found return address(0).*


```solidity
function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_functionSelector`|`bytes4`|The function selector.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddress_`|`address`|The facet address.|


### supportsInterface


```solidity
function supportsInterface(bytes4 _interfaceId) external view override returns (bool);
```

