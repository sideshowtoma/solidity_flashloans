pragma solidity >= 0.8.4;

import "./interfaces/IDMMRouter02.sol";
import "./interfaces/IDMMFactory.sol";
import "../zeplin/utils/Strings.sol";


import "hardhat/console.sol";


contract kyberswapperaction 
{
                        IDMMRouter02 public dmmRouter;
                        IDMMFactory public dmmFactory;
                    

                        constructor(IDMMRouter02 _dmmRouter) 
                        {
                            dmmRouter = _dmmRouter;
                            dmmFactory = IDMMFactory(dmmRouter.factory());

                            console.log("ROUTER SET");
                        }

                        function doSwapKyber ( IERC20 fromToken,IERC20 ToToken, uint256 amountIn,uint256 amountOutMin) public returns (uint256[] memory amounts_out)
                        {
                            IERC20[] memory path = new IERC20[](2);
                            path[0] = fromToken; // assuming core is specified as IERC20
                            path[1] = ToToken; // assuming usdt is specified as IERC20

                            address[] memory poolsPath = dmmFactory.getPools(fromToken, ToToken);
                            require(fromToken.approve(address(dmmRouter), amountIn), 'approve failed');

                            

                            amounts_out=  dmmRouter.getAmountsOut( amountIn,  poolsPath, path);


                            for(uint256 i=0; i < amounts_out.length; i++) 
                            {
                                   
                                  console.log("'%d' ==> '%d'",i, amounts_out[i]);
                            }
                              

                                dmmRouter.swapTokensForExactTokens(
                                        amountIn, // 
                                        amountOutMin, // should be obtained via a price oracle, either off or on-chain
                                        poolsPath, // eg. [core-usdt-pool]
                                        path,
                                        msg.sender,
                                        block.timestamp+90
                                    );
                                 console.log("1 amountIn'%d'  amountOutMin '%d'",amountIn, amountOutMin);
                    
                        }




}