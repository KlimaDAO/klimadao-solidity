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
    address private constant CARBONMARK = 0x7B51dBc2A8fD98Fe0924416E628D5755f57eB821;

    /* Carbon Pools */
    // Toucan
    address private constant BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
    address private constant NCT = 0xD838290e877E0188a4A44700463419ED96c16107;

    // Moss
    address private constant MCO2 = 0xAa7DbD1598251f856C12f63557A4C4397c253Cea;

    // C3
    address private constant UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
    address private constant NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;

    // Other important addresses
    address private constant TOUCAN_RETIRE_CERT = 0x5e377f16E4ec6001652befD737341a28889Af002;
    address private constant MOSS_CARBON_CHAIN = 0xeDAEFCf60e12Bd331c092341D5b3d8901C1c05A8;
    address private constant KLIMA_CARBON_RETIREMENTS = 0xac298CD34559B9AcfaedeA8344a977eceff1C0Fd;
    address private constant KLIMA_RETIREMENT_BOND = 0xa595f0d598DaF144e5a7ca91E6D9A5bAA09dDeD0;
    address constant TOUCAN_REGISTRY = 0x263fA1c180889b3a3f46330F32a4a23287E99FC9;
    address constant C3_PROJECT_FACTORY = 0xa4c951B30952f5E2feFC8a92F4d3c7551925A63B;
    address constant ICR_PROJECT_REGISTRY = 0x9f87988FF45E9b58ae30fA1685088460125a7d8A;

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
