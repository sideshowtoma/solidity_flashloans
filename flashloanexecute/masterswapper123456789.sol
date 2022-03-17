pragma solidity >= 0.8.4;

import "../avvee/contracts/v2/aave/FlashLoanReceiverBaseV2.sol";
import "../avvee/interfaces/v2/ILendingPoolAddressesProviderV2.sol";
import "../avvee/interfaces/v2/ILendingPoolV2.sol";

contract masterswapper123456789 is FlashLoanReceiverBaseV2, Withdrawable {

    using SafeMath for uint256;
    address public owner_ni_nani_mazee_ehh;

    mapping(uint=> transactionsmine) public transactionsminearray;

    uint256 public transactionsmine_counter=0;


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

     transactionsmine public current_items;

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

    function _flashloan(address[] memory assets, 
                        uint256[] memory amounts
    ) internal
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




                //get the flash loan
                    address[] memory assets = new address[](1);
                    assets[0] = transaction1_address_in;

                    uint256[] memory amounts = new uint256[](1);
                    amounts[0] = transaction1_amount_in;

                    current_items=transactionsmine_this;

                    _flashloan(assets,  amounts);
                    
        }
  


      
    


} 