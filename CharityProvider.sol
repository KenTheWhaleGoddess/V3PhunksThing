// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./SSTORE2.sol";
import "./IENS.sol";
/**
 * @title Owner
 * @dev Set & change owner
 */
contract CharityProvider is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet charities;
    mapping(string => address) charitiesEnsCheck;

    ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    function isCharity(address _address) external view returns (bool) {
        return charities.contains(_address);
    }

    function isEnsCharity(string calldata _ens) external view returns (bool) {
        return charitiesEnsCheck[_ens] != address(0);
    }
    function resolveCharityEns(string calldata _ens) external view returns (address) {
        require(charitiesEnsCheck[_ens] != address(0));
        bytes32 node = keccak256(abi.encodePacked(SSTORE2.read(charitiesEnsCheck[_ens])));
        Resolver resolver = ens.resolver(node);
        return resolver.addr(node);
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
    function addCharitiesEns(string[] calldata charitiesList) external onlyOwner {
        for(uint i; i < charitiesList.length; i++) {
            charitiesEnsCheck[charitiesList[i]] = SSTORE2.write(bytes(charitiesList[i]));
        }
    }

    function removeCharitiesEns(string[] calldata notCharities) external onlyOwner {
        for(uint i; i < notCharities.length; i++) {
            charitiesEnsCheck[notCharities[i]] = address(0);
        }
    }

} 
