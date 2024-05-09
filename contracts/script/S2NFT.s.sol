// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {S2NFT} from "../src/S2NFT.sol";

contract S2NFTScript is Script {
     function run() public {
        address deployer = 0xC3b0FAafeB7a80D9E3Bfde134972026B61c1F127;
        vm.startBroadcast(deployer);
        new S2NFT("Music NFT","MUNFT","ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH",10000);
        vm.stopBroadcast();
    }
}