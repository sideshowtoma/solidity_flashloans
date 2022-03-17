pragma solidity >= 0.8.4;

import "./aave/FlashLoanReceiverBaseV2.sol";
import "../../interfaces/v2/ILendingPoolAddressesProviderV2.sol";
import "../../interfaces/v2/ILendingPoolV2.sol";

contract FlashloanV2 is FlashLoanReceiverBaseV2, Withdrawable {

    using SafeMath for uint256;
    address public owner_ni_nani_mazee_ehh;

    mapping (address=>uint256) public balances_are_hahah;
    mapping (string=>string) public transaction_happen;

    constructor(address _addressProvider)
        public
        FlashLoanReceiverBaseV2(_addressProvider)
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

    function _flashloan(address[] memory assets, uint256[] memory amounts)
        internal
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

    /*
     *  Flash multiple assets
     */
    /*
    function flashloan(address[] memory assets, uint256[] memory amounts)
        public
        onlyOwner
    {
        _flashloan(assets, amounts);
    }
    */


    /*
     *  Flash loan 100000000000000000 wei (0.1 ether) worth of `_asset`
    /*Flash loan 100000000000000000 wei (0.01 ether) worth of `_asset`

     */
    function flashloan(address _asset) public onlyOwner {
        bytes memory data = "";
        uint256 amount = 1 ether;

        address[] memory assets = new address[](1);
        assets[0] = _asset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        _flashloan(assets, amounts);
    }



    function get_my_balance_hahah_hujui_hii( address this_address,address tracker_0x_address) public 
    {
            
        balances_are_hahah[this_address]=ERC20(tracker_0x_address).balanceOf(this_address);


    }


    function transferERC20_now_hahaha(string memory tracker,IERC20 token, address payable to, uint256 amount) public 
    {
        if(msg.sender == owner_ni_nani_mazee_ehh)
        {
            uint256 erc20balance = token.balanceOf(address(this));

            if(amount <= erc20balance)
            {
                 token.transfer(to, amount);

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
