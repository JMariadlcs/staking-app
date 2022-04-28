require("@nomiclabs/hardhat-waffle")
// require("@nomiclabs/hardhat-etherscan")
require("hardhat-deploy")
// require("solidity-coverage")
// require("hardhat-gas-reporter")
// require("hardhat-contract-sizer")
// require("./tasks")
// require("@appliedblockchain/chainlink-plugins-fund-link")
// require("dotenv").config()

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  namedAccounts: {
    deployer: { // deployer account
      default: 0, // ethers built an account at index 0
    }
  }
};