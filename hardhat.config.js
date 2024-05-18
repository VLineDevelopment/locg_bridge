require("@nomicfoundation/hardhat-toolbox");
const dotenv = require('dotenv')
dotenv.config({path: './.env'})
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    defaultNetwork: "sepolia",
  networks: {
    hardhat: {
    },
    sepolia: {
      url: "https://ethereum-sepolia-rpc.publicnode.com",
      accounts: [process.env.WALLET_PRIV_KEY]
    },
    opsepolia: {
      url:"https://sepolia.optimism.io",
      accounts: [process.env.WALLET_PRIV_KEY]
    },
    basesepolia: {
      url: "https://public.stackup.sh/api/v1/node/base-sepolia",
      accounts: [process.env.WALLET_PRIV_KEY]
    }
  },
  solidity: {
   compilers: [{ version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }}},
    { version: "0.8.1",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }}},
    { version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }}}
    ]
    },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  },
  sourcify: {enabled: false},
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_KEY,
      opsepolia: process.env.OPSEPOLIASCAN_KEY
    },
      customChains: [
    {
      network: "opsepolia",
      chainId: 11155420,
      urls: {
        apiURL: "https://api-sepolia-optimistic.etherscan.io/api" ,
        browserURL: "https://docs.optimism.etherscan.io"
      },
      // apiKey: {"OP Sepolia": process.env.OPSEPOLIASCAN_KEY}
    }
  ]
  }
};
