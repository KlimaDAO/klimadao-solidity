// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IKlimaInfinity {
    function retireExactCarbonDefault(
        address sourceToken,
        address poolToken,
        uint256 maxAmountIn,
        uint256 retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external payable returns (uint256 retirementIndex);

    function retireExactCarbonSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint256 maxAmountIn,
        uint256 retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external payable returns (uint256 retirementIndex);

    function retireExactSourceDefault(
        address sourceToken,
        address poolToken,
        uint256 maxAmountIn,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external payable returns (uint256 retirementIndex);

    function retireExactSourceSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint256 maxAmountIn,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external payable returns (uint256 retirementIndex);

    /* Views */

    function getSourceAmountDefaultRetirement(
        address sourceToken,
        address carbonToken,
        uint256 retireAmount
    ) external view returns (uint256 amountIn);

    function getSourceAmountSpecificRetirement(
        address sourceToken,
        address carbonToken,
        uint256 retireAmount
    ) external view returns (uint256 amountIn);

    function getSourceAmountSwapOnly(
        address sourceToken,
        address carbonToken,
        uint256 amountOut
    ) external view returns (uint256 amountIn);
}
