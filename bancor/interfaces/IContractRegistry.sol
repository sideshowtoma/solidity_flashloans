pragma solidity >= 0.8.4;



abstract contract IContractRegistry {
     function  addressOf(
        bytes32 contractName
    )virtual external returns(address);
}

