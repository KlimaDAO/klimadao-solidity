


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import  "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetFixedSupplyUpgradeable.sol";
import  "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import  "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";



contract PreKlimaTokenUpgradeable is ERC20PresetFixedSupplyUpgradeable, OwnableUpgradeable {

    using SafeMathUpgradeable for uint256;

    bool public requireSellerApproval;
    bool public allowMinting;

    mapping( address => bool ) public isApprovedSeller;

    constructor() {
        
    }
    
    function initialize(address _Klimadmin) public initializer {
        
        __PreKlimaTokenUpgradeable_init(_Klimadmin);
        
    }
    
    
    function __PreKlimaTokenUpgradeable_init(address _Klimadmin) internal {

        requireSellerApproval = true;
        allowMinting = true;
        _addApprovedSeller( address(this) );
        _addApprovedSeller( _Klimadmin );
        _addApprovedSeller(address(0x0000));
        __Ownable_init();
        __ERC20PresetFixedSupply_init("PreKlima", "pKLIMA", 1000000000 * 1e18, _Klimadmin);
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

}
