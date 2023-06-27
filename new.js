require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

module.exports = {
  defaultNetwork: "polygon_mumbai",
  networks: {
    hardhat: {
    },
    polygon_mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: ['02e92ea268c29d20f29b4b7398a54dc389d6fd6ce4415ce67a0fe7c0d79b1a26']
    }
  },
  etherscan: {
    apiKey: "XGC2AQPVEC7S3RRBHX29FS8JQXPQGINM18"
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
}