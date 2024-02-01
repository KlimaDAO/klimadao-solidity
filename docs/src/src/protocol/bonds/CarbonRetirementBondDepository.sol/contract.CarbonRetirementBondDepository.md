# CarbonRetirementBondDepository
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/protocol/bonds/CarbonRetirementBondDepository.sol)

**Inherits:**
Ownable2Step

**Author:**
Cujo

A smart contract that handles the distribution of carbon in exchange for KLIMA tokens.
Bond depositors can only use this to retire carbon by providing KLIMA tokens.


## State Variables
### KLIMA
Address of the KLIMA token contract.


```solidity
address public constant KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
```


### DAO
Address of the DAO multi-sig.


```solidity
address public constant DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;
```


### TREASURY
Address of the Treasury contract.


```solidity
address public constant TREASURY = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
```


### INFINITY
address of the Klima Infinity contract.


```solidity
address public constant INFINITY = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;
```


### FEE_DIVISOR
Divisor used for calculating percentages.


```solidity
uint256 public constant FEE_DIVISOR = 10_000;
```


### allocatorContract
Allocator contract used by policy to fund and close markets.


```solidity
address public allocatorContract;
```


### poolReference
Mapping that stores the KLIMA/X LP used for quoting price references.


```solidity
mapping(address => address) public poolReference;
```


### referenceKlimaPosition
Mapping that stores whether the KLIMA is token 0 or token 1 in the LP contract.


```solidity
mapping(address => uint8) public referenceKlimaPosition;
```


### daoFee
Mapping that stores the DAO fee charged for a specific pool token.


```solidity
mapping(address => uint256) public daoFee;
```


### maxSlippage
Mapping that stores the maximum slippage tolerated for a specific pool token.


```solidity
mapping(address => uint256) public maxSlippage;
```


## Functions
### onlyAllocator

Modifier to ensure that the calling function is being called by the allocator contract.


```solidity
modifier onlyAllocator();
```

### swapToExact

Swaps the specified amount of pool tokens for KLIMA tokens.

*Only callable by the Infinity contract.*


```solidity
function swapToExact(address poolToken, uint256 poolAmount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|    The pool token address.|
|`poolAmount`|`uint256`|   The amount of pool tokens to swap.|


### retireCarbonDefault

Retires the specified amount of carbon for the given pool token using KI.

*Requires KLIMA spend approval for the amount returned by getKlimaAmount()*


```solidity
function retireCarbonDefault(
    address poolToken,
    uint256 retireAmount,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) external returns (uint256 retirementIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|            The pool token address.|
|`retireAmount`|`uint256`|         The amount of carbon to retire.|
|`retiringEntityString`|`string`| The string representing the retiring entity.|
|`beneficiaryAddress`|`address`|   The address of the beneficiary.|
|`beneficiaryString`|`string`|    The string representing the beneficiary.|
|`retirementMessage`|`string`|    The message for the retirement.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`retirementIndex`|`uint256`|     The index of the retirement transaction.|


### retireCarbonSpecific

Retires the specified amount of carbon for the given pool token using KI.
Uses the provided project token for the underlying credit to retire.

*Requires KLIMA spend approval for the amount returned by getKlimaAmount()*


```solidity
function retireCarbonSpecific(
    address poolToken,
    address projectToken,
    uint256 retireAmount,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) external returns (uint256 retirementIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|            The pool token address.|
|`projectToken`|`address`|         The project token to retire.|
|`retireAmount`|`uint256`|         The amount of carbon to retire.|
|`retiringEntityString`|`string`| The string representing the retiring entity.|
|`beneficiaryAddress`|`address`|   The address of the beneficiary.|
|`beneficiaryString`|`string`|    The string representing the beneficiary.|
|`retirementMessage`|`string`|    The message for the retirement.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`retirementIndex`|`uint256`|     The index of the retirement transaction.|


### openMarket

Emits event on market allocation.

*Only the allocator contract can call this function.*


```solidity
function openMarket(address poolToken) external onlyAllocator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|The address of the pool token to open the market for.|


### closeMarket

Closes the market for a specified pool token by transferring all remaining pool tokens to the treasury address.

*Only the allocator contract can call this function.*


```solidity
function closeMarket(address poolToken) external onlyAllocator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|The address of the pool token to close the market for.|


### updateMaxSlippage

Updates the maximum slippage percentage for a specified pool token.


```solidity
function updateMaxSlippage(address poolToken, uint256 _maxSlippage) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|The address of the pool token to update the maximum slippage percentage for.|
|`_maxSlippage`|`uint256`|The new maximum slippage percentage.|


### updateDaoFee

Updates the DAO fee for a specified pool token.


```solidity
function updateDaoFee(address poolToken, uint256 _daoFee) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|The address of the pool token to update the DAO fee for.|
|`_daoFee`|`uint256`|The new DAO fee.|


### setPoolReference

Sets the reference token for a given pool token. The reference token is used to determine the current price
of the pool token in terms of KLIMA. The position of KLIMA in the Uniswap pair for the reference token is also determined.


```solidity
function setPoolReference(address poolToken, address referenceToken) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|        The pool token for which to set the reference token.|
|`referenceToken`|`address`|   The reference token for the given pool token.|


### setAllocator

Sets the address of the allocator contract. Only the contract owner can call this function.


```solidity
function setAllocator(address allocator) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`allocator`|`address`|The address of the allocator contract to set.|


### getKlimaAmount

Calculates the amount of KLIMA tokens needed to retire a specified amount of pool tokens for a pool.
The required amount of KLIMA tokens is calculated based on the current market price of the pool token and the amount of pool tokens to be retired.
If the raw amount needed from the dex exceeds slippage, than the limited amount is returned.


```solidity
function getKlimaAmount(uint256 poolAmount, address poolToken) public view returns (uint256 klimaNeeded);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolAmount`|`uint256`|   The amount of pool tokens to retire.|
|`poolToken`|`address`|    The address of the pool token to retire.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`klimaNeeded`|`uint256`|The amount of KLIMA tokens needed to retire the specified amount of pool tokens.|


### _transferAndBurnKlima

Transfers and burns a specified amount of KLIMA tokens.
A fee is also transferred to the DAO address based on the fee divisor and the configured fee for the pool token.

*On extremely small quote amounts this can result in zero*


```solidity
function _transferAndBurnKlima(uint256 totalKlima, address poolToken) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`totalKlima`|`uint256`|   The total amount of KLIMA tokens to transfer and burn.|
|`poolToken`|`address`|    The address of the pool token to burn KLIMA tokens for.|


### getMarketQuote

Returns the current market price of the pool token in terms of KLIMA tokens.

*Currently all KLIMA LP contracts safely interact with the IUniswapV2Pair abi.*


```solidity
function getMarketQuote(address poolToken, uint256 amountOut) internal view returns (uint256 currentPrice);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|The address of the pool token to get the market quote for.|
|`amountOut`|`uint256`|The amount of pool tokens to get the market quote for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`currentPrice`|`uint256`|The current market price of the pool token in terms of KLIMA tokens.|


## Events
### AllocatorChanged

```solidity
event AllocatorChanged(address oldAllocator, address newAllocator);
```

### PoolReferenceChanged

```solidity
event PoolReferenceChanged(address pool, address oldLp, address newLp);
```

### ReferenceKlimaPositionChanged

```solidity
event ReferenceKlimaPositionChanged(address lp, uint8 oldPosition, uint8 newPosition);
```

### DaoFeeChanged

```solidity
event DaoFeeChanged(address pool, uint256 oldFee, uint256 newFee);
```

### PoolSlippageChanged

```solidity
event PoolSlippageChanged(address pool, uint256 oldSlippage, uint256 newSlippage);
```

### MarketOpened

```solidity
event MarketOpened(address pool, uint256 amount);
```

### MarketClosed

```solidity
event MarketClosed(address pool, uint256 amount);
```

### CarbonBonded

```solidity
event CarbonBonded(address pool, uint256 poolAmount);
```

### KlimaBonded

```solidity
event KlimaBonded(uint256 daoFee, uint256 klimaBurned);
```

