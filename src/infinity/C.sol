// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Cujo
 * @title C holds the constants for Klima Infinity
 */

library C {
    // Chain
    uint256 private constant CHAIN_ID = 137; // Polygon

    // Klima Protocol Contracts
    address private constant KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
    address private constant SKLIMA = 0xb0C22d8D350C67420f06F48936654f567C73E8C8;
    address private constant WSKLIMA = 0x6f370dba99E32A3cAD959b341120DB3C9E280bA6;
    address private constant STAKING = 0x25d28a24Ceb6F81015bB0b2007D795ACAc411b4d;
    address private constant STAKING_HELPER = 0x4D70a031Fc76DA6a9bC0C922101A05FA95c3A227;
    address private constant TREASURY = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;

    // Standard Swap ERC20s
    address private constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;

    // DEX Router Addresses
    address private constant SUSHI_POLYGON = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    address private constant QUICKSWAP_POLYGON = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address private constant SUSHI_BENTO = 0x0319000133d3AdA02600f0875d2cf03D442C3367;
    address private constant SUSHI_TRIDENT_POLYGON = 0xc5017BE80b4446988e8686168396289a9A62668E;

    // Marketplace contracts
    address private constant CARBONMARK = 0x6D9D36D4C4572Bd4C5F5472Ab264cD2a3f4dB85c;

    /* Carbon Pools */
    // Toucan
    address private constant BCT = address(0);
    address private constant NCT = address(0);

    // Moss
    address private constant MCO2 = address(0);

    // C3
    address private constant UBO = address(0);
    address private constant NBO = address(0);

    // Other important addresses
    address private constant TOUCAN_RETIRE_CERT = address(0);
    address private constant MOSS_CARBON_CHAIN = address(0);
    address private constant KLIMA_CARBON_RETIREMENTS = 0xe4069467D406281249AC02699f2e87dfd5819535;
    address private constant KLIMA_RETIREMENT_BOND = address(0);
    address constant TOUCAN_REGISTRY = address(0);
    address constant C3_PROJECT_FACTORY = address(0);
    address constant ICR_PROJECT_REGISTRY = 0x0B0fCaCD2336A5f000661fF5E69aA70c28fD526D;

    function toucanCert() internal pure returns (address) {
        return TOUCAN_RETIRE_CERT;
    }

    function mossCarbonChain() internal pure returns (address) {
        return MOSS_CARBON_CHAIN;
    }

    function staking() internal pure returns (address) {
        return STAKING;
    }

    function stakingHelper() internal pure returns (address) {
        return STAKING_HELPER;
    }

    function treasury() internal pure returns (address) {
        return TREASURY;
    }

    function klima() internal pure returns (address) {
        return KLIMA;
    }

    function sKlima() internal pure returns (address) {
        return SKLIMA;
    }

    function wsKlima() internal pure returns (address) {
        return WSKLIMA;
    }

    function usdc() internal pure returns (address) {
        return USDC;
    }

    function bct() internal pure returns (address) {
        return BCT;
    }

    function nct() internal pure returns (address) {
        return NCT;
    }

    function mco2() internal pure returns (address) {
        return MCO2;
    }

    function ubo() internal pure returns (address) {
        return UBO;
    }

    function nbo() internal pure returns (address) {
        return NBO;
    }

    function sushiRouter() internal pure returns (address) {
        return SUSHI_POLYGON;
    }

    function quickswapRouter() internal pure returns (address) {
        return QUICKSWAP_POLYGON;
    }

    function sushiTridentRouter() internal pure returns (address) {
        return SUSHI_TRIDENT_POLYGON;
    }

    function sushiBento() internal pure returns (address) {
        return SUSHI_BENTO;
    }

    function klimaCarbonRetirements() internal pure returns (address) {
        return KLIMA_CARBON_RETIREMENTS;
    }

    function klimaRetirementBond() internal pure returns (address) {
        return KLIMA_RETIREMENT_BOND;
    }

    function toucanRegistry() internal pure returns (address) {
        return TOUCAN_REGISTRY;
    }

    function c3ProjectFactory() internal pure returns (address) {
        return C3_PROJECT_FACTORY;
    }

    function carbonmark() internal pure returns (address) {
        return CARBONMARK;
    }

    function icrProjectRegistry() internal pure returns (address) {
        return ICR_PROJECT_REGISTRY;
    }
}
