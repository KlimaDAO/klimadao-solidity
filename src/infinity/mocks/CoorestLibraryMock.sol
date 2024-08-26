pragma solidity ^0.8.16;

import {LibCoorestCarbon} from "../../infinity/libraries/Bridges/LibCoorestCarbon.sol";

contract CoorestLibraryMock {
    function getSpecificRetirementFee(address carbonToken, uint256 amount) public returns (uint256) {
        return LibCoorestCarbon.getSpecificRetirementFee(carbonToken, amount);
    }
}
