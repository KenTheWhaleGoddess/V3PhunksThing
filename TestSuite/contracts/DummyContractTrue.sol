// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DummyBalanceContractTrue {

    uint256 returnValue;

    constructor() {
        returnValue = 1;
    }

    function balanceOf(address _dummy_wallet) public view returns (uint256) {
        return returnValue;
    }
    
    function getContractAddress() public view returns(address) {
        return address(this);
    }
    
}