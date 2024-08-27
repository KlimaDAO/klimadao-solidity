# ITWAPOracle
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/protocol/tokens/regular/KlimaToken.sol)

*Intended to update the TWAP for a token based on accepting an update call from that token.
expectation is to have this happen in the _beforeTokenTransfer function of ERC20.
Provides a method for a token to register its price sourve adaptor.
Provides a function for a token to register its TWAP updater. Defaults to token itself.
Provides a function a tokent to set its TWAP epoch.
Implements automatic closeing and opening up a TWAP epoch when epoch ends.
Provides a function to report the TWAP from the last epoch when passed a token address.*


## Functions
### uniV2CompPairAddressForLastEpochUpdateBlockTimstamp


```solidity
function uniV2CompPairAddressForLastEpochUpdateBlockTimstamp(address) external returns (uint32);
```

### priceTokenAddressForPricingTokenAddressForLastEpochUpdateBlockTimstamp


```solidity
function priceTokenAddressForPricingTokenAddressForLastEpochUpdateBlockTimstamp(
    address tokenToPrice_,
    address tokenForPriceComparison_,
    uint256 epochPeriod_
) external returns (uint32);
```

### pricedTokenForPricingTokenForEpochPeriodForPrice


```solidity
function pricedTokenForPricingTokenForEpochPeriodForPrice(address, address, uint256) external returns (uint256);
```

### pricedTokenForPricingTokenForEpochPeriodForLastEpochPrice


```solidity
function pricedTokenForPricingTokenForEpochPeriodForLastEpochPrice(address, address, uint256)
    external
    returns (uint256);
```

### updateTWAP


```solidity
function updateTWAP(address uniV2CompatPairAddressToUpdate_, uint256 eopchPeriodToUpdate_) external returns (bool);
```

