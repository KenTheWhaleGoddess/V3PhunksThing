 // SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface ICharityProvider {
    function isEnsCharity(string calldata) external view returns (bool);
    function resolveCharityEns(string calldata) external view returns (address);
}
