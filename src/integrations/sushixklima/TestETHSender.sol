// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract testETHSender {
    address payable public retirementHolderAddress;
    uint256 public sushiAmountOffset;

    constructor(address retirementHolder, uint256 sushiAmount) {
        retirementHolderAddress = payable(retirementHolder);
        sushiAmountOffset = sushiAmount;
    }

    function sendETHToHolder(address payable _to) public payable {
        require(msg.value >= 1 ether, "not enough eth sent");
        (bool sent, bytes memory data) = retirementHolderAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        //retirementHolderAddress.send(msg.value);
    }
}
