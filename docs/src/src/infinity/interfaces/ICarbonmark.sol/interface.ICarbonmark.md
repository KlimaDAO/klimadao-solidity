# ICarbonmark
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/interfaces/ICarbonmark.sol)


## Functions
### createListing

This function creates a new listing and returns the resulting listing ID


```solidity
function createListing(address token, uint256 amount, uint256 unitPrice, uint256 minFillAmount, uint256 deadline)
    external
    returns (bytes32 id);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The token being listed|
|`amount`|`uint256`|The amount to be listed|
|`unitPrice`|`uint256`|The unit price in USDC to list. Should be provided in full form so a price of 2.5 USDC = input of 2500000|
|`minFillAmount`|`uint256`|The minimum number of tons needed to be purchased to fill this listing|
|`deadline`|`uint256`|The block timestamp at which this listing will expire|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|The ID of the listing that was created|


### fillListing

This function fills an existing listing


```solidity
function fillListing(
    bytes32 id,
    address listingAccount,
    address listingToken,
    uint256 listingUnitPrice,
    uint256 amount,
    uint256 maxCost
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`id`|`bytes32`|The listing ID to update|
|`listingAccount`|`address`|The account that created the listing you are filling|
|`listingToken`|`address`|The token you are swapping for|
|`listingUnitPrice`|`uint256`|The unit price per token to fill the listing|
|`amount`|`uint256`|Amount of the listing to fill|
|`maxCost`|`uint256`|Maximum cost in USDC for filling this listing|


### getListingOwner


```solidity
function getListingOwner(bytes32 id) external view returns (address);
```

### getUnitPrice


```solidity
function getUnitPrice(bytes32 id) external view returns (uint256);
```

### getRemainingAmount


```solidity
function getRemainingAmount(bytes32 id) external view returns (uint256);
```

### getListingDeadline


```solidity
function getListingDeadline(bytes32 id) external view returns (uint256);
```

## Structs
### CreditListing
Struct containing all of the detail information needed to fill a listing


```solidity
struct CreditListing {
    bytes32 id;
    address account;
    address token;
    uint256 tokenId;
    uint256 remainingAmount;
    uint256 unitPrice;
}
```

