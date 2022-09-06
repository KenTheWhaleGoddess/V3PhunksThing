// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract ENS {
    function resolver(bytes32 node) public virtual view returns (Resolver);
}

abstract contract Resolver {
    function addr(bytes32 node) public virtual view returns (address);
}
