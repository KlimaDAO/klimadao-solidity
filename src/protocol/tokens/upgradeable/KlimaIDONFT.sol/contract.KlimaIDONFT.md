# KlimaIDONFT
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/tokens/upgradeable/KlimaIDONFT.sol)

**Inherits:**
Initializable, ContextUpgradeable, AccessControlEnumerableUpgradeable, ERC721EnumerableUpgradeable, ERC721BurnableUpgradeable, ERC721PausableUpgradeable


## State Variables
### MINTER_ROLE

```solidity
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
```


### PAUSER_ROLE

```solidity
bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
```


### _tokenIdTracker

```solidity
CountersUpgradeable.Counter private _tokenIdTracker;
```


### _baseTokenURI

```solidity
string private _baseTokenURI;
```


### __gap

```solidity
uint256[48] private __gap;
```


## Functions
### onlyMinter


```solidity
modifier onlyMinter();
```

### onlyPauser


```solidity
modifier onlyPauser();
```

### constructor


```solidity
constructor();
```

### __KlimaIDONFT_init


```solidity
function __KlimaIDONFT_init(string memory name, string memory symbol, string memory _TokenURI) public initializer;
```

### setTokenURI


```solidity
function setTokenURI(string memory _TokenURI) public onlyMinter;
```

### _setTokenURI


```solidity
function _setTokenURI(string memory _TokenURI) internal;
```

### tokenURI


```solidity
function tokenURI() public view returns (string memory);
```

### totalSupply


```solidity
function totalSupply() public view override returns (uint256);
```

### burn


```solidity
function burn(uint256 tokenId) public override;
```

### _burn


```solidity
function _burn(uint256 tokenId) internal virtual override(ERC721Upgradeable);
```

### mint


```solidity
function mint(address to) public onlyMinter whenPaused;
```

### batchMint


```solidity
function batchMint(address[] memory _list) public onlyMinter whenPaused;
```

### pause


```solidity
function pause() public virtual onlyPauser;
```

### unpause


```solidity
function unpause() public virtual onlyPauser;
```

### _beforeTokenTransfer


```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    virtual
    override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721PausableUpgradeable);
```

### supportsInterface

*See [IERC165-supportsInterface](/lib/openzeppelin-contracts-4-5-0/certora/harnesses/WizardControlFirstPriority.sol/contract.WizardControlFirstPriority.md#supportsinterface).*


```solidity
function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControlEnumerableUpgradeable, ERC721Upgradeable, ERC721EnumerableUpgradeable)
    returns (bool);
```

