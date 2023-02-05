// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Diligence.sol";
import "../src/IUniswapV2Pair.sol";
import {SafeTransferLib} from "@solbase/utils/SafeTransferLib.sol";

contract DiligenceTest is Test {
    using stdJson for string;
    using SafeTransferLib for address;
    address[] public markets;
    Diligence public checker;
    address deployer;

    function setUp() public {
        string memory RPC_URL = vm.envString("RPC_URL");
        vm.createSelectFork(RPC_URL);

        string memory json = vm.readFile("joe.json");
        address[] memory addies = json.readAddressArray("key");
        deployer = tx.origin;
        checker = new Diligence();
        for (uint i=0; i< addies.length;++i)
            markets.push(addies[i]);
    }


    function testFirst() public {
        address token = 0x6e7f5C0b9f4432716bDd0a77a3601291b9D9e985;
        for (uint i=40; i< 40+20; ++i)
        {
            vm.prank(deployer);
            address(checker).safeTransferETH(1_000_000_000_000_000);
            IUniswapV2Pair pair = IUniswapV2Pair(markets[i]);
            token = pair.token1() == checker.wavax() ? pair.token0() : pair.token1(); 
            vm.prank(deployer);
            uint256 val = checker.checkToken(token, 0x9Ad6C38BE94206cA50bb0d90783181662f0Cfa10);
            console.log(token, val);
        }
        vm.prank(deployer);
        checker.withdraw();
    }

    function testMarket() public {
        for (uint i=40; i< 40+20; ++i)
        {
            vm.prank(deployer);
            address(checker).safeTransferETH(1_000_000_000_000_000);
            vm.prank(deployer);
            uint256 val = checker.checkMarket(markets[i]);
            console.log(markets[i], val);
        }
        vm.prank(deployer);
        checker.withdraw();

    }
}
