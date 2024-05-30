//SPDX-Identifier: MIT

pragma solidity =0.8.16;

contract MockInfinity {
    event DefaultRetirement(
        address sourceToken,
        address poolToken,
        uint256 maxAmountIn,
        uint256 retireAmount,
        string retiringEntityString,
        address beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        uint8 fromMode
    );

    event SpecificRetirement(
        address sourceToken,
        address poolToken,
        address projectToken,
        uint256 maxAmountIn,
        uint256 retireAmount,
        string retiringEntityString,
        address beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        uint8 fromMode
    );

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
    ) external payable returns (uint256 retirementIndex) {
        emit DefaultRetirement(
            sourceToken,
            poolToken,
            maxAmountIn,
            retireAmount,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage,
            fromMode
        );
    }

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
    ) external payable returns (uint256 retirementIndex) {
        emit SpecificRetirement(
            sourceToken,
            poolToken,
            projectToken,
            maxAmountIn,
            retireAmount,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage,
            fromMode
        );
    }
}
