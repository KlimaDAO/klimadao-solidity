// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/infinity/C.sol";
import "../src/infinity/libraries/LibAppStorage.sol";

/**
 * @title IntrospectCurrentSwapPaths
 * @notice Test/script to introspect current swap paths on Polygon mainnet
 * @dev Run with: forge test --match-test testIntrospectSwapPaths --rpc-url polygon -vv
 */
contract IntrospectCurrentSwapPaths is Test {
    address constant DIAMOND = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;

    // We'll use this helper to access storage
    AppStorage s;

    function setUp() public {
        // Fork Polygon mainnet
        // Note: This will be done via --rpc-url polygon flag
    }

    function testIntrospectSwapPaths() public {
        console.log("=== Current Swap Paths on Polygon Mainnet ===");
        console.log("Diamond Address:", DIAMOND);
        console.log("");

        // Use vm.load to read storage directly
        _inspectSwapPath("BCT", C.bct(), "USDC.e", C.usdc_bridged());
        _inspectSwapPath("BCT", C.bct(), "KLIMA", C.klima());

        _inspectSwapPath("NCT", C.nct(), "USDC.e", C.usdc_bridged());
        _inspectSwapPath("NCT", C.nct(), "KLIMA", C.klima());

        _inspectSwapPath("MCO2", C.mco2(), "USDC.e", C.usdc_bridged());
        _inspectSwapPath("MCO2", C.mco2(), "KLIMA", C.klima());

        _inspectSwapPath("UBO", C.ubo(), "USDC.e", C.usdc_bridged());
        _inspectSwapPath("UBO", C.ubo(), "KLIMA", C.klima());

        _inspectSwapPath("NBO", C.nbo(), "USDC.e", C.usdc_bridged());
        _inspectSwapPath("NBO", C.nbo(), "KLIMA", C.klima());
    }

    function _inspectSwapPath(
        string memory poolName,
        address poolToken,
        string memory sourceName,
        address sourceToken
    ) internal {
        console.log("===========================================");
        console.log("Pool: %s | Source: %s", poolName, sourceName);
        console.log("Pool Token:", poolToken);
        console.log("Source Token:", sourceToken);
        console.log("");

        // Read swap configuration from storage
        (uint8[] memory swapDexes, address[] memory ammRouters, address[][] memory swapPaths) =
            _readSwapConfig(poolToken, sourceToken);

        if (swapDexes.length == 0) {
            console.log("NO DIRECT PATH CONFIGURED");
            console.log("-> Will fallback to USDC.e intermediary route");
        } else {
            console.log("Number of hops:", swapDexes.length);
            console.log("");

            for (uint256 i = 0; i < swapDexes.length; i++) {
                console.log("  --- Hop #%d ---", i);
                console.log("  DEX Type:", swapDexes[i] == 0 ? "UniswapV2-style" : "Trident");
                console.log("  Router:", ammRouters[i]);
                console.log("  Router Name:", _getRouterName(ammRouters[i]));
                console.log("");

                console.log("  Token Path:");
                for (uint256 j = 0; j < swapPaths[i].length; j++) {
                    console.log("    [%d] %s (%s)", j, swapPaths[i][j], _getTokenSymbol(swapPaths[i][j]));
                }
                console.log("");
            }
        }

        console.log("");
    }

    /**
     * @notice Read swap configuration from Diamond storage
     */
    function _readSwapConfig(address poolToken, address sourceToken)
        internal
        view
        returns (uint8[] memory swapDexes, address[] memory ammRouters, address[][] memory swapPaths)
    {
        // Storage layout for AppStorage.swap mapping
        // Position 3 in AppStorage (0-indexed)
        bytes32 baseSlot = bytes32(uint256(3));

        // Calculate slot for swap[poolToken][sourceToken]
        bytes32 poolSlot = keccak256(abi.encode(poolToken, baseSlot));
        bytes32 sourceSlot = keccak256(abi.encode(sourceToken, poolSlot));

        // Read swapDexes array (offset 0)
        swapDexes = _readUint8Array(sourceSlot);

        // Read ammRouters array (offset 1)
        bytes32 routersSlot = bytes32(uint256(sourceSlot) + 1);
        ammRouters = _readAddressArray(routersSlot);

        // Read swapPaths mapping (offset 2)
        bytes32 pathsSlot = bytes32(uint256(sourceSlot) + 2);
        swapPaths = new address[][](swapDexes.length);
        for (uint256 i = 0; i < swapDexes.length; i++) {
            bytes32 pathArraySlot = keccak256(abi.encode(uint8(i), pathsSlot));
            swapPaths[i] = _readAddressArray(pathArraySlot);
        }
    }

    function _readUint8Array(bytes32 slot) internal view returns (uint8[] memory arr) {
        uint256 length = uint256(vm.load(DIAMOND, slot));
        arr = new uint8[](length);

        if (length > 0) {
            bytes32 dataSlot = keccak256(abi.encode(slot));
            for (uint256 i = 0; i < length; i++) {
                arr[i] = uint8(uint256(vm.load(DIAMOND, bytes32(uint256(dataSlot) + i))));
            }
        }
    }

    function _readAddressArray(bytes32 slot) internal view returns (address[] memory arr) {
        uint256 length = uint256(vm.load(DIAMOND, slot));
        arr = new address[](length);

        if (length > 0) {
            bytes32 dataSlot = keccak256(abi.encode(slot));
            for (uint256 i = 0; i < length; i++) {
                arr[i] = address(uint160(uint256(vm.load(DIAMOND, bytes32(uint256(dataSlot) + i)))));
            }
        }
    }

    function _getRouterName(address router) internal pure returns (string memory) {
        if (router == C.sushiRouter()) return "SushiSwap";
        if (router == C.quickswapRouter()) return "QuickSwap";
        if (router == C.sushiTridentRouter()) return "SushiSwap Trident";
        return "Unknown";
    }

    function _getTokenSymbol(address token) internal pure returns (string memory) {
        if (token == C.bct()) return "BCT";
        if (token == C.nct()) return "NCT";
        if (token == C.mco2()) return "MCO2";
        if (token == C.ubo()) return "UBO";
        if (token == C.nbo()) return "NBO";
        if (token == C.usdc_bridged()) return "USDC.e";
        if (token == C.usdc()) return "USDC";
        if (token == C.klima()) return "KLIMA";
        return "UNKNOWN";
    }
}
