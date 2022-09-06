// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ICharityProvider {
    function isCharity(address _address) external view returns (bool);
    function isEnsCharity(string calldata) external view returns (bool);
    function resolveCharityEns(string calldata) external view returns (address);
}
