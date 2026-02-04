//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MoodNFT} from "../src/MoodNFT.sol";
import {console2} from "forge-std/console2.sol";

contract MoodNFTTest is Test {
    MoodNFT moodNFT;
    string public constant HAPPY_SVG_URI = "";
    string public constant SAD_SVG_URI = "";

    address USER = makeAddr("user");

    function setUp() public {
        moodNFT = new MoodNFT(SAD_SVG_URI, HAPPY_SVG_URI);
    }

    function testViewTokenURI() public {
        vm.prank(USER);
        moodNFT.mintNFT();
        console2.log(moodNFT.tokenURI(0));
    }
}
