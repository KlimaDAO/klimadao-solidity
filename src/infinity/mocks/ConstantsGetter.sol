// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Cujo
 * @title Constants Getter helps pull values for tests
 */

import "../C.sol";

contract ConstantsGetter {
    function toucanCert() external pure returns (address) {
        return C.toucanCert();
    }

    function mossCarbonChain() external pure returns (address) {
        return C.mossCarbonChain();
    }

    function staking() external pure returns (address) {
        return C.staking();
    }

    function stakingHelper() external pure returns (address) {
        return C.stakingHelper();
    }

    function treasury() external pure returns (address) {
        return C.treasury();
    }

    function klima() external pure returns (address) {
        return C.klima();
    }

    function sKlima() external pure returns (address) {
        return C.sKlima();
    }

    function wsKlima() external pure returns (address) {
        return C.wsKlima();
    }

    function usdc() external pure returns (address) {
        return C.usdc();
    }

    function bct() external pure returns (address) {
        return C.bct();
    }

    function nct() external pure returns (address) {
        return C.nct();
    }

    function mco2() external pure returns (address) {
        return C.mco2();
    }

    function ubo() external pure returns (address) {
        return C.ubo();
    }

    function nbo() external pure returns (address) {
        return C.nbo();
    }

    function sushiRouter() external pure returns (address) {
        return C.sushiRouter();
    }

    function quickswapRouter() external pure returns (address) {
        return C.quickswapRouter();
    }

    function sushiTridentRouter() external pure returns (address) {
        return C.sushiTridentRouter();
    }

    function sushiBento() external pure returns (address) {
        return C.sushiBento();
    }

    function klimaCarbonRetirements() external pure returns (address) {
        return C.klimaCarbonRetirements();
    }

    function klimaRetirementBond() external pure returns (address) {
        return C.klimaRetirementBond();
    }

    function carbonmark() external pure returns (address) {
        return C.carbonmark();
    }
}
