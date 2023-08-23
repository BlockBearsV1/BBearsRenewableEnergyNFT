const Address = artifacts.require("Address");

module.exports = function (deployer) {
  deployer.deploy(Address);
};