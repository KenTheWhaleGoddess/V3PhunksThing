// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title Owner
 * @dev Set & change owner
 */
contract CharityProvider is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet charities;

    function getCharities() external view returns (address[] memory) {
        return charities.values();
    }

    function isCharity(address _address) external view returns (bool) {
        return charities.contains(_address);
    }

    function addCharities(address[] calldata charitiesList) external onlyOwner {
        for(uint i; i < charitiesList.length; i++) {
            charities.add(charitiesList[i]);
        }
    }

    function removeCharities(address[] calldata notCharities) external onlyOwner {
        for(uint i; i < notCharities.length; i++) {
            charities.remove(notCharities[i]);
        }
    }

} 
