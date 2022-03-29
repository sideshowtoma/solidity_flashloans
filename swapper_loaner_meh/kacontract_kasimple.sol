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

 console.log("my_trans exchange '%d' ",my_trans.length );
 exchange_tokens_specific memory first_one=my_trans[0];

                            console.log("first_one exchange '%s' and is '%d' long ",first_one.exchange ,first_one.exchange_swaps.length );
                            console.log("loan '%d'  ",first_one.exchange_swaps[0].swapAmount );



        for(uint i=0;i<my_trans.length;i++)
        {
                    exchange_tokens_specific memory thisonehere=my_trans[i];
                   
                if(keccak256(bytes(thisonehere.exchange)) == keccak256(bytes("uniswap")))
                {
                     console.log("uniswap thisonehere '%s' and is '%d' long ",thisonehere.exchange ,thisonehere.exchange_swaps.length );

                }
                else if(keccak256(bytes(thisonehere.exchange)) == keccak256(bytes("sushiswap")))
                {
                         console.log("sushiswap thisonehere '%s' and is '%d' long ",thisonehere.exchange ,thisonehere.exchange_swaps.length );

                }
                else if(keccak256(bytes(thisonehere.exchange)) == keccak256(bytes("kyberswap")))
                {
                     console.log("kyberswap thisonehere '%s' and is '%d' long ",thisonehere.exchange ,thisonehere.exchange_swaps.length );

                }


                          
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
                    console.log("my_trans exchange '%d' ",my_trans.length );
                }

                //get the amounts to loan
                

    }




}
    