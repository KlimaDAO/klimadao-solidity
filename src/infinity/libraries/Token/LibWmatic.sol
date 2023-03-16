/*
 SPDX-License-Identifier: MIT*/

pragma solidity ^0.8.16;

import "../../interfaces/IWMATIC.sol";
import "./LibTransfer.sol";

/**
 * @author Cujo
 * @title LibWmatic handles wrapping and unwrapping Wmatic
 * Largely inspired by Balancer's Vault
 *
 */

library LibWmatic {
    address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    function wrap(uint amount, LibTransfer.To mode) internal {
        deposit(amount);
        LibTransfer.sendToken(IERC20(WMATIC), amount, msg.sender, mode);
    }

    function unwrap(uint amount, LibTransfer.From mode) internal {
        amount = LibTransfer.receiveToken(IERC20(WMATIC), amount, msg.sender, mode);
        withdraw(amount);
        (bool success,) = msg.sender.call{value: amount}(new bytes(0));
        require(success, "Wmatic: unwrap failed");
    }

    function deposit(uint amount) private {
        IWMATIC(WMATIC).deposit{value: amount}();
    }

    function withdraw(uint amount) private {
        IWMATIC(WMATIC).withdraw(amount);
    }
}
