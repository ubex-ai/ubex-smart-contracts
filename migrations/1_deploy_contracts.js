var UbexStorage = artifacts.require("./UbexStorage.sol");
var AdamCoefficients = artifacts.require("./AdamCoefficients.sol");
var SystemOwner = artifacts.require("./SystemOwner.sol");
var UbexExchange = artifacts.require("./UbexExchange.sol");

module.exports = function(deployer, network, accounts) {
  if (network === 'development') {
    deployer.deploy(SystemOwner).then(function () {
      return deployer.deploy(AdamCoefficients, SystemOwner.address)
    }).then(function () {
      return deployer.deploy(UbexStorage, SystemOwner.address);
    }).then(function () {
      return deployer.deploy(UbexExchange, UbexStorage.address, AdamCoefficients.address, SystemOwner.address);
    });
  } else {
    // production
  }
};
