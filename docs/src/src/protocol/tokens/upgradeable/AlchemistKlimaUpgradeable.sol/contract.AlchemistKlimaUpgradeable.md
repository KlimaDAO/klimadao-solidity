# AlchemistKlimaUpgradeable
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/protocol/tokens/upgradeable/AlchemistKlimaUpgradeable.sol)

**Inherits:**
ERC20PresetMinterPauserUpgradeable


## State Variables
### allowMinting

```solidity
bool public allowMinting;
```


## Functions
### constructor


```solidity
constructor();
```

### initialize


```solidity
function initialize() public initializer;
```

### __AlchemistKlimaUpgradeable_init


```solidity
function __AlchemistKlimaUpgradeable_init() internal;
```

### mint


```solidity
function mint(address recipient_, uint256 amount_) public virtual override;
```

### disableMinting


```solidity
function disableMinting() external returns (bool);
```

