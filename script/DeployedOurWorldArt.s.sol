// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {OurWorldArt} from "../src/OurWorldArt.sol";

contract DeployedOurWorldArt is Script {
    address public myTestContractAddress = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496; //Address of test contract
    address public myAnvil0Address = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; //Anvil 0
    address public mySepoliaAddress = 0x19c1Bce56b325Bc55e4292c1E15567ca40FFD062;

    function run() external returns (OurWorldArt) {
        vm.startBroadcast();
        OurWorldArt ourWorldArt = new OurWorldArt(mySepoliaAddress); 
        vm.stopBroadcast();
        return ourWorldArt;
    }
}