pragma solidity >= 0.8.4;

import "../avvee/contracts/v2/aave/FlashLoanReceiverBaseV2.sol";
import "../avvee/interfaces/v2/ILendingPoolAddressesProviderV2.sol";
import "../avvee/interfaces/v2/ILendingPoolV2.sol";





//sushiswap
import "../sushiswap/interfaces/IUniswapV2Router02.sol";




//import "hardhat/console.sol";


contract swap_uniswap_sushiswap is FlashLoanReceiverBaseV2, Withdrawable 
{

     using SafeMath for uint256;
    IUniswapV2Router02 public immutable UniSwapRouter;
    IUniswapV2Router02 public SushiUniRouter ;

  

    uint24 public constant poolFee = 10000000;

/*
    struct base_meta
    {
                 
                address  tokenOut;
                uint256  swapAmount;
                uint256  poolLength;
                address  pool;
                uint256  amountOut;  
                string   exchange;  
                uint256  maxPrice; 
                string   poolType; 
                address  tokenIn;

    }
*/

    struct base_meta
    {
                 
                address  tokenOut;
                uint256  swapAmount;
                uint256  amountOut;
                address  tokenIn;

    }

    struct input_structure
    {
                address  tokenAddress;
                uint256  amount;
    }



    struct exchange_tokens_specific
    {       
                string  exchange;
                base_meta[]  exchange_swaps;
    }


    struct exchange_tokens_specific_many
    {       
                exchange_tokens_specific[] all_exchange_tokens_specific;
    }
 



    constructor(address _addressProvider, IUniswapV2Router02 _UniSwapRouter, IUniswapV2Router02  _SushiUniRouter ) public FlashLoanReceiverBaseV2(_addressProvider)
    {
        //uni
        UniSwapRouter=IUniswapV2Router02(_UniSwapRouter);
        //sushi
        SushiUniRouter = IUniswapV2Router02(_SushiUniRouter);
        
       
      //  console.log("ROUTER SET DONE");
    }

   

     function executeOperation( address[] calldata assets,uint256[] calldata amounts, uint256[] calldata premiums, address initiator, bytes calldata params ) external override returns (bool) 
     {          
                            exchange_tokens_specific[] memory my_trans=abi.decode(params, (exchange_tokens_specific_many)).all_exchange_tokens_specific;
                            
                                //    console.log("loaned amounts '%d' ",  IERC20(assets[0]).balanceOf(address(this))   );      
                           
                           
                               for(uint i=0;i<my_trans.length;i++)
                                    {
                                                exchange_tokens_specific memory thisonehere=my_trans[i];
                                            
                                                swap_execute5655455(thisonehere.exchange,thisonehere.exchange_swaps);


                                                    
                                    }
                           

                                    
                                 //   console.log("executeOperation now just repay loan");

        
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }

      //  console.log("u keep amounts '%d' ",  IERC20(assets[0]).balanceOf(address(this))   );      
        return true;

         
    }



        function swap_execute5655455(string memory center,base_meta[] memory my_array_swaps) internal returns ( uint256 amountOutFinal)
        {

           // console.log("center '%s' and is '%d' long ",center ,my_array_swaps.length );

             if(keccak256(bytes(center)) == keccak256(bytes("uniswap")))
                {
                     //  console.log("here"); 
                    
                
                                address[] memory path = new address[]( ( (my_array_swaps.length)+1 ) );
                                path[0] = address( my_array_swaps[0].tokenIn);
                                path[1] = address( my_array_swaps[0].tokenOut);


                            
                            // TransferHelper.safeApprove(address(my_array_swaps[0].tokenIn), address(UniSwapRouter), my_array_swaps[0].swapAmount);
                              IERC20(my_array_swaps[0].tokenIn).approve(address(UniSwapRouter), my_array_swaps[0].swapAmount);

                                
                                uint256 path_counter =2;

                                for (uint256 i = 1; i < my_array_swaps.length ; i++) 
                                {
                                            path[ path_counter ] = (my_array_swaps[i].tokenOut);
                                          
                                            path_counter++;
                                }
                                
                                

                                                    UniSwapRouter.swapExactTokensForTokens(
                                                                            my_array_swaps[0].swapAmount, 
                                                                            my_array_swaps[ ((my_array_swaps.length)-1)  ].amountOut,
                                                                            path, 
                                                                            address(this), 
                                                                            block.timestamp+120
                                                                        );


                                                amountOutFinal= my_array_swaps[ ((my_array_swaps.length)-1)  ].amountOut;

                                              //  console.log("[uniswap] amountOutFinal: '%d' ",amountOutFinal);  
                                            





                }
                else if(keccak256(bytes(center)) == keccak256(bytes("sushiswap")))
                {
                    address[] memory path = new address[]( ( (my_array_swaps.length)+1 ) );
                    path[0] = address(my_array_swaps[0].tokenIn);
                    path[1] = address(my_array_swaps[0].tokenOut);

                    IERC20(my_array_swaps[0].tokenIn).approve(address(SushiUniRouter), my_array_swaps[0].swapAmount);

                    uint256 path_counter =2;

                       for (uint256 i = 1; i < my_array_swaps.length ; i++) 
                       {
                                path[ path_counter ] = address(my_array_swaps[i].tokenOut);
                                path_counter++;
                       }

                                         SushiUniRouter.swapExactTokensForTokens(
                                                                  my_array_swaps[0].swapAmount, 
                                                                  my_array_swaps[ ((my_array_swaps.length)-1)  ].amountOut,
                                                                  path, 
                                                                  address(this), 
                                                                  block.timestamp+60
                                                              );


                                    amountOutFinal= my_array_swaps[ ((my_array_swaps.length)-1)  ].amountOut;

                                   // console.log("[sushi] amountOutFinal: '%d' ",amountOutFinal);   

                    

                }
                
                

        }


    function _flashloan(address[] memory assets, uint256[] memory amounts, exchange_tokens_specific[] memory  my_trans) internal
    {
        uint256[] memory modes = new uint256[](assets.length);
       
        for (uint256 i = 0; i < assets.length; i++) {
            modes[i] = 0;
        }

        LENDING_POOL.flashLoan(  address(this), assets,  amounts, modes,  address(this),  abi.encode(exchange_tokens_specific_many(my_trans)) ,  0 );

      
    }


    function transferERC20_now_hahaha(IERC20 token, address payable to, uint256 amount) public onlyOwner  {   token.transfer(to, amount);  }

    function fanya_ile_kitu_baba(input_structure[] memory loan_assets_addresses, exchange_tokens_specific[] memory  my_trans ) public onlyOwner
    {     
                

                                address[] memory assets = new address[](loan_assets_addresses.length);
                                uint256[] memory amounts = new uint256[](loan_assets_addresses.length);

                            for(uint i=0;i<loan_assets_addresses.length;i++)
                            {
                                input_structure memory loan_assets_addresses_specific=loan_assets_addresses[i];

                                assets[0] = loan_assets_addresses_specific.tokenAddress;
                                amounts[0] = loan_assets_addresses_specific.amount;
                            }
                                


                                _flashloan(assets, amounts,my_trans);

                
    }




}
    