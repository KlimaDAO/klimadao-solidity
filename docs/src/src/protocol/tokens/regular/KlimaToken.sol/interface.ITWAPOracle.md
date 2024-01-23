# ITWAPOracle
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/tokens/regular/KlimaToken.sol)

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
    uint epochPeriod_
) external returns (uint32);
```

### pricedTokenForPricingTokenForEpochPeriodForPrice


```solidity
function pricedTokenForPricingTokenForEpochPeriodForPrice(address, address, uint) external returns (uint);
```

### pricedTokenForPricingTokenForEpochPeriodForLastEpochPrice


```solidity
function pricedTokenForPricingTokenForEpochPeriodForLastEpochPrice(address, address, uint) external returns (uint);
```

### updateTWAP


```solidity
function updateTWAP(address uniV2CompatPairAddressToUpdate_, uint eopchPeriodToUpdate_) external returns (bool);
```

