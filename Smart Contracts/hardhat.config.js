require("@nomicfoundation/hardhat-toolbox");

const privateKey = "05a78a752e876b28304ed67c6c0cb05545693c99df446e8f8c27734209240e8c";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hyperspace: {
      url: "https://api.hyperspace.node.glif.io/rpc/v1",
      chainId: 3141,
      accounts: [privateKey]
    },
    
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      chainId: 80001,
      accounts: [privateKey]
    },

    BSCTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      accounts: [privateKey]
    }
  }
};