

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import  "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";


contract AlchemistKlimaUpgradeable is ERC20PresetMinterPauserUpgradeable {

    bool public allowMinting;

    constructor(){
    }

    function initialize() public initializer {
        __AlchemistKlimaUpgradeable_init();
    }

    function __AlchemistKlimaUpgradeable_init() internal {
        allowMinting = true;
        __ERC20PresetMinterPauser_init("AlchemistKlima", "alKLIMA");
    }

    function mint( address recipient_, uint256 amount_) public virtual override {
        require( allowMinting, "Minting has been disabled." );
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint( recipient_, amount_ );
    }

    function disableMinting() external returns ( bool ) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Is not Admin");
        allowMinting = false;
        return allowMinting;
    }

}
