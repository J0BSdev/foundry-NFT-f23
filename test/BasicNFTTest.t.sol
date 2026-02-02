//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {DeployBasicNFT} from "../script/DeployBasicNFT.s.sol";


contract BasicNFTTest is Test {
    DeployBasicNFT public deployer;
  BasicNFT public basicNFT; 

    function setUp() public {
        deployer = new DeployBasicNFT();
        basicNFT = deployer.run();
    }


function TestNameIsCorrect() public view{
    string memory expectedName = "Dogie";
    string memory actualName = basicNFT.name();
    assert(keccak256(abi.encodePacked(expectedName)) == 
    keccak256(abi.encodePacked(actualName)));
}



}