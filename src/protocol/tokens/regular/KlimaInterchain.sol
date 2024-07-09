// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20, ERC20, ERC20Wrapper} from "oz/token/ERC20/extensions/ERC20Wrapper.sol";
import {ERC20Permit} from "oz/token/ERC20/extensions/ERC20Permit.sol";

import {Minter} from "@axelar-network/interchain-token-service/contracts/utils/Minter.sol";
// import {IInterchainTokenStandard} from
//     "@axelar-network/interchain-token-service/contracts/interfaces/IInterchainTokenStandard.sol";

contract KlimaInterchain is ERC20Wrapper, ERC20Permit, Minter {
    uint8 internal immutable decimals_ = 9;

    uint256 internal constant UINT256_MAX = 2 ** 256 - 1;

    constructor(string memory name_, string memory symbol_, IERC20 _underlying)
        ERC20(name_, symbol_)
        ERC20Permit(name_)
        ERC20Wrapper(_underlying)
    {
        _addMinter(msg.sender);
    }

    function decimals() public pure override(ERC20, ERC20Wrapper) returns (uint8) {
        return decimals_;
    }

    /**
     * @notice Function to mint new tokens.
     * @dev Can only be called by the minter address.
     * @param account The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address account, uint256 amount) external onlyRole(uint8(Roles.MINTER)) {
        _mint(account, amount);
    }

    /**
     * @notice Function to burn tokens.
     * @dev Can only be called by the minter address.
     * @param account The address that will have its tokens burnt.
     * @param amount The amount of tokens to burn.
     */
    function burn(address account, uint256 amount) external onlyRole(uint8(Roles.MINTER)) {
        _burn(account, amount);
    }
}
