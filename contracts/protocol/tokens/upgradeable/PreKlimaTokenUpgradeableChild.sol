


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import  "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetFixedSupplyUpgradeable.sol";
import  "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import  "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";



contract PreKlimaTokenUpgradeableChild is ERC20PresetFixedSupplyUpgradeable, OwnableUpgradeable {

    using SafeMathUpgradeable for uint256;

    bool public requireSellerApproval;
    bool public allowMinting;

    // Matic childChainManager
    address public childChainManagerProxy;

    mapping( address => bool ) public isApprovedSeller;

    constructor() {
        
    }
    
    function initializeChild(address _Klimadmin, address _childChainManagerProxy) public initializer {
        
        __PreKlimaTokenUpgradeableChild_init(_Klimadmin, _childChainManagerProxy);
        
    }
    
    
    function __PreKlimaTokenUpgradeableChild_init(address _Klimadmin, address _childChainManagerProxy) internal initializer {
        require(_childChainManagerProxy != address(0), "_childChainManagerProxy must not be null");
        requireSellerApproval = true;
        allowMinting = true;
        _addApprovedSeller( address(this) );
        _addApprovedSeller( _Klimadmin );
        _addApprovedSeller(address(0x0000));
        _addApprovedSeller(_childChainManagerProxy);
        __Ownable_init();
        childChainManagerProxy = _childChainManagerProxy;
        __ERC20PresetFixedSupply_init("PreKlima (POS)", "pKLIMA", 0 * 1e18, _Klimadmin);
    }

    function allowOpenTrading() external onlyOwner() returns ( bool ) {
        requireSellerApproval = false;
        return requireSellerApproval;
    }

    function disableMinting() external onlyOwner() returns ( bool ) {
        allowMinting = false;
        return allowMinting;
    }

    function _addApprovedSeller( address approvedSeller_ ) internal {
        isApprovedSeller[approvedSeller_] = true;
    }

    function addApprovedSeller( address approvedSeller_ ) external onlyOwner() returns ( bool ) {
        _addApprovedSeller( approvedSeller_ );
        return isApprovedSeller[approvedSeller_];
    }

    function addApprovedSellers( address[] calldata approvedSellers_ ) external onlyOwner() returns ( bool ) {

        for( uint256 iteration_; approvedSellers_.length > iteration_; iteration_++ ) {
            _addApprovedSeller( approvedSellers_[iteration_] );
        }
        return true;
    }

    function _removeApprovedSeller( address disapprovedSeller_ ) internal {
        isApprovedSeller[disapprovedSeller_] = false;
    }

    function removeApprovedSeller( address disapprovedSeller_ ) external onlyOwner() returns ( bool ) {
        _removeApprovedSeller( disapprovedSeller_ );
        return isApprovedSeller[disapprovedSeller_];
    }

    function removeApprovedSellers( address[] calldata disapprovedSellers_ ) external onlyOwner() returns ( bool ) {

        for( uint256 iteration_; disapprovedSellers_.length > iteration_; iteration_++ ) {
            _removeApprovedSeller( disapprovedSellers_[iteration_] );
        }
        return true;
    }
    function _beforeTokenTransfer(address from_, address to_, uint256 amount_ ) internal override {
        require( (balanceOf(to_) > 0 || isApprovedSeller[from_] == true || !requireSellerApproval), "Account not approved to transfer pKLIMA." );
    }

    function mint( address recipient_, uint256 amount_) public virtual onlyOwner() {
        require( allowMinting, "Minting has been disabled." );
        _mint( recipient_, amount_ );
    }

    /**
  * @notice called when token is deposited on root chain
  * @dev Should be callable only by ChildChainManager
  * Should handle deposit by minting the required amount for user
  * Make sure minting is done only by this function
  * @param user user address for whom deposit is being done
  * @param depositData abi encoded amount
  */
    function deposit(address user, bytes calldata depositData)
    external
    {
        require(_msgSender() == childChainManagerProxy, "You're not allowed to deposit");

        uint256 amount = abi.decode(depositData, (uint256));
        _mint(user, amount);
    }

    /**
      * @notice called when user wants to withdraw tokens back to root chain
      * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
      * @param amount amount of tokens to withdraw
      */
    function withdraw(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

}
