pragma solidity >= 0.8.4;

import {IERC20 as IERC20Token} from '../../zeplin/token/ERC20/IERC20.sol';



abstract contract IBancorNetwork {
    function convertByPath(
        address[] memory _path, 
        uint256 _amount, 
        uint256 _minReturn, 
        address _beneficiary, 
        address _affiliateAccount, 
        uint256 _affiliateFee
    ) virtual external payable returns (uint256);

 function convert(
        address[] memory _path, 
        uint256 _amount, 
        uint256 _minReturn
        
    ) virtual external payable returns (uint256);



    function rateByPath(
        address[] memory _path, 
        uint256 _amount
    )virtual external view returns (uint256);

    function conversionPath(
        IERC20Token _sourceToken, 
        IERC20Token _targetToken
    )virtual external view returns ( address[] memory);
}