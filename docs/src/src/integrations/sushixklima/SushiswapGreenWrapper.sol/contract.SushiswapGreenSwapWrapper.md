# SushiswapGreenSwapWrapper
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/integrations/sushixklima/SushiswapGreenWrapper.sol)

**Inherits:**
Initializable, ContextUpgradeable, OwnableUpgradeable

**Author:**
KlimaDAO

This contracts allows for a sushiswap swap to be offset in a 2nd txn triggered


## State Variables
### retirementHoldingAddress

```solidity
address payable public retirementHoldingAddress;
```


### sushiRouterMain

```solidity
address public sushiRouterMain;
```


### sushiAmountOffset

```solidity
uint public sushiAmountOffset;
```


## Functions
### initialize


```solidity
function initialize() public initializer;
```

### GreenSwapTokensForTokens

This function will do a retirement as well as a swap, while it is \
configurable, it can be pre-populated with default values from the Sushi UI


```solidity
function GreenSwapTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    public
    payable;
```

### setRetirementHoldingAddress


```solidity
function setRetirementHoldingAddress(address _newHoldingAddress) public onlyOwner;
```

### setSushiRouterMain


```solidity
function setSushiRouterMain(address _newSushiRouter) public onlyOwner;
```

### setSushiAmountOffset


```solidity
function setSushiAmountOffset(uint _newSushiAmountOffset) public onlyOwner;
```

## Events
### newRetirementHolder

```solidity
event newRetirementHolder(address newHolder);
```

### newSushiRouter

```solidity
event newSushiRouter(address newRouter);
```

### newSushiAmountOffset

```solidity
event newSushiAmountOffset(uint newAmount);
```

