// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @author Cujo
 * @title LibKlima
 */

import "../C.sol";
import "./LibAppStorage.sol";
import "../interfaces/IKlima.sol";
import "./Token/LibApprove.sol";

library LibKlima {
    /**
     * @notice                  Returns wsKLIMA amount for provided sKLIMA amount
     * @param amount            sKLIMA provided
     * @return wrappedAmount    wsKLIMA amount
     */
    function toWrappedAmount(uint amount) internal view returns (uint wrappedAmount) {
        // @dev Account for rounding differences in wsKLIMA contract.
        return IwsKLIMA(C.wsKlima()).sKLIMATowKLIMA(amount) + 5;
    }

    /**
     * @notice                  Returns sKLIMA amount for provided wsKLIMA amount
     * @param amount            wsKLIMA provided
     * @return unwrappedAmount    sKLIMA amount
     */
    function toUnwrappedAmount(uint amount) internal view returns (uint unwrappedAmount) {
        // @dev Account for rounding differences in wsKLIMA contract.
        return IwsKLIMA(C.wsKlima()).wKLIMATosKLIMA(amount);
    }

    /**
     * @notice                  Unwraps and unstakes provided wsKLIMA amount
     * @param amount            wsKLIMA provided
     * @return unwrappedAmount    Final KLIMA amount
     */
    function unwrapKlima(uint amount) internal returns (uint unwrappedAmount) {
        unwrappedAmount = IwsKLIMA(C.wsKlima()).unwrap(amount);
        unstakeKlima(unwrappedAmount);
    }

    /**
     * @notice                  Unstakes provided sKLIMA amount
     * @param amount            sKLIMA provided
     */
    function unstakeKlima(uint amount) internal {
        IStaking(C.staking()).unstake(amount, false);
    }

    /**
     * @notice                  Stakes and wraps provided KLIMA amount
     * @param amount            KLIMA provided
     * @return wrappedAmount    Final wsKLIMA amount
     */
    function wrapKlima(uint amount) internal returns (uint wrappedAmount) {
        stakeKlima(amount);
        wrappedAmount = IwsKLIMA(C.wsKlima()).wrap(amount);
    }

    /**
     * @notice                  Stakes provided KLIMA amount
     * @param amount            KLIMA provided
     */
    function stakeKlima(uint amount) internal {
        IStakingHelper(C.stakingHelper()).stake(amount);
    }
}
