const SignedMath = artifacts.require("SignedMath");

module.exports = function (deployer) {
  deployer.deploy(SignedMath);
};