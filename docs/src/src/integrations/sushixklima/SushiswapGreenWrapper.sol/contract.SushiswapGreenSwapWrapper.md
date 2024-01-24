# SushiswapGreenSwapWrapper
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/integrations/sushixklima/SushiswapGreenWrapper.sol)

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
uint256 public sushiAmountOffset;
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
function GreenSwapTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) public payable;
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
function setSushiAmountOffset(uint256 _newSushiAmountOffset) public onlyOwner;
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
event newSushiAmountOffset(uint256 newAmount);
```

