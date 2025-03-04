// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "./AppStorage.sol";

/**
 * @author Beanstalk Farms
 * @title Variation of Oepn Zeppelins reentrant guard to include Silo Update
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts%2Fsecurity%2FReentrancyGuard.sol
 *
 */
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _FUNC_ONLY_ENTERED = 2;
    uint256 private constant _BATCH_ONLY_ENTERED = 3;
    uint256 private constant _BATCH_AND_FUNC_ENTERED = 4;

    AppStorage internal s;

    /** Handles non reentrance for single retirement transactions */
    modifier nonReentrant() {
        require(s.reentrantStatus != _FUNC_ONLY_ENTERED && s.reentrantStatus != _BATCH_AND_FUNC_ENTERED, "ReentrancyGuard: reentrant call");
        if (s.reentrantStatus == _NOT_ENTERED) s.reentrantStatus = _FUNC_ONLY_ENTERED;
        else if (s.reentrantStatus == _BATCH_ONLY_ENTERED) s.reentrantStatus = _BATCH_AND_FUNC_ENTERED;
        _;
        if (s.reentrantStatus == _FUNC_ONLY_ENTERED) s.reentrantStatus = _NOT_ENTERED;
        else if (s.reentrantStatus == _BATCH_AND_FUNC_ENTERED) s.reentrantStatus = _BATCH_ONLY_ENTERED;
    }

    /** Handles non reentrance for batch retirements transactions */
    modifier nonBatchReentrant() {
        require(s.reentrantStatus == _NOT_ENTERED, "BatchReentrancyGuard: reentrant call");
        s.reentrantStatus = _BATCH_ONLY_ENTERED;
        _;
        s.reentrantStatus = _NOT_ENTERED;
    }
}
