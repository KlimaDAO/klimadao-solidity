// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

contract KlimaIDONFT is
Initializable, ContextUpgradeable,
AccessControlEnumerableUpgradeable,
ERC721EnumerableUpgradeable,
ERC721BurnableUpgradeable,
ERC721PausableUpgradeable
{

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, _msgSender()), "Minter: caller does not have the the minter role");
        _;
    }
    
    modifier onlyPauser(){
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _;
    }
    
    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    



    CountersUpgradeable.Counter private _tokenIdTracker;
    
    string private _baseTokenURI;



    constructor() {

    }

    function __KlimaIDONFT_init(
        string memory name,
        string memory symbol,
        string memory _TokenURI
    ) initializer public {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
        __ERC721_init_unchained(name, symbol);
        __ERC721Enumerable_init_unchained();
        __ERC721Burnable_init_unchained();
        __Pausable_init_unchained();
        __ERC721Pausable_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setTokenURI(_TokenURI);
    }


    function setTokenURI(string memory _TokenURI) onlyMinter public {
        _baseTokenURI = _TokenURI;

    }
    function _setTokenURI(string memory _TokenURI) internal {
        _baseTokenURI = _TokenURI;

    }
    function tokenURI() public view returns (string memory){
        return _baseTokenURI;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _tokenIdTracker.current();
    }


    function burn(uint256 tokenId) public override{
        ERC721Upgradeable._burn(tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override(ERC721Upgradeable){
        ERC721Upgradeable._burn(tokenId);
    }
    

    function mint(address to) public onlyMinter whenPaused {
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        ERC721Upgradeable._mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }
    
    function batchMint(address [] memory _list) public onlyMinter whenPaused {
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        require(_list.length <= 255, "Max 255 addresses at once");
        
        for (uint8 i = 0; i < _list.length; i++) {
            ERC721Upgradeable._mint(_list[i], _tokenIdTracker.current());
            _tokenIdTracker.increment();
        }
    
    }

    function pause() public virtual onlyPauser {
        _pause();
    }

    function unpause() public virtual onlyPauser{
        _unpause();
    }
    
   function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721PausableUpgradeable) {
        
        if(hasRole(MINTER_ROLE, _msgSender())){
            ERC721Upgradeable._beforeTokenTransfer(from,to,tokenId);
        }
        else
        {
            ERC721PausableUpgradeable._beforeTokenTransfer(from, to, tokenId);
        }
    }
    

    /**
 * @dev See {IERC165-supportsInterface}.
 */
    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControlEnumerableUpgradeable, ERC721Upgradeable, ERC721EnumerableUpgradeable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    uint256[48] private __gap;


}
