pragma solidity >= 0.8.4;

import "../avvee/contracts/v2/aave/FlashLoanReceiverBaseV2.sol";
import "../avvee/interfaces/v2/ILendingPoolAddressesProviderV2.sol";
import "../avvee/interfaces/v2/ILendingPoolV2.sol";



//sushiswap
import "../sushiswap/interfaces/IUniswapV2Router02.sol";
import '../zeplin/token/ERC20/IERC20.sol';



//bancor
import '../bancor/interfaces/IContractRegistry.sol'; 
import '../bancor/interfaces/IBancorNetwork.sol';



//import "hardhat/console.sol";


contract kacontract_ka_sushi_bancore is FlashLoanReceiverBaseV2, Withdrawable 
{

     using SafeMath for uint256;
  
    IUniswapV2Router02 public SushiUniRouter ;

   
    IContractRegistry contractRegistry; 
    


    uint24 public constant poolFee = 3000;

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

    struct exchange_tokens_specific
    {       
                string  exchange;
                base_meta[]  exchange_swaps;
    }


    struct exchange_tokens_specific_many
    {       
                exchange_tokens_specific[] all_exchange_tokens_specific;
    }
 



    constructor(address _addressProvider, IUniswapV2Router02  _SushiUniRouter , IContractRegistry _BancorcontractRegistry ) public FlashLoanReceiverBaseV2(_addressProvider)
    {
       
        //sushi
        SushiUniRouter = IUniswapV2Router02(_SushiUniRouter);
        
        //bancor
        contractRegistry=_BancorcontractRegistry;
      //  console.log("ROUTER SET DONE");
    }

   

     function executeOperation( address[] calldata assets,uint256[] calldata amounts, uint256[] calldata premiums, address initiator, bytes calldata params ) external override returns (bool) 
     {          
                            exchange_tokens_specific[] memory my_trans=abi.decode(params, (exchange_tokens_specific_many)).all_exchange_tokens_specific;
                            
                                   // console.log("loaned amounts '%d' ",  IERC20(assets[0]).balanceOf(address(this))   );      
                           

                                    for(uint i=0;i<my_trans.length;i++)
                                    {
                                                exchange_tokens_specific memory thisonehere=my_trans[i];
                                            
                                                swap_execute5655455(thisonehere.exchange,thisonehere.exchange_swaps);


                                                    
                                    }
                                    //console.log("executeOperation now just repay loan");

        
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }

        return true;

        // console.log("executeOperation end");
    }



        function swap_execute5655455(string memory center,base_meta[] memory my_array_swaps) internal returns ( uint256 amountOutFinal)
        {

            //console.log("center '%s' and is '%d' long ",center ,my_array_swaps.length );


                if(keccak256(bytes(center)) == keccak256(bytes("bancor")))
                {
                       // console.log("bancor start");   
                        bytes32  bancorNetworkName="BancorNetwork"; 
                        IBancorNetwork bancorNetwork =  IBancorNetwork(contractRegistry.addressOf(bancorNetworkName));
          
                        

                        uint minReturn = bancorNetwork.rateByPath( bancorNetwork.conversionPath(IERC20Token(my_array_swaps[0].tokenIn),IERC20Token(my_array_swaps[0].tokenOut) ), my_array_swaps[0].swapAmount );
                      //  console.log("[bancor] minReturn: '%d' ",minReturn); 

                                    if(minReturn>= my_array_swaps[0].amountOut )
                                    {
                                     

                                     IERC20(my_array_swaps[0].tokenIn).approve(address(bancorNetwork), my_array_swaps[0].swapAmount);

                                            //console.log("[bancor] yes is greater");  
                                            bancorNetwork.convertByPath{value: msg.value}(
                                                                                        bancorNetwork.conversionPath(IERC20Token(my_array_swaps[0].tokenIn),IERC20Token(my_array_swaps[0].tokenOut) ),
                                                                                        my_array_swaps[0].swapAmount,
                                                                                        my_array_swaps[0].amountOut,
                                                                                        address(this),
                                                                                        address(0),
                                                                                        0
                                                                                    );

                                            amountOutFinal=my_array_swaps[0].amountOut ;

                                           // console.log("[bancor] amountOutFinal: '%d' ",amountOutFinal);    

                                    }

                                // console.log("bancor end");   


                   
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

    function fanya_ile_kitu_baba(address  transaction1_address_in,uint256  transaction1_amount_in, exchange_tokens_specific[] memory  my_trans ) public onlyOwner
    {     
                

                                address[] memory assets = new address[](1);
                                assets[0] = transaction1_address_in;

                                uint256[] memory amounts = new uint256[](1);
                                amounts[0] = transaction1_amount_in;
                                _flashloan(assets, amounts,my_trans);

                
    }




}
    