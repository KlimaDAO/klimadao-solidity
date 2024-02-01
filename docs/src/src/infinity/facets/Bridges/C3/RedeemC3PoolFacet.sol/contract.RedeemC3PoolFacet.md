# RedeemC3PoolFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/infinity/facets/Bridges/C3/RedeemC3PoolFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md)


## Functions
### c3RedeemPoolDefault

Redeems default underlying carbon tokens from a C3 Pool


```solidity
function c3RedeemPoolDefault(
    address sourceToken,
    address poolToken,
    uint256 amount,
    uint256 maxAmountIn,
    LibTransfer.From fromMode,
    LibTransfer.To toMode
) external nonReentrant returns (address[] memory projectTokens, uint256[] memory amounts);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|     Source token to use in the redemption|
|`poolToken`|`address`|       Pool token to redeem|
|`amount`|`uint256`|          Amount to redeem|
|`maxAmountIn`|`uint256`|     Max amount of source token to spend|
|`fromMode`|`LibTransfer.From`|        From Mode for transfering tokens|
|`toMode`|`LibTransfer.To`|          To Mode for where undlerying tokens are sent|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`projectTokens`|`address[]`|  List of underlying tokens received|
|`amounts`|`uint256[]`|        Amounts of underlying tokens received|


### c3RedeemPoolSpecific

Redeems default underlying carbon tokens from a C3 Pool


```solidity
function c3RedeemPoolSpecific(
    address sourceToken,
    address poolToken,
    uint256 maxAmountIn,
    address[] memory projectTokens,
    uint256[] memory amounts,
    LibTransfer.From fromMode,
    LibTransfer.To toMode
) external nonReentrant returns (uint256[] memory redeemedAmounts);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|         Source token to use in the redemption|
|`poolToken`|`address`|           Pool token to redeem|
|`maxAmountIn`|`uint256`|         Max amount of source token to spend|
|`projectTokens`|`address[]`|       Underlying tokens to redeem|
|`amounts`|`uint256[]`|             Amounts of underlying tokens to redeem|
|`fromMode`|`LibTransfer.From`|            From Mode for transfering tokens|
|`toMode`|`LibTransfer.To`|              To Mode for where undlerying tokens are sent|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`redeemedAmounts`|`uint256[]`|    Amounts of underlying tokens redeemed|


