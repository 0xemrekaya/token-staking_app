require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  
  paths: {
    artifacts: './src/artifacts',
  },

  networks: {
    //Localhost requires an instance of ganache or similar local node
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]

    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY
  }

}
