// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IKlimaInfinity {
    function retireExactCarbonDefault(
        address sourceToken,
        address poolToken,
        uint maxAmountIn,
        uint retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external payable returns (uint retirementIndex);

    function retireExactCarbonSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint maxAmountIn,
        uint retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external payable returns (uint retirementIndex);

    function retireExactSourceDefault(
        address sourceToken,
        address poolToken,
        uint maxAmountIn,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external payable returns (uint retirementIndex);

    function retireExactSourceSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint maxAmountIn,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external payable returns (uint retirementIndex);
    
    function getSourceAmountDefaultRetirement(
        address sourceToken,
        address carbonToken,
        uint retireAmount
    ) external view returns (uint amountIn);

    function getSourceAmountSpecificRetirement(
        address sourceToken,
        address carbonToken,
        uint retireAmount
    ) external view returns (uint amountIn);
}
