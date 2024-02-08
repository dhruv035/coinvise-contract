import { HardhatUserConfig } from "hardhat/config";
require('dotenv').config()
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.20",
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
