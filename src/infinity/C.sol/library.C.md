# C
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/C.sol)

**Author:**
Cujo


## State Variables
### CHAIN_ID

```solidity
uint256 private constant CHAIN_ID = 137;
```


### KLIMA

```solidity
address private constant KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
```


### SKLIMA

```solidity
address private constant SKLIMA = 0xb0C22d8D350C67420f06F48936654f567C73E8C8;
```


### WSKLIMA

```solidity
address private constant WSKLIMA = 0x6f370dba99E32A3cAD959b341120DB3C9E280bA6;
```


### STAKING

```solidity
address private constant STAKING = 0x25d28a24Ceb6F81015bB0b2007D795ACAc411b4d;
```


### STAKING_HELPER

```solidity
address private constant STAKING_HELPER = 0x4D70a031Fc76DA6a9bC0C922101A05FA95c3A227;
```


### TREASURY

```solidity
address private constant TREASURY = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
```


### USDC

```solidity
address private constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
```


### SUSHI_POLYGON

```solidity
address private constant SUSHI_POLYGON = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
```


### QUICKSWAP_POLYGON

```solidity
address private constant QUICKSWAP_POLYGON = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
```


### SUSHI_BENTO

```solidity
address private constant SUSHI_BENTO = 0x0319000133d3AdA02600f0875d2cf03D442C3367;
```


### SUSHI_TRIDENT_POLYGON

```solidity
address private constant SUSHI_TRIDENT_POLYGON = 0xc5017BE80b4446988e8686168396289a9A62668E;
```


### CARBONMARK

```solidity
address private constant CARBONMARK = 0x7B51dBc2A8fD98Fe0924416E628D5755f57eB821;
```


### BCT

```solidity
address private constant BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
```


### NCT

```solidity
address private constant NCT = 0xD838290e877E0188a4A44700463419ED96c16107;
```


### MCO2

```solidity
address private constant MCO2 = 0xAa7DbD1598251f856C12f63557A4C4397c253Cea;
```


### UBO

```solidity
address private constant UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
```


### NBO

```solidity
address private constant NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;
```


### TOUCAN_RETIRE_CERT

```solidity
address private constant TOUCAN_RETIRE_CERT = 0x5e377f16E4ec6001652befD737341a28889Af002;
```


### MOSS_CARBON_CHAIN

```solidity
address private constant MOSS_CARBON_CHAIN = 0xeDAEFCf60e12Bd331c092341D5b3d8901C1c05A8;
```


### KLIMA_CARBON_RETIREMENTS

```solidity
address private constant KLIMA_CARBON_RETIREMENTS = 0xac298CD34559B9AcfaedeA8344a977eceff1C0Fd;
```


### KLIMA_RETIREMENT_BOND

```solidity
address private constant KLIMA_RETIREMENT_BOND = 0xa595f0d598DaF144e5a7ca91E6D9A5bAA09dDeD0;
```


### TOUCAN_REGISTRY

```solidity
address constant TOUCAN_REGISTRY = 0x263fA1c180889b3a3f46330F32a4a23287E99FC9;
```


### C3_PROJECT_FACTORY

```solidity
address constant C3_PROJECT_FACTORY = 0xa4c951B30952f5E2feFC8a92F4d3c7551925A63B;
```


### ICR_PROJECT_REGISTRY

```solidity
address constant ICR_PROJECT_REGISTRY = 0x9f87988FF45E9b58ae30fA1685088460125a7d8A;
```


## Functions
### toucanCert


```solidity
function toucanCert() internal pure returns (address);
```

### mossCarbonChain


```solidity
function mossCarbonChain() internal pure returns (address);
```

### staking


```solidity
function staking() internal pure returns (address);
```

### stakingHelper


```solidity
function stakingHelper() internal pure returns (address);
```

### treasury


```solidity
function treasury() internal pure returns (address);
```

### klima


```solidity
function klima() internal pure returns (address);
```

### sKlima


```solidity
function sKlima() internal pure returns (address);
```

### wsKlima


```solidity
function wsKlima() internal pure returns (address);
```

### usdc


```solidity
function usdc() internal pure returns (address);
```

### bct


```solidity
function bct() internal pure returns (address);
```

### nct


```solidity
function nct() internal pure returns (address);
```

### mco2


```solidity
function mco2() internal pure returns (address);
```

### ubo


```solidity
function ubo() internal pure returns (address);
```

### nbo


```solidity
function nbo() internal pure returns (address);
```

### sushiRouter


```solidity
function sushiRouter() internal pure returns (address);
```

### quickswapRouter


```solidity
function quickswapRouter() internal pure returns (address);
```

### sushiTridentRouter


```solidity
function sushiTridentRouter() internal pure returns (address);
```

### sushiBento


```solidity
function sushiBento() internal pure returns (address);
```

### klimaCarbonRetirements


```solidity
function klimaCarbonRetirements() internal pure returns (address);
```

### klimaRetirementBond


```solidity
function klimaRetirementBond() internal pure returns (address);
```

### toucanRegistry


```solidity
function toucanRegistry() internal pure returns (address);
```

### c3ProjectFactory


```solidity
function c3ProjectFactory() internal pure returns (address);
```

### carbonmark


```solidity
function carbonmark() internal pure returns (address);
```

### icrProjectRegistry


```solidity
function icrProjectRegistry() internal pure returns (address);
```

