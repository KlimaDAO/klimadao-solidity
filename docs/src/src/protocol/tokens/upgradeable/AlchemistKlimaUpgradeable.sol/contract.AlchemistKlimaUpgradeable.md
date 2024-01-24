# AlchemistKlimaUpgradeable
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/protocol/tokens/upgradeable/AlchemistKlimaUpgradeable.sol)

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

