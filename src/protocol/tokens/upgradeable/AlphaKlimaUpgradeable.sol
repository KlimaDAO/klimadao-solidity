// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ozu-4-5-1/access/OwnableUpgradeable.sol";
import "ozu-4-5-1/token/ERC20/presets/ERC20PresetFixedSupplyUpgradeable.sol";

contract AlphaKlimaUpgradeable is ERC20PresetFixedSupplyUpgradeable, OwnableUpgradeable {
    constructor() {}

    function initialize() public initializer {
        __AlphaKlimaUpgradeable_init(0x693aD12DbA5F6E07dE86FaA21098B691F60A1BEa);
    }

    function __AlphaKlimaUpgradeable_init(address _Klimadmin) internal {
        __Ownable_init();
        __ERC20PresetFixedSupply_init("AlphaKlima", "aKLIMA", 120_000 * 1e18, _Klimadmin);
    }
}
