// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {RenftMarket} from "../src/RenftMarket.sol";

contract NFTRentMarketScript is Script {
     function run() public {
        address deployer = 0xC3b0FAafeB7a80D9E3Bfde134972026B61c1F127;
        vm.startBroadcast(deployer);
        RenftMarket market = new RenftMarket();
        vm.stopBroadcast();
    }
}