pragma solidity 0.8.12;

interface ICharityProvider {
    function isCharity(address _address) external view returns (bool);
}
