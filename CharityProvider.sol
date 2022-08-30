// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Owner
 * @dev Set & change owner
 */
contract CharityProvider is Ownable {
    mapping(address => bool) isCharityAddress;

    function isCharity(address _address) external view returns (bool) {
        return isCharityAddress[_address];
    }

    function addCharities(address[] calldata charities) external onlyOwner {
        for(uint i; i < charities.length; i++) {
            isCharityAddress[charities[i]] = true;
        }
    }

    function removeCharities(address[] calldata notCharities) external onlyOwner {
        for(uint i; i < notCharities.length; i++) {
            isCharityAddress[notCharities[i]] = false;
        }
    }

} 
