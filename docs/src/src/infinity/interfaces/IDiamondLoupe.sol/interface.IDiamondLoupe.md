# IDiamondLoupe
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/interfaces/IDiamondLoupe.sol)

\
Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/*****************************************************************************


## Functions
### facets

Gets all facet addresses and their four byte function selectors.


```solidity
function facets() external view returns (Facet[] memory facets_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facets_`|`Facet[]`|Facet|


### facetFunctionSelectors

Gets all the function selectors supported by a specific facet.


```solidity
function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);
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
function facetAddresses() external view returns (address[] memory facetAddresses_);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddresses_`|`address[]`|facetAddresses_|


### facetAddress

Gets the facet that supports the given selector.

*If facet is not found return address(0).*


```solidity
function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_functionSelector`|`bytes4`|The function selector.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`facetAddress_`|`address`|The facet address.|


## Structs
### Facet
These functions are expected to be called frequently
by tools.


```solidity
struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
}
```

