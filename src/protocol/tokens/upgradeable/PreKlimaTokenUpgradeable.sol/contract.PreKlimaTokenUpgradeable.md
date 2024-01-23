# PreKlimaTokenUpgradeable
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/tokens/upgradeable/PreKlimaTokenUpgradeable.sol)

**Inherits:**
ERC20PresetFixedSupplyUpgradeable, OwnableUpgradeable


## State Variables
### requireSellerApproval

```solidity
bool public requireSellerApproval;
```


### allowMinting

```solidity
bool public allowMinting;
```


### isApprovedSeller

```solidity
mapping(address => bool) public isApprovedSeller;
```


## Functions
### constructor


```solidity
constructor();
```

### initialize


```solidity
function initialize(address _Klimadmin) public initializer;
```

### __PreKlimaTokenUpgradeable_init


```solidity
function __PreKlimaTokenUpgradeable_init(address _Klimadmin) internal;
```

### allowOpenTrading


```solidity
function allowOpenTrading() external onlyOwner returns (bool);
```

### disableMinting


```solidity
function disableMinting() external onlyOwner returns (bool);
```

### _addApprovedSeller


```solidity
function _addApprovedSeller(address approvedSeller_) internal;
```

### addApprovedSeller


```solidity
function addApprovedSeller(address approvedSeller_) external onlyOwner returns (bool);
```

### addApprovedSellers


```solidity
function addApprovedSellers(address[] calldata approvedSellers_) external onlyOwner returns (bool);
```

### _removeApprovedSeller


```solidity
function _removeApprovedSeller(address disapprovedSeller_) internal;
```

### removeApprovedSeller


```solidity
function removeApprovedSeller(address disapprovedSeller_) external onlyOwner returns (bool);
```

### removeApprovedSellers


```solidity
function removeApprovedSellers(address[] calldata disapprovedSellers_) external onlyOwner returns (bool);
```

### _beforeTokenTransfer


```solidity
function _beforeTokenTransfer(address from_, address to_, uint256 amount_) internal override;
```

### mint


```solidity
function mint(address recipient_, uint256 amount_) public virtual onlyOwner;
```

