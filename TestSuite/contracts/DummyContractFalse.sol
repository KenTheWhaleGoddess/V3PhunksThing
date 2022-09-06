// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DummyBalanceContractFalse {

    uint256 returnValue;

    constructor() {
        returnValue = 0;
    }

    function balanceOf(address _dummy_wallet) public view returns (uint256) {
        return returnValue;
    }
    
    function getContractAddress() public view returns(address) {
        return address(this);
    }
    
}