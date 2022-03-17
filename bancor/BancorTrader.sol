pragma solidity >= 0.8.4;

import './interfaces/IContractRegistry.sol';
import './interfaces/IBancorNetwork.sol';


import "hardhat/console.sol"; 
 

contract BancorTrader {
    IContractRegistry contractRegistry = IContractRegistry(0xFD95E724962fCfC269010A0c6700Aa09D5de3074); // "ropsten"
    bytes32 public constant bancorNetworkName="BancorNetwork";

                function getBancorNetworkContract() public returns(IBancorNetwork)
                { 
                        return IBancorNetwork(contractRegistry.addressOf(bancorNetworkName));

                }


    
    function trade(
        IERC20Token _sourceToken, 
        IERC20Token _targetToken, 
        uint _amount
    ) external payable returns(uint returnAmount) 

    {
         

         
            IBancorNetwork bancorNetwork = getBancorNetworkContract();
            console.log("ROUTER SET");
          
                    address[] memory path = bancorNetwork.conversionPath(_sourceToken,_targetToken );
                    uint minReturn = bancorNetwork.rateByPath( path, _amount );

                    console.log("minReturn '%d':",minReturn);
                  
              
                   /*
                    returnAmount = bancorNetwork.convertByPath{value: msg.value}(
                        path,
                         _amount,
                        minReturn,
                         address(this),
                        address(0x0),
                        0
                    );
                    
                      
                        returnAmount = bancorNetwork.convert{value: msg.value}(
                                                path,
                                                _amount,
                                                minReturn
                                            );
                        */

                    console.log("returnAmount '%d':",returnAmount);
                 
    }

}