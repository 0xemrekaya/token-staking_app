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
    localhost01: {
      url: "HTTP://0.0.0.0:7545",
      accounts: { mnemonic: process.env.LOCALHOST_SECRET_KEY }
    },
    localhost2: {
      url: "http://127.0.0.1:8545",
      chainId: 1337,
      gasPrice: 1000,
      accounts: { mnemonic: "test test test test test test test test test test test junk" }

    },

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
