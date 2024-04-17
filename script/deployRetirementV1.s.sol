// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Cujo <rawr@cujowolf.dev>

* Script to deploy Retirement Aggregator V1 as Transparent Proxies.
/******************************************************************************/

import "forge-std/Script.sol";

import "oz-4-8-3/proxy/transparent/TransparentUpgradeableProxy.sol";
import "oz-4-8-3/proxy/transparent/ProxyAdmin.sol";

import {KlimaCarbonRetirements} from "../src/retirement_v1/KlimaCarbonRetirements.sol";
import {KlimaRetirementAggregator} from "../src/retirement_v1/KlimaRetirementAggregator.sol";
import {RetireMossCarbon} from "../src/retirement_v1/RetireMossCarbon.sol";
import {RetireToucanCarbon} from "../src/retirement_v1/RetireToucanCarbon.sol";
import {RetireC3Carbon} from "../src/retirement_v1/RetireC3Carbon.sol";

contract DeployRetirementV1 is Script {
    ProxyAdmin admin;

    KlimaCarbonRetirements retireStorage;

    KlimaRetirementAggregator masterImplementation;
    TransparentUpgradeableProxy masterProxy;
    KlimaRetirementAggregator wrappedMasterProxy;

    RetireMossCarbon mossImplementation;
    TransparentUpgradeableProxy mossProxy;
    RetireMossCarbon wrappedMossProxy;

    RetireToucanCarbon toucanImplementation;
    TransparentUpgradeableProxy toucanProxy;
    RetireToucanCarbon wrappedToucanProxy;

    RetireC3Carbon c3Implementation;
    TransparentUpgradeableProxy c3Proxy;
    RetireC3Carbon wrappedC3Proxy;

    function run() external {
        //read env variables and choose EOA for transaction signing
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        address USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        address MCO2 = 0xAa7DbD1598251f856C12f63557A4C4397c253Cea;
        address KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
        address sKLIMA = 0xb0C22d8D350C67420f06F48936654f567C73E8C8;
        address wsKLIMA = 0x6f370dba99E32A3cAD959b341120DB3C9E280bA6;
        address NCT = 0xD838290e877E0188a4A44700463419ED96c16107;
        address BCT = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
        address UBO = 0x2B3eCb0991AF0498ECE9135bcD04013d7993110c;
        address NBO = 0x6BCa3B77C1909Ce1a4Ba1A20d1103bDe8d222E48;
        address TRIDENT = 0xc5017BE80b4446988e8686168396289a9A62668E;
        address BENTO = 0x0319000133d3AdA02600f0875d2cf03D442C3367;
        address TOUCANREGISTRY = 0x263fA1c180889b3a3f46330F32a4a23287E99FC9;

        admin = new ProxyAdmin();

        retireStorage = new KlimaCarbonRetirements();

        masterImplementation = new KlimaRetirementAggregator();
        masterProxy = new TransparentUpgradeableProxy(address(masterImplementation), address(admin), "");
        wrappedMasterProxy = KlimaRetirementAggregator(address(masterProxy));
        wrappedMasterProxy.initialize();

        masterImplementation = new KlimaRetirementAggregator();
        masterProxy = new TransparentUpgradeableProxy(address(masterImplementation), address(admin), "");
        wrappedMasterProxy = KlimaRetirementAggregator(address(masterProxy));
        wrappedMasterProxy.initialize();

        // Set addresses in master contract
        wrappedMasterProxy.setAddress(0, KLIMA);
        wrappedMasterProxy.setAddress(1, sKLIMA);
        wrappedMasterProxy.setAddress(2, wsKLIMA);
        wrappedMasterProxy.setAddress(3, USDC);
        wrappedMasterProxy.setAddress(4, 0x25d28a24Ceb6F81015bB0b2007D795ACAc411b4d);
        wrappedMasterProxy.setAddress(5, 0x4D70a031Fc76DA6a9bC0C922101A05FA95c3A227);
        wrappedMasterProxy.setAddress(6, 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7);
        wrappedMasterProxy.setAddress(7, address(retireStorage));

        /* ======= Moss helper deployment ======= */

        mossImplementation = new RetireMossCarbon();
        mossProxy = new TransparentUpgradeableProxy(address(mossImplementation), address(admin), "");
        wrappedMossProxy = RetireMossCarbon(address(mossProxy));
        wrappedMossProxy.initialize();

        wrappedMossProxy.addPool(MCO2, 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

        wrappedMossProxy.setMasterAggregator(address(masterProxy));
        wrappedMossProxy.setCarbonChain(0xeDAEFCf60e12Bd331c092341D5b3d8901C1c05A8);
        wrappedMossProxy.setFeeAmount(10);
        retireStorage.addHelperContract(address(mossProxy));

        wrappedMasterProxy.addPool(0xAa7DbD1598251f856C12f63557A4C4397c253Cea, 0);
        wrappedMasterProxy.setBridgeHelper(0, address(masterProxy));

        /* ======= Toucan helper deployment ======= */

        toucanImplementation = new RetireToucanCarbon();
        toucanProxy = new TransparentUpgradeableProxy(address(toucanImplementation), address(admin), "");
        wrappedToucanProxy = RetireToucanCarbon(address(toucanProxy));
        wrappedToucanProxy.initialize();

        wrappedToucanProxy.addPool(NCT, 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
        wrappedToucanProxy.addPool(BCT, 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);

        wrappedToucanProxy.setMasterAggregator(address(masterProxy));
        wrappedToucanProxy.setFeeAmount(10);
        retireStorage.addHelperContract(address(toucanProxy));
        wrappedToucanProxy.setToucanRegistry(TOUCANREGISTRY);

        wrappedMasterProxy.addPool(NCT, 1);
        wrappedMasterProxy.addPool(BCT, 1);
        wrappedMasterProxy.setBridgeHelper(1, address(toucanProxy));

        /* ======= C3 helper deployment ======= */

        c3Implementation = new RetireC3Carbon();
        c3Proxy = new TransparentUpgradeableProxy(address(c3Implementation), address(admin), "");
        wrappedC3Proxy = RetireC3Carbon(address(c3Proxy));
        wrappedC3Proxy.initialize();

        wrappedC3Proxy.addPool(
            UBO,
            0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506,
            0x5400A05B8B45EaF9105315B4F2e31F806AB706dE
        );
        wrappedC3Proxy.addPool(
            NBO,
            0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506,
            0x251cA6A70cbd93Ccd7039B6b708D4cb9683c266C
        );

        wrappedC3Proxy.setMasterAggregator(address(masterProxy));
        wrappedC3Proxy.setFeeAmount(10);
        retireStorage.addHelperContract(address(c3Proxy));
        wrappedC3Proxy.setTrident(TRIDENT, BENTO);

        wrappedMasterProxy.addPool(UBO, 2);
        wrappedMasterProxy.addPool(NBO, 2);
        wrappedMasterProxy.setBridgeHelper(2, address(c3Proxy));

        /* ======= Logs ======= */

        console.log("======= Immutable Deployments =======");
        console.log("Proxy admin deployed to:", address(admin));
        console.log("Retirement storage deployed to:", address(retireStorage));
        console.log("Master implementation deployed to:", address(masterImplementation));
        console.log("Moss implementation deployed to:", address(mossImplementation));
        console.log("Toucan implementation deployed to:", address(toucanImplementation));
        console.log("C3 implementation deployed to:", address(c3Implementation));
        console.log("======= Proxy Deployments =======");
        console.log("Master proxy deployed to:", address(masterProxy));
        console.log("Moss proxy deployed to:", address(mossProxy));
        console.log("Toucan proxy deployed to:", address(toucanProxy));
        console.log("C3 proxy deployed to:", address(c3Proxy));

        vm.stopBroadcast();
    }
}
