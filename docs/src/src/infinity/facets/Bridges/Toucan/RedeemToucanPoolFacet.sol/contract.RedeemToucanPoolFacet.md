# RedeemToucanPoolFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/facets/Bridges/Toucan/RedeemToucanPoolFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md)


## Functions
### toucanRedeemExactCarbonPoolDefault

Redeems default underlying carbon tokens from a Toucan Pool


```solidity
function toucanRedeemExactCarbonPoolDefault(
    address sourceToken,
    address poolToken,
    uint amount,
    uint maxAmountIn,
    LibTransfer.From fromMode,
    LibTransfer.To toMode
) external nonReentrant returns (address[] memory projectTokens, uint[] memory amounts);
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


### toucanRedeemExactCarbonPoolSpecific

Redeems specific underlying carbon tokens from a Toucan Pool


```solidity
function toucanRedeemExactCarbonPoolSpecific(
    address sourceToken,
    address poolToken,
    uint maxAmountIn,
    address[] memory projectTokens,
    uint[] memory amounts,
    LibTransfer.From fromMode,
    LibTransfer.To toMode
) external nonReentrant returns (uint[] memory redeemedAmounts);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|         Source token to use in the redemption|
|`poolToken`|`address`|           Pool token to redeem|
|`maxAmountIn`|`uint256`|         Maximum amount of source token to spend|
|`projectTokens`|`address[]`|       Underlying tokens to redeem|
|`amounts`|`uint256[]`|             Amounts of underlying tokens to redeem|
|`fromMode`|`LibTransfer.From`|            From Mode for transfering tokens|
|`toMode`|`LibTransfer.To`|              To Mode for where undlerying tokens are sent|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`redeemedAmounts`|`uint256[]`|    Amounts of underlying tokens redeemed|


