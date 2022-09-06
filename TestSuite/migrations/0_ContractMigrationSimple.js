const DummyBalanceContractFalse = artifacts.require("DummyBalanceContractFalse");
const DummyBalanceContractTrue = artifacts.require("DummyBalanceContractTrue");
const CharityProvider = artifacts.require("CharityProvider");
const OpenEdition = artifacts.require("OpenEdition");


// ensure it overwrites all states on migration 
// truffle migrate --reset
module.exports = function (deployer) {
  deployer.deploy(DummyBalanceContractFalse);
  deployer.deploy(DummyBalanceContractTrue);
  deployer.deploy(CharityProvider);
  deployer.deploy(OpenEdition);
};
