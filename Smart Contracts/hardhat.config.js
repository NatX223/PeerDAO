require("@nomicfoundation/hardhat-toolbox");

const privateKey = "1c11effa8507816a38a5de6bbe05daed06e45961235ca2c833234c6b0ae0f06a";

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
    }
  }
};