const hre = require("hardhat");

async function main() {
  const name = "PeerDAO";
  const symbol = "PED";

  const peerToken = await hre.ethers.getContractFactory("peerToken");
  const peertoken = await peerToken.deploy(name, symbol);

  await peertoken.deployed();

  console.log(peertoken.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
