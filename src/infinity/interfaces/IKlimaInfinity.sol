// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

interface IKlimaInfinity {
    function toucan_retireExactCarbonPoolDefault(
        address sourceToken,
        address carbonToken,
        uint amount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function toucan_retireExactCarbonPoolWithEntityDefault(
        address sourceToken,
        address carbonToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function toucan_retireExactSourcePoolDefault(
        address sourceToken,
        address carbonToken,
        uint amount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function toucan_retireExactSourcePoolWithEntityDefault(
        address sourceToken,
        address carbonToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function toucan_retireExactCarbonPoolSpecific(
        address sourceToken,
        address carbonToken,
        address projectToken,
        uint amount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function toucan_retireExactCarbonPoolWithEntitySpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function toucan_retireExactSourcePoolWithEntitySpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint sourceAmount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function toucan_retireExactSourcePoolSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint sourceAmount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function moss_retireExactCarbonPoolDefault(
        address sourceToken,
        address carbonToken,
        uint amount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function moss_retireExactCarbonPoolWithEntityDefault(
        address sourceToken,
        address carbonToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function moss_retireExactSourcePoolDefault(
        address sourceToken,
        address carbonToken,
        uint sourceAmount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function moss_retireExactSourcePoolWithEntityDefault(
        address sourceToken,
        address carbonToken,
        uint sourceAmount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function c3_retireExactCarbonPoolDefault(
        address sourceToken,
        address carbonToken,
        uint amount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function c3_retireExactCarbonPoolWithEntityDefault(
        address sourceToken,
        address carbonToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function c3_retireExactSourcePoolDefault(
        address sourceToken,
        address carbonToken,
        uint sourceAmount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function c3_retireExactSourcePoolWithEntityDefault(
        address sourceToken,
        address carbonToken,
        uint sourceAmount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function c3_retireExactCarbonPoolSpecific(
        address sourceToken,
        address carbonToken,
        address projectToken,
        uint amount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function c3_retireExactCarbonPoolWithEntitySpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function c3_retireExactSourcePoolWithEntitySpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint sourceAmount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);

    function c3_retireExactSourcePoolSpecific(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint sourceAmount,
        address retiringAddress,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        uint8 fromMode
    ) external returns (uint retirementIndex);
}
