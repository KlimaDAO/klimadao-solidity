# PreKlimaTokenUpgradeableChild
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/protocol/tokens/upgradeable/PreKlimaTokenUpgradeableChild.sol)

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


### childChainManagerProxy

```solidity
address public childChainManagerProxy;
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

### initializeChild


```solidity
function initializeChild(address _Klimadmin, address _childChainManagerProxy) public initializer;
```

### __PreKlimaTokenUpgradeableChild_init


```solidity
function __PreKlimaTokenUpgradeableChild_init(address _Klimadmin, address _childChainManagerProxy)
    internal
    initializer;
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

### deposit

called when token is deposited on root chain

*Should be callable only by ChildChainManager
Should handle deposit by minting the required amount for user
Make sure minting is done only by this function*


```solidity
function deposit(address user, bytes calldata depositData) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|user address for whom deposit is being done|
|`depositData`|`bytes`|abi encoded amount|


### withdraw

called when user wants to withdraw tokens back to root chain

*Should burn user's tokens. This transaction will be verified when exiting on root chain*


```solidity
function withdraw(uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|amount of tokens to withdraw|


