// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {NineEleven} from "../src/911Coin.sol";

contract NineElevenCoinTest is Test {
    NineEleven public nineEleven;

    function setUp() public {
        nineEleven = new NineEleven();
    }
}