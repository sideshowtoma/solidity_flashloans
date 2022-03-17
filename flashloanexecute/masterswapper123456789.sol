pragma solidity >= 0.8.4;

import "../avvee/contracts/v2/aave/FlashLoanReceiverBaseV2.sol";
import "../avvee/interfaces/v2/ILendingPoolAddressesProviderV2.sol";
import "../avvee/interfaces/v2/ILendingPoolV2.sol";

contract masterswapper123456789 is FlashLoanReceiverBaseV2, Withdrawable {

    using SafeMath for uint256;
    address public owner_ni_nani_mazee_ehh;

    
    /*
    string transaction_hash,
                                            string transaction1_center, 
                                            string transaction1_address_in,
                                            string transaction1_address_out,
                                            string transaction1_token_in,
                                            string transaction1_token_out,
                                            uint256 transaction1_amount_in,
                                            uint256 transaction1_amount_out,
                                            string transaction2_center,     
                                            string transaction2_address_in,
                                            string transaction2_address_out,   
                                            string transaction2_token_in,
                                            string transaction2_token_out,
                                            uint256 transaction2_amount_in,
                                            uint256 transaction3_amount_out
    */
    struct mytransactions
   {
        string transaction_hash;
        string transaction1_address_in_comb;
        uint256 transaction1_amount_in,
        string transaction1_address_out_comb;
        int256 transaction1_amount_out,
       bool umeowa;

   }



    constructor(address _addressProvider) public FlashLoanReceiverBaseV2(_addressProvider)
    {
        owner_ni_nani_mazee_ehh=msg.sender;
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
        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //

        

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
    }

    function _flashloan(address[] memory assets, uint256[] memory amounts) internal
    {
        address receiverAddress = address(this);

        address onBehalfOf = address(this);
        bytes memory params = "";
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
    }

    
    function flashloan(address _asset,uint256 amount) public onlyOwner 
    {
        bytes memory data = "";

        address[] memory assets = new address[](1);
        assets[0] = _asset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        _flashloan(assets, amounts);
    }



//17-3-2022 11:56:31::: Used (0x6b175474e89094c44da98b954eedeac495271d0f) dai[1111.0] to buy (0xa117000000f279d81a1d3cc75430faa017fa5a2e) ant[223.0] at sushi, and sold the ant[223.0] to get dai[1747.0 ]  at uniswap with 100.18 > 157.24572457245725%  
        function initiate_loan_and_deals(string transaction_hash,
                                            string transaction1_center, 
                                            string transaction1_address_in,
                                            string transaction1_address_out,
                                            string transaction1_token_in,
                                            string transaction1_token_out,
                                            uint256 transaction1_amount_in,
                                            uint256 transaction1_amount_out,
                                            string transaction2_center,     
                                            string transaction2_address_in,
                                            string transaction2_address_out,   
                                            string transaction2_token_in,
                                            string transaction2_token_out,
                                            uint256 transaction2_amount_in,
                                            uint256 transaction3_amount_out
                                            ) 
        public onlyOwner
        {

        }
  


    


} 
