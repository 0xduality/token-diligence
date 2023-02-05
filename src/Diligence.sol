// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import {Owned} from "@solbase/auth/Owned.sol";
import {SafeTransferLib} from "@solbase/utils/SafeTransferLib.sol";
import {ERC20} from "@solbase/tokens/ERC20/ERC20.sol";
import {WETH} from "@solbase/tokens/WETH.sol";
import {IUniswapV2Factory} from "./IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "./IUniswapV2Pair.sol";
import {IRouter} from "./IRouter.sol";

contract Diligence is Owned(tx.origin) {
    using SafeTransferLib for address;
    address payable constant public wavax = payable(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7);
    
    constructor() {
    }

    fallback() external payable { }

    receive() external payable { }

    function withdraw() public onlyOwner
    {
        msg.sender.safeTransferETH(address(this).balance);
    }

    function determineRouterFromFactory(address factory) internal pure returns (address)
    {
        if (factory == 0x9Ad6C38BE94206cA50bb0d90783181662f0Cfa10)
            return 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;
        else if (factory == 0xefa94DE7a4656D787667C749f7E1223D71E9FD88)
            return 0xE54Ca86531e17Ef3616d22Ca28b0D458b6C89106;
        else if (factory == 0xc35DADB65012eC5796536bD9864eD8773aBc74C4)
            return 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
        else
            return address(0);
    }

    function determineRouterFromPair(address pair) internal view returns (address)
    {
        address factory = IUniswapV2Pair(pair).factory();
        return determineRouterFromFactory(factory);
    }

    function swap(uint256 amount, address from, address to, address router) internal returns (uint256)
    {
        uint256 before = ERC20(to).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = from;
        path[1] = to;
        bytes memory payload = abi.encodeCall(IRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens, (amount, 0, path, address(this), block.timestamp));
        (bool success,) = address(router).call(payload);

        if (success)
        {
             return ERC20(to).balanceOf(address(this))-before;
        } 
        else
        {
            return type(uint256).max;
        }
    }

    function buyAndSell(address token, address with, uint256 amount, address factory) internal returns (uint256)
    {
        address router = determineRouterFromFactory(factory);
        uint256 expected; 
        uint256 actual; 
        ERC20(with).approve(router, amount);
        if (token < with)
        {
            address pair = IUniswapV2Factory(factory).getPair(token, with);
            (uint112 reserveT, uint112 reserveW,) = IUniswapV2Pair(pair).getReserves();
            expected = IRouter(router).getAmountOut(amount, reserveW, reserveT);
        }
        else
        {
            address pair = IUniswapV2Factory(factory).getPair(with, token);
            (uint112 reserveW, uint112 reserveT,) = IUniswapV2Pair(pair).getReserves();
            expected = IRouter(router).getAmountOut(amount, reserveW, reserveT);
        }
        actual = swap(amount, with, token, router);
        if (actual == 0)
            return 1;
        if (actual == type(uint256).max)
            return 2;
        if (actual < expected)
            return 3;
        ERC20(token).approve(router, actual);
        if (token < with)
        {
            address pair = IUniswapV2Factory(factory).getPair(token, with);
            (uint112 reserveT, uint112 reserveW,) = IUniswapV2Pair(pair).getReserves();
            expected = IRouter(router).getAmountOut(actual, reserveT, reserveW);
        }
        else
        {
            address pair = IUniswapV2Factory(factory).getPair(with, token);
            (uint112 reserveW, uint112 reserveT,) = IUniswapV2Pair(pair).getReserves();
            expected = IRouter(router).getAmountOut(actual, reserveT, reserveW);
        }
        actual = swap(actual, token, with, router);
        if (actual == 0)
            return 1;
        if (actual == type(uint256).max)
            return 4;
        if (actual < expected)
            return 5;
        return 0;
    }

    function checkToken(address token, address factory) public onlyOwner returns (uint256)
    {
        WETH(wavax).deposit{value: address(this).balance}();
        uint256 balance = WETH(wavax).balanceOf(address(this));
        uint256 ret = buyAndSell(token, wavax, balance, factory);
        balance = WETH(wavax).balanceOf(address(this));
        WETH(wavax).withdraw(balance);
        return ret;
    }

    function getPair(address factory, address tokenA, address tokenB) internal view returns (address)
    {
        if (tokenA < tokenB)
            return IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        else 
            return IUniswapV2Factory(factory).getPair(tokenB, tokenA);

    }

    function checkMarket(address market) public onlyOwner returns (uint256)
    {
        address factory = IUniswapV2Pair(market).factory();
        address router = determineRouterFromFactory(factory);
        address token0 = IUniswapV2Pair(market).token0();
        address token1 = IUniswapV2Pair(market).token1();
        if ( token0 == wavax)
        {
            return checkToken(token1, factory);
        }
        else if (token1 == wavax)
        {
            return checkToken(token0, factory);
        }
        else 
        {
            address pair = getPair(factory, token0, wavax);
            if (pair == address(0))
            {
                uint256 ret = checkToken(token1, factory);
                if (ret > 0)
                    return ret;
                WETH(wavax).deposit{value: address(this).balance}();
                ERC20(wavax).approve(router, ERC20(wavax).balanceOf(address(this)));
                ret = swap(ERC20(wavax).balanceOf(address(this)), wavax, token1, router);
                if (ret == type(uint256).max)
                    return 1;
                ret = buyAndSell(token0, token1, ret, factory);
                WETH(wavax).withdraw(ERC20(wavax).balanceOf(address(this)));
                return ret;
            }
            else
            {
                uint256 ret = checkToken(token1, factory);
                if (ret > 0)
                    return ret;
                WETH(wavax).deposit{value: address(this).balance}();
                ERC20(wavax).approve(router, ERC20(wavax).balanceOf(address(this)));
                ret = swap(ERC20(wavax).balanceOf(address(this)), wavax, token0, router);
                if (ret == type(uint256).max)
                    return 1;
                ret = buyAndSell(token1, token0, ret, factory);
                WETH(wavax).withdraw(ERC20(wavax).balanceOf(address(this)));
                return ret;
            }
        }
    }
}
