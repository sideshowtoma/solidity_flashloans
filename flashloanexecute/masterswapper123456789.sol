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

//bancor
import '../bancor/interfaces/IContractRegistry.sol'; 
import '../bancor/interfaces/IBancorNetwork.sol';

import "hardhat/console.sol";

contract masterswapper123456789 is FlashLoanReceiverBaseV2, Withdrawable {

    using SafeMath for uint256;
    address public owner_ni_nani_mazee_ehh;

    mapping(uint=> transactionsmine) public transactionsminearray;

    uint256 public transactionsmine_counter=0;


    mapping(uint=> transactionsmine) public transactionsminearrayclone;

    uint256 public transactionsmine_counterclone=0;


    mapping (address=>uint256) public balances_are_hahah;
    mapping (string=>string) public transaction_happen;
    mapping (string=>uint256) public counter_tracker;


    struct transactionsmine
    {
                string  transaction1_center;
                address  transaction1_address_in;
                address  transaction1_address_out;
                uint256 transaction1_amount_in;
                uint256 transaction1_amount_out;
                string  transaction2_center;     
                address  transaction2_address_in;
                address  transaction2_address_out;  
                uint256 transaction2_amount_in;
                uint256 transaction2_amount_out;
                uint256 time_stamp;

    }


ISwapRouter public immutable UniSwapRouter;
 IUniswapV2Router02 public SushiUniRouter ;

    IDMMRouter02 public dmmRouter;
    IDMMFactory public dmmFactory;

    IContractRegistry contractRegistry; 
    bytes32 public constant bancorNetworkName="BancorNetwork";


     //transactionsmine public current_items;

    constructor(address _addressProvider,
                        ISwapRouter _UniSwapRouter,
                        IUniswapV2Router02  _SushiUniRouter ,
                        IDMMRouter02 _KeyberdmmRouter,
                        IContractRegistry _BancorcontractRegistry ) public FlashLoanReceiverBaseV2(_addressProvider)
    {
        console.log("ROUTER SET START");

        //uni
        owner_ni_nani_mazee_ehh=msg.sender;
        UniSwapRouter=_UniSwapRouter;

        //sushi
        SushiUniRouter = IUniswapV2Router02(_SushiUniRouter);

        //kyber
        dmmRouter = _KeyberdmmRouter;
        dmmFactory = IDMMFactory(dmmRouter.factory());

        //bancor
        contractRegistry=_BancorcontractRegistry;
        
        console.log("ROUTER SET DONE");
    }


                function getBancorNetworkContract() public returns(IBancorNetwork)
                { 
                        return IBancorNetwork(contractRegistry.addressOf(bancorNetworkName));

                }


    /**
     * @dev This function must be called only be the LENDING_POOL and takes care of repaying
     * active debt positions, migrating collateral and incurring new V2 debt token debt.
     *
     * @param assets The array of flash loaned assets used to repay debts.
     * @param amounts The array of flash loaned asset amounts used to repay debts.
     * @param premiums The array of premiums incurred as additional debts.
     * @param initiator The address that initiated the flash loan, unused.
     * @param params The byte array containing, in this case, the arrays of aTokens and aTokenAmounts.
     */

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {

         console.log("executeOperation start");

        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //
     //transactionsmine memory current_items_here=current_items;
            transactionsmine memory current_items_here=abi.decode(params, (transactionsmine));

              console.log("1. center '%s' ['%s'] then ['%s']",current_items_here.transaction1_center,uintToStringIkoNiniKinuthia(current_items_here.transaction1_amount_in),uintToStringIkoNiniKinuthia(current_items_here.transaction1_amount_out));

        uint256 amountOutFinal0=swap_execute5655455(current_items_here.transaction1_center,
                            current_items_here.transaction1_amount_in, 
                            current_items_here.transaction1_amount_out,
                            current_items_here.transaction1_address_in,
                            current_items_here.transaction1_address_out);


console.log("2. center '%s' ['%s'] then ['%s']",current_items_here.transaction2_center,uintToStringIkoNiniKinuthia(current_items_here.transaction2_amount_in),uintToStringIkoNiniKinuthia(current_items_here.transaction2_amount_out));            
       
        uint256 amountOutFinal1=swap_execute5655455(current_items_here.transaction2_center,
                            amountOutFinal0, 
                            current_items_here.transaction2_amount_out,
                            current_items_here.transaction2_address_in,
                            current_items_here.transaction2_address_out);

                
                transactionsminearrayclone[transactionsmine_counterclone]=current_items_here;
                transactionsmine_counterclone++;

                counter_tracker["transactionsmine_counterclone"]=transactionsmine_counterclone;

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

         console.log("executeOperation end");
    }

    function _flashloan(address[] memory assets, 
                        uint256[] memory amounts,
                        transactionsmine memory transactionsmine_this
    ) internal
    {
        console.log("_flashloan start");
        address receiverAddress = address(this);

        address onBehalfOf = address(this);
        bytes memory params = abi.encode(transactionsmine_this);
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

        console.log("_flashloan end");
    }



       function initiate_loan_and_deals(
                                            string memory transaction1_center, 
                                            address  transaction1_address_in,
                                            address  transaction1_address_out,
                                            uint256 transaction1_amount_in,
                                            uint256 transaction1_amount_out,
                                            string memory transaction2_center,     
                                            address  transaction2_address_in,
                                            address  transaction2_address_out,  
                                            uint256 transaction2_amount_in,
                                            uint256 transaction2_amount_out
                                            ) 
        public onlyOwner
        {
            
           
           console.log("initiate_loan_and_deals START");

          transactionsmine memory transactionsmine_this=  transactionsmine(
                                                                                    transaction1_center,
                                                                                    transaction1_address_in,
                                                                                    transaction1_address_out,
                                                                                    transaction1_amount_in,
                                                                                    transaction1_amount_out,
                                                                                    transaction2_center,     
                                                                                    transaction2_address_in,
                                                                                    transaction2_address_out,  
                                                                                    transaction2_amount_in,
                                                                                    transaction2_amount_out,
                                                                                    block.timestamp
                                                                        );

                transactionsminearray[transactionsmine_counter]=transactionsmine_this;
                transactionsmine_counter++;
                counter_tracker["transactionsmine_counter"]=transactionsmine_counter;

                console.log("initiate_loan_and_deals MID");

                //get the flash loan
                    address[] memory assets = new address[](1);
                    assets[0] = transaction1_address_in;

                    uint256[] memory amounts = new uint256[](1);
                    amounts[0] = transaction1_amount_in;

                    //current_items=transactionsmine_this;

                    _flashloan(assets,  amounts,transactionsmine_this);

                    console.log("initiate_loan_and_deals end");
                    
        }
  

 function uintToStringIkoNiniKinuthia(
  uint256 _i
)
  internal
  pure
  returns (string memory str)
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

   

        function swap_execute5655455(string memory center,uint256 amountIn, uint256 amountOut, address tokenIn, address tokenOut) internal returns ( uint256 amountOutFinal)
        {
                if(keccak256(bytes(center)) == keccak256(bytes("sushi")))
                {

                     console.log("sushi start");    

                    address[] memory path = new address[](2);
                    path[0] = tokenIn;
                    path[1] = tokenOut;
                    uint amountOut_sushi =SushiUniRouter.getAmountsOut(amountIn, path)[1];


                     console.log("[sushi] amountIn: '%s' amountOut: '%s'",uintToStringIkoNiniKinuthia(amountIn),uintToStringIkoNiniKinuthia(amountOut));    
                     console.log("[sushi] amountOut_sushi: '%s' ",uintToStringIkoNiniKinuthia(amountOut_sushi));    

                     //make sure the out is more than what u anticipate
                     if(amountOut_sushi>=amountOut)
                     {
                         console.log("[sushi] yes is greater");  
                            //approve
                             IERC20(tokenIn).approve(address(SushiUniRouter), amountIn);
                             IERC20(tokenOut).approve(address(SushiUniRouter), amountOut_sushi);

                        console.log("[sushi] approved");  

                            SushiUniRouter.swapExactTokensForTokens(
                                                        amountIn, 
                                                        amountOut_sushi,
                                                        path, 
                                                        address(this), 
                                                        block.timestamp + 120
                                                    );


                                                    amountOutFinal=amountOut_sushi;
                          console.log("[sushi] executed");  

                     } 
                     else
                     {
                         console.log("[sushi] yes is lesser");  
                            amountOutFinal=amountOut;
                     }  


                     console.log("[sushi] done");   

                }
                else if(keccak256(bytes(center)) == keccak256(bytes("uniswap")))
                {
                    TransferHelper.safeApprove(tokenIn, address(UniSwapRouter), amountIn);


                    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                                                                        tokenIn: tokenIn,
                                                                        tokenOut: tokenOut,
                                                                        fee: 3000,
                                                                        recipient: address(this),
                                                                        deadline: block.timestamp+120,
                                                                        amountIn: amountIn,
                                                                        amountOutMinimum: amountOut,
                                                                        sqrtPriceLimitX96: 0
                                                                    });

                                                                // The call to `exactInputSingle` executes the swap.
                                                                amountOutFinal = UniSwapRouter.exactInputSingle(params);

                     // amountOutFinal=amountOut;
                }
                else if(keccak256(bytes(center)) == keccak256(bytes("kyberswap")))
                {
                            IERC20[] memory path = new IERC20[](2);
                            path[0] = IERC20(tokenIn); // assuming core is specified as IERC20
                            path[1] = IERC20(tokenOut); // assuming usdt is specified as IERC20

                            address[] memory poolsPath = dmmFactory.getPools(IERC20(tokenIn), IERC20(tokenOut));
                            require(IERC20(tokenIn).approve(address(dmmRouter), amountIn), 'approve failed');

                            
                                    dmmRouter.swapTokensForExactTokens(
                                                                            amountIn, // 
                                                                            amountOut, // should be obtained via a price oracle, either off or on-chain
                                                                            poolsPath, // eg. [core-usdt-pool]
                                                                            path,
                                                                           address(this), 
                                                                            block.timestamp + 120
                                                                        );


                            amountOutFinal=amountOut;
                           
                      //amountOutFinal=amountOut;
                }
                else if(keccak256(bytes(center)) == keccak256(bytes("bancor")))
                {
                      
                      IBancorNetwork bancorNetwork = getBancorNetworkContract();

          
                    address[] memory path = bancorNetwork.conversionPath(IERC20Token(tokenIn),IERC20Token(tokenOut) );
                    uint minReturn = bancorNetwork.rateByPath( path, amountIn );

                    if(minReturn>=amountOut)
                    {

                        amountOutFinal = bancorNetwork.convertByPath{value: msg.value}(
                                                                    path,
                                                                    amountIn,
                                                                    minReturn,
                                                                    address(this),
                                                                    address(0x0),
                                                                    0
                                                                );


                       // amountOutFinal=minReturn;
                    }
                    else
                    {
                        amountOutFinal=amountOut;
                    }

                      
                }
                else
                {
                     amountOutFinal=amountOut;
                }




        }


        

      
     function get_my_balance_hahah_hujui_hii( address tracker_0x_address) public 
    {
            
        balances_are_hahah[tracker_0x_address]=ERC20(tracker_0x_address).balanceOf(address(this));


    }


    function transferERC20_now_hahaha(string memory tracker,IERC20 token, address payable to, uint256 amount) public 
    {
        if(msg.sender == owner_ni_nani_mazee_ehh)
        {
            uint256 erc20balance = token.balanceOf(address(this));

            if(amount <= erc20balance)
            {
                 token.transfer(to, amount);

                 balances_are_hahah[address(token)]=   balances_are_hahah[address(token)]-amount;//adjust amount on withdraw
                 transaction_happen[tracker]="success.";
            }
            else
            {
                  transaction_happen[tracker]="insufficient balance.";
            }
        }
        else
        {
             transaction_happen[tracker]="invalid sender.";
        }
           
    }


} 
