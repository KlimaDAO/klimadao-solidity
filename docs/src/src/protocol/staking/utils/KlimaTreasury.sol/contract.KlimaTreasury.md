# KlimaTreasury
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/protocol/staking/utils/KlimaTreasury.sol)

**Inherits:**
[Ownable](/src/protocol/staking/utils/KlimaTreasury.sol/contract.Ownable.md)


## State Variables
### KLIMA

```solidity
address public KLIMA;
```


### blocksNeededForQueue

```solidity
uint256 public blocksNeededForQueue;
```


### reserveTokens

```solidity
address[] public reserveTokens;
```


### isReserveToken

```solidity
mapping(address => bool) public isReserveToken;
```


### reserveTokenQueue

```solidity
mapping(address => uint256) public reserveTokenQueue;
```


### reserveDepositors

```solidity
address[] public reserveDepositors;
```


### isReserveDepositor

```solidity
mapping(address => bool) public isReserveDepositor;
```


### reserveDepositorQueue

```solidity
mapping(address => uint256) public reserveDepositorQueue;
```


### reserveSpenders

```solidity
address[] public reserveSpenders;
```


### isReserveSpender

```solidity
mapping(address => bool) public isReserveSpender;
```


### reserveSpenderQueue

```solidity
mapping(address => uint256) public reserveSpenderQueue;
```


### liquidityTokens

```solidity
address[] public liquidityTokens;
```


### isLiquidityToken

```solidity
mapping(address => bool) public isLiquidityToken;
```


### LiquidityTokenQueue

```solidity
mapping(address => uint256) public LiquidityTokenQueue;
```


### liquidityDepositors

```solidity
address[] public liquidityDepositors;
```


### isLiquidityDepositor

```solidity
mapping(address => bool) public isLiquidityDepositor;
```


### LiquidityDepositorQueue

```solidity
mapping(address => uint256) public LiquidityDepositorQueue;
```


### bondCalculator

```solidity
mapping(address => address) public bondCalculator;
```


### reserveManagers

```solidity
address[] public reserveManagers;
```


### isReserveManager

```solidity
mapping(address => bool) public isReserveManager;
```


### ReserveManagerQueue

```solidity
mapping(address => uint256) public ReserveManagerQueue;
```


### liquidityManagers

```solidity
address[] public liquidityManagers;
```


### isLiquidityManager

```solidity
mapping(address => bool) public isLiquidityManager;
```


### LiquidityManagerQueue

```solidity
mapping(address => uint256) public LiquidityManagerQueue;
```


### debtors

```solidity
address[] public debtors;
```


### isDebtor

```solidity
mapping(address => bool) public isDebtor;
```


### debtorQueue

```solidity
mapping(address => uint256) public debtorQueue;
```


### debtorBalance

```solidity
mapping(address => uint256) public debtorBalance;
```


### rewardManagers

```solidity
address[] public rewardManagers;
```


### isRewardManager

```solidity
mapping(address => bool) public isRewardManager;
```


### rewardManagerQueue

```solidity
mapping(address => uint256) public rewardManagerQueue;
```


### sKLIMA

```solidity
address public sKLIMA;
```


### sKLIMAQueue

```solidity
uint256 public sKLIMAQueue;
```


### totalReserves

```solidity
uint256 public totalReserves;
```


### totalDebt

```solidity
uint256 public totalDebt;
```


## Functions
### constructor


```solidity
constructor(address _KLIMA, address _BCT, uint256 _blocksNeededForQueue);
```

### deposit

allow approved address to deposit an asset for KLIMA


```solidity
function deposit(uint256 _amount, address _token, uint256 _profit) external returns (uint256 send_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|
|`_token`|`address`|address|
|`_profit`|`uint256`|uint|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`send_`|`uint256`|uint|


### withdraw

allow approved address to burn KLIMA for reserves


```solidity
function withdraw(uint256 _amount, address _token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|
|`_token`|`address`|address|


### incurDebt

allow approved address to borrow reserves


```solidity
function incurDebt(uint256 _amount, address _token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|
|`_token`|`address`|address|


### repayDebtWithReserve

allow approved address to repay borrowed reserves with reserves


```solidity
function repayDebtWithReserve(uint256 _amount, address _token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|
|`_token`|`address`|address|


### repayDebtWithKLIMA

allow approved address to repay borrowed reserves with KLIMA


```solidity
function repayDebtWithKLIMA(uint256 _amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|


### manage

allow approved address to withdraw assets


```solidity
function manage(address _token, uint256 _amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|address|
|`_amount`|`uint256`|uint|


### mintRewards

send epoch reward to staking contract


```solidity
function mintRewards(address _recipient, uint256 _amount) external;
```

### excessReserves

returns excess reserves not backing tokens


```solidity
function excessReserves() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


### auditReserves

takes inventory of all tracked assets

always consolidate to recognized reserves before audit


```solidity
function auditReserves() external onlyManager;
```

### valueOf

returns KLIMA valuation of asset


```solidity
function valueOf(address _token, uint256 _amount) public view returns (uint256 value_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|address|
|`_amount`|`uint256`|uint|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`value_`|`uint256`|uint|


### queue

queue address to change boolean in mapping


```solidity
function queue(MANAGING _managing, address _address) external onlyManager returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_managing`|`MANAGING`|MANAGING|
|`_address`|`address`|address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### toggle

verify queue then set boolean in mapping


```solidity
function toggle(MANAGING _managing, address _address, address _calculator) external onlyManager returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_managing`|`MANAGING`|MANAGING|
|`_address`|`address`|address|
|`_calculator`|`address`|address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### requirements

checks requirements and returns altered structs


```solidity
function requirements(
    mapping(address => uint256) storage queue_,
    mapping(address => bool) storage status_,
    address _address
) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`queue_`|`mapping(address => uint256)`|mapping( address => uint )|
|`status_`|`mapping(address => bool)`|mapping( address => bool )|
|`_address`|`address`|address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### listContains

checks array to ensure against duplicate


```solidity
function listContains(address[] storage _list, address _token) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_list`|`address[]`|address[]|
|`_token`|`address`|address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


## Events
### Deposit

```solidity
event Deposit(address indexed token, uint256 amount, uint256 value);
```

### Withdrawal

```solidity
event Withdrawal(address indexed token, uint256 amount, uint256 value);
```

### CreateDebt

```solidity
event CreateDebt(address indexed debtor, address indexed token, uint256 amount, uint256 value);
```

### RepayDebt

```solidity
event RepayDebt(address indexed debtor, address indexed token, uint256 amount, uint256 value);
```

### ReservesManaged

```solidity
event ReservesManaged(address indexed token, uint256 amount);
```

### ReservesUpdated

```solidity
event ReservesUpdated(uint256 indexed totalReserves);
```

### ReservesAudited

```solidity
event ReservesAudited(uint256 indexed totalReserves);
```

### RewardsMinted

```solidity
event RewardsMinted(address indexed caller, address indexed recipient, uint256 amount);
```

### ChangeQueued

```solidity
event ChangeQueued(MANAGING indexed managing, address queued);
```

### ChangeActivated

```solidity
event ChangeActivated(MANAGING indexed managing, address activated, bool result);
```

## Enums
### MANAGING

```solidity
enum MANAGING {
    RESERVEDEPOSITOR,
    RESERVESPENDER,
    RESERVETOKEN,
    RESERVEMANAGER,
    LIQUIDITYDEPOSITOR,
    LIQUIDITYTOKEN,
    LIQUIDITYMANAGER,
    DEBTOR,
    REWARDMANAGER,
    SKLIMA
}
```

