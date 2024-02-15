import { HardhatUserConfig } from "hardhat/config";
require('dotenv').config()
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    version:"0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 20000,
        
      },
    },
  },
  etherscan:{
    apiKey: {
      polygonMumbai:process.env.POLYGONSCAN??""
    }
  },
  networks:{
    goerli:{
      url:process.env.GOERLI_RPC,
      accounts:[process.env.PRIVATE_KEY??""]
    },
    mumbai:{
      url:process.env.MUMBAI_RPC,
      accounts:[process.env.PRIVATE_KEY??""]
    }
  }
};

export default config;
