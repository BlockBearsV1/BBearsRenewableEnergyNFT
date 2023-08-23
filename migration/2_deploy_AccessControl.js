const AccessControl = artifacts.require("AccessControl");

module.exports = function (deployer) {
  deployer.deploy(AccessControl);
};