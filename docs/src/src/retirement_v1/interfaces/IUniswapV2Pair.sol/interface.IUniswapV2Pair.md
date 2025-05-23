# IUniswapV2Pair
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/retirement_v1/interfaces/IUniswapV2Pair.sol)


## Functions
### name


```solidity
function name() external pure returns (string memory);
```

### symbol


```solidity
function symbol() external pure returns (string memory);
```

### decimals


```solidity
function decimals() external pure returns (uint8);
```

### totalSupply


```solidity
function totalSupply() external view returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address owner) external view returns (uint256);
```

### allowance


```solidity
function allowance(address owner, address spender) external view returns (uint256);
```

### approve


```solidity
function approve(address spender, uint256 value) external returns (bool);
```

### transfer


```solidity
function transfer(address to, uint256 value) external returns (bool);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 value) external returns (bool);
```

### DOMAIN_SEPARATOR


```solidity
function DOMAIN_SEPARATOR() external view returns (bytes32);
```

### PERMIT_TYPEHASH


```solidity
function PERMIT_TYPEHASH() external pure returns (bytes32);
```

### nonces


```solidity
function nonces(address owner) external view returns (uint256);
```

### permit


```solidity
function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
    external;
```

### MINIMUM_LIQUIDITY


```solidity
function MINIMUM_LIQUIDITY() external pure returns (uint256);
```

### factory


```solidity
function factory() external view returns (address);
```

### token0


```solidity
function token0() external view returns (address);
```

### token1


```solidity
function token1() external view returns (address);
```

### getReserves


```solidity
function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
```

### price0CumulativeLast


```solidity
function price0CumulativeLast() external view returns (uint256);
```

### price1CumulativeLast


```solidity
function price1CumulativeLast() external view returns (uint256);
```

### kLast


```solidity
function kLast() external view returns (uint256);
```

### mint


```solidity
function mint(address to) external returns (uint256 liquidity);
```

### burn


```solidity
function burn(address to) external returns (uint256 amount0, uint256 amount1);
```

### swap


```solidity
function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
```

### skim


```solidity
function skim(address to) external;
```

### sync


```solidity
function sync() external;
```

### initialize


```solidity
function initialize(address, address) external;
```

## Events
### Approval

```solidity
event Approval(address indexed owner, address indexed spender, uint256 value);
```

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 value);
```

### Mint

```solidity
event Mint(address indexed sender, uint256 amount0, uint256 amount1);
```

### Burn

```solidity
event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
```

### Swap

```solidity
event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
);
```

### Sync

```solidity
event Sync(uint112 reserve0, uint112 reserve1);
```

