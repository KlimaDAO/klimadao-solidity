# IUniswapV2Pair
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/interfaces/IUniswapV2Pair.sol)


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
function totalSupply() external view returns (uint);
```

### balanceOf


```solidity
function balanceOf(address owner) external view returns (uint);
```

### allowance


```solidity
function allowance(address owner, address spender) external view returns (uint);
```

### approve


```solidity
function approve(address spender, uint value) external returns (bool);
```

### transfer


```solidity
function transfer(address to, uint value) external returns (bool);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint value) external returns (bool);
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
function nonces(address owner) external view returns (uint);
```

### permit


```solidity
function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
```

### MINIMUM_LIQUIDITY


```solidity
function MINIMUM_LIQUIDITY() external pure returns (uint);
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
function price0CumulativeLast() external view returns (uint);
```

### price1CumulativeLast


```solidity
function price1CumulativeLast() external view returns (uint);
```

### kLast


```solidity
function kLast() external view returns (uint);
```

### mint


```solidity
function mint(address to) external returns (uint liquidity);
```

### burn


```solidity
function burn(address to) external returns (uint amount0, uint amount1);
```

### swap


```solidity
function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
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
event Approval(address indexed owner, address indexed spender, uint value);
```

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint value);
```

### Mint

```solidity
event Mint(address indexed sender, uint amount0, uint amount1);
```

### Burn

```solidity
event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
```

### Swap

```solidity
event Swap(
    address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to
);
```

### Sync

```solidity
event Sync(uint112 reserve0, uint112 reserve1);
```

