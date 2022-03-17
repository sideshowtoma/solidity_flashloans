// SwapToken.sol
pragma solidity >= 0.8.4;

import "./interfaces/IUniswapV2Router02.sol";
import '../zeplin/token/ERC20/IERC20.sol';

contract sushiswapper {
    
    IUniswapV2Router02 public uniRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    
    event test (uint timestamp, uint amountIn, uint amountOut, address[] path, uint allowance, address sender);
   event test_1 (uint timestamp, address token1, address token2);
   

    function swapper(address token1, address token2,uint amountIn) public  {

    emit test_1( block.timestamp, token1,token2);


        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;
        uint amountOut =uniRouter.getAmountsOut(amountIn, path)[0];
        
        

      //  emit test( block.timestamp, amountIn, amountOut, path, 0, msg.sender);


        IERC20(token1).approve(address(uniRouter), amountIn);
        IERC20(token2).approve(address(uniRouter), amountOut);
        
        uint allowed = IERC20(token1).allowance(address(this), address(uniRouter));
        
         //emit test( block.timestamp, amountIn, amountOut, path, allowed, msg.sender);

        uniRouter.swapExactTokensForTokens(
            amountIn, 
            amountOut,
            path, 
            address(this), 
            block.timestamp + 120
        );

        
        emit test( block.timestamp, amountIn, amountOut, path, allowed, msg.sender);
        
    }
}