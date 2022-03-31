pragma solidity >= 0.8.4;

import "../avvee/contracts/v2/aave/FlashLoanReceiverBaseV2.sol";
import "../avvee/interfaces/v2/ILendingPoolAddressesProviderV2.sol";
import "../avvee/interfaces/v2/ILendingPoolV2.sol";

//uniswap
pragma abicoder v2;

import '../uniswap/contracts/libraries/TransferHelper.sol';
import '../uniswap/contracts/interfaces/ISwapRouter.sol';


//sushiswap
import "../sushiswap/interfaces/IUniswapV2Router02.sol";
import '../zeplin/token/ERC20/IERC20.sol';

//kyberswap
import "../kyber2/interfaces/IDMMRouter02.sol";
import "../kyber2/interfaces/IDMMFactory.sol";


import "hardhat/console.sol";


contract kacontract_kasimple is FlashLoanReceiverBaseV2, Withdrawable 
{

     using SafeMath for uint256;
    ISwapRouter public immutable UniSwapRouter;
    IUniswapV2Router02 public SushiUniRouter ;

    IDMMRouter02 public dmmRouter;
    IDMMFactory public dmmFactory;

    uint24 public poolFee = 3000;

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
 



    constructor(address _addressProvider,
                        ISwapRouter _UniSwapRouter,
                        IUniswapV2Router02  _SushiUniRouter ,
                        IDMMRouter02 _KeyberdmmRouter
                        ) public FlashLoanReceiverBaseV2(_addressProvider)
    {
        console.log("ROUTER SET START");

        //uni
        UniSwapRouter=_UniSwapRouter;

        //sushi
        SushiUniRouter = IUniswapV2Router02(_SushiUniRouter);

        //kyber
        dmmRouter = _KeyberdmmRouter;
        dmmFactory = IDMMFactory(dmmRouter.factory());

       
        console.log("ROUTER SET DONE");
    }


     function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {

      //   console.log("executeOperation start");

        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //

    ///exchange_tokens_specific[] memory  my_trans;
//exchange_tokens_specific_many memory my_trans_all=exchange_tokens_specific_many(my_trans);

 exchange_tokens_specific_many memory my_trans_all=abi.decode(params, (exchange_tokens_specific_many));
 exchange_tokens_specific[] memory my_trans=my_trans_all.all_exchange_tokens_specific;

 //console.log("my_trans exchange '%d' ",my_trans.length );
 exchange_tokens_specific memory first_one=my_trans[0];

                           // console.log("first_one exchange '%s' and is '%d' long ",first_one.exchange ,first_one.exchange_swaps.length );
                           // console.log("loan '%d'  ",first_one.exchange_swaps[0].swapAmount );



        for(uint i=0;i<my_trans.length;i++)
        {
                    exchange_tokens_specific memory thisonehere=my_trans[i];
                   
                    swap_execute5655455(thisonehere.exchange,thisonehere.exchange_swaps);


                          
        }
        console.log("executeOperation--");

        //transactionsmine memory current_items_here=current_items;
           
        // At the end of your logic above, this contract owes
        // the flashloaned amounts + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.

        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }

        return true;

        // console.log("executeOperation end");
    }



        function swap_execute5655455(string memory center,base_meta[] memory my_array_swaps) internal returns ( uint256 amountOutFinal)
        {

            console.log("center '%s' and is '%d' long ",center ,my_array_swaps.length );


                if(keccak256(bytes(center)) == keccak256(bytes("uniswap")))
                {
                    
                    TransferHelper.safeApprove(my_array_swaps[0].tokenIn, address(UniSwapRouter), my_array_swaps[0].swapAmount);
                   
                    console.log("[uniswap] amountIn: '%s' amountOut: '%s'",uintToStringIkoNiniKinuthia(my_array_swaps[0].swapAmount),uintToStringIkoNiniKinuthia(my_array_swaps[ ((my_array_swaps.length)-1)  ].amountOut));    
                    bytes memory data_path;
                    if(my_array_swaps.length==1)
                    {
                        console.log("1"); 
                        data_path= abi.encodePacked(my_array_swaps[0].tokenIn, poolFee, my_array_swaps[0].tokenOut );
                    }
                    else if(my_array_swaps.length==2)
                    {
                         console.log("2"); 
                         data_path= abi.encodePacked(my_array_swaps[0].tokenIn, poolFee, my_array_swaps[0].tokenOut, poolFee  ,my_array_swaps[1].tokenOut );
                    }
                    else if(my_array_swaps.length==3)
                    {
                        console.log("3"); 
                         data_path= abi.encodePacked(my_array_swaps[0].tokenIn, poolFee, my_array_swaps[0].tokenOut, poolFee  ,my_array_swaps[1].tokenOut, poolFee  ,my_array_swaps[2].tokenOut );
                    }
                    else if(my_array_swaps.length==4)
                    {
                        console.log("4"); 
                         data_path= abi.encodePacked(my_array_swaps[0].tokenIn, poolFee, my_array_swaps[0].tokenOut, poolFee  ,my_array_swaps[1].tokenOut, poolFee  ,my_array_swaps[2].tokenOut , poolFee  ,my_array_swaps[3].tokenOut );
             
                    }

                    ISwapRouter.ExactInputParams memory params =
                                            ISwapRouter.ExactInputParams({
                                                path: data_path,
                                                recipient:address(this),
                                                deadline: block.timestamp+120,
                                                amountIn: my_array_swaps[0].swapAmount,
                                                amountOutMinimum:my_array_swaps[ ((my_array_swaps.length)-1)  ].amountOut
                                            });

                                amountOutFinal = UniSwapRouter.exactInput(params);
                            console.log("[uniswap] amountOutFinal: '%s' ",uintToStringIkoNiniKinuthia(amountOutFinal));    



                }
                else if(keccak256(bytes(center)) == keccak256(bytes("sushiswap")))
                {
                    address[] memory path = new address[]( ( (my_array_swaps.length)+1 ) );
                    path[0] = address(my_array_swaps[0].tokenIn);
                    path[1] = address(my_array_swaps[0].tokenOut);

                    IERC20(my_array_swaps[0].tokenIn).approve(address(SushiUniRouter), my_array_swaps[0].swapAmount);
                    IERC20(my_array_swaps[0].tokenOut).approve(address(SushiUniRouter), my_array_swaps[0].amountOut);

                    uint256 path_counter =2;

                       for (uint256 i = 1; i < my_array_swaps.length ; i++) 
                       {
                                  path[ path_counter ] = address(my_array_swaps[i].tokenOut);
                                    
                                  IERC20(my_array_swaps[i].tokenOut).approve(address(SushiUniRouter), my_array_swaps[i].amountOut);
                                    
                                    path_counter++;
                       }

                                         SushiUniRouter.swapExactTokensForTokens(
                                                                  my_array_swaps[0].swapAmount, 
                                                                  my_array_swaps[ ((my_array_swaps.length)-1)  ].amountOut,
                                                                  path, 
                                                                  address(this), 
                                                                  block.timestamp + 120
                                                              );


                                    amountOutFinal= my_array_swaps[ ((my_array_swaps.length)-1)  ].amountOut;

                                    console.log("[sushi] amountOutFinal: '%s' ",uintToStringIkoNiniKinuthia(amountOutFinal));   

                    

                }
                else if(keccak256(bytes(center)) == keccak256(bytes("kyberswap")))
                {
                     console.log("kyberswap start");  
                        IERC20[] memory path = new IERC20[]( ( (my_array_swaps.length)+1 ) );
                        path[0] = IERC20(my_array_swaps[0].tokenIn);
                        path[1] = IERC20(my_array_swaps[0].tokenOut);

                        address[] memory poolsPath= new address[]( my_array_swaps.length   ) ;
                        poolsPath[0]=my_array_swaps[0].pool;

                         
                        require(IERC20(my_array_swaps[0].tokenIn).approve(address(dmmRouter),  my_array_swaps[0].swapAmount), 'approve failed');

                    console.log("kyberswap approved");  


                    uint256 path_counter =2;
                    uint256 poolsPath_counter=1;

         
                       for (uint256 i = 1; i < my_array_swaps.length ; i++) 
                       {
                           
                                path[ path_counter  ] = IERC20(my_array_swaps[i].tokenOut);
                                poolsPath[ poolsPath_counter]=my_array_swaps[i].pool;
                                require(IERC20(my_array_swaps[i].tokenOut).approve(address(dmmRouter),  my_array_swaps[i].swapAmount), 'approve failed');
                            
                                path_counter++;
                                poolsPath_counter++;
                       }
                       
               
               console.log("kyberswap approved here");  

                     uint256[] memory outs=dmmRouter.getAmountsOut(my_array_swaps[0].swapAmount, poolsPath, path);

                        for (uint256 i = 0; i < outs.length ; i++) 
                       {
                           
                                console.log("outs %d: %s",i,uintToStringIkoNiniKinuthia( outs[i]) );   
                       }

                     console.log("out is %s",uintToStringIkoNiniKinuthia( outs[ ((path.length)-1) ]));   
                         console.log("kyberswap here");   

                         dmmRouter.swapTokensForExactTokens(
                                                                            my_array_swaps[0].swapAmount, // 
                                                                            my_array_swaps[((my_array_swaps.length)-1)].amountOut, // should be obtained via a price oracle, either off or on-chain
                                                                            poolsPath, // eg. [core-usdt-pool]
                                                                            path,
                                                                           address(this), 
                                                                            block.timestamp + 120
                                                                        );


                            amountOutFinal=my_array_swaps[ ((my_array_swaps.length)-1)  ].amountOut;

                    console.log("kyberswap end");   
                         
                }
                
                

        }


     function _flashloan(address[] memory assets, 
                        uint256[] memory amounts,
                        exchange_tokens_specific[] memory  my_trans
    ) internal
    {
        exchange_tokens_specific_many memory my_trans_all=exchange_tokens_specific_many(my_trans);

        // exchange_tokens_specific_many memory  my_trans=all_params.all_exchange_tokens_specific;

       // console.log("_flashloan start");
        address receiverAddress = address(this);

        address onBehalfOf = address(this);
        
        bytes memory params = abi.encode(my_trans_all);
        uint16 referralCode = 0;

        uint256[] memory modes = new uint256[](assets.length);

        // 0 = no debt (flash), 1 = stable, 2 = variable
        for (uint256 i = 0; i < assets.length; i++) {
            modes[i] = 0;
        }

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );

       // console.log("_flashloan end");
    }


function transferERC20_now_hahaha(IERC20 token, address payable to, uint256 amount) public onlyOwner
    {
        
            uint256 erc20balance = token.balanceOf(address(this));

            if(amount <= erc20balance)
            {
                 token.transfer(to, amount);
            }
            
       
    }

   
   

    function fanya_ile_kitu_baba( exchange_tokens_specific[] memory  my_trans ) public onlyOwner
    {


       // exchange_tokens_specific[] memory  my_trans=all_params.all_exchange_tokens_specific;

   // console.log("my_trans exchange '%d' ",my_trans.length );

                    
                
                if(my_trans.length > 0)
                {
                        // console.log("my_trans exchange '%d' ",my_trans.length );

                        exchange_tokens_specific memory first_one=my_trans[0];

                        //base_meta memory first_one_assets =first_one.exchange_swaps[0];

                                address[] memory assets = new address[](1);
                                assets[0] = first_one.exchange_swaps[0].tokenIn;

                                uint256[] memory amounts = new uint256[](1);
                                amounts[0] = first_one.exchange_swaps[0].swapAmount;


                            //console.log("first_one exchange '%s' and is '%d' long ",first_one.exchange ,first_one.exchange_swaps.length );
                            //console.log("loan '%d'  ",first_one.exchange_swaps[0].swapAmount );

                            _flashloan(assets, amounts,my_trans);

                        // console.log("initiate_loan_and_deals end");

                }
                else
                {
                    //console.log("my_trans exchange '%d' ",my_trans.length );
                }

                //get the amounts to loan
                

    }


function uintToStringIkoNiniKinuthia(uint256 _i) internal pure returns (string memory str)
{
            if (_i == 0)
            {
                return "0";
            }
            uint256 j = _i;
            uint256 length;
            while (j != 0)
            {
                length++;
                j /= 10;
            }
            bytes memory bstr = new bytes(length);
            uint256 k = length;
            j = _i;
            while (j != 0)
            {
                bstr[--k] = bytes1(uint8(48 + j % 10));
                j /= 10;
            }
            str = string(bstr);
            }


}
    