require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config({ path: "../.env" });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      viaIR: true
    }
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    sepolia: {
      url: process.env.SEPOLIA_URL || "",
      accounts: (process.env.PRIVATE_KEY && process.env.PRIVATE_KEY.length === 66) ? [process.env.PRIVATE_KEY] : []
    },
    mainnet: {
      url: process.env.MAINNET_URL || "",
      accounts: (process.env.PRIVATE_KEY && process.env.PRIVATE_KEY.length === 66) ? [process.env.PRIVATE_KEY] : []
    },
    polygon: {
      url: process.env.POLYGON_URL || "",
      accounts: (process.env.PRIVATE_KEY && process.env.PRIVATE_KEY.length === 66) ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      sepolia: process.env.ETHERSCAN_API_KEY,
      polygon: process.env.ETHERSCAN_API_KEY,
    }
  },
  sourcify: {
    enabled: true,
  },
};
