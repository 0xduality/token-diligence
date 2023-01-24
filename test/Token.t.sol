// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Token.sol";
import {Owned} from "@solbase/auth/Owned.sol";

contract TokenTest is Test {
    address alice;
    address deployer;
    Token public token;

    function setUp() public {
        string memory name = "alice";
        alice = address(uint160(uint256(keccak256(bytes(name)))));
        vm.label(alice, name);
        vm.deal(alice, 10 ether);
        deployer = tx.origin;
        vm.prank(alice);
        token = new Token();
    }

    function testInitialBalances() public view {
        require(token.balanceOf(alice) == 10**24);
        require(token.balanceOf(deployer) == 0);
    }
}
