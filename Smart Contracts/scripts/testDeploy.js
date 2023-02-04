const hre = require("hardhat");

async function main() {
  const name = "PeerDAO";
  const symbol = "PED";

  const peerToken = await hre.ethers.getContractFactory("peerToken");
  const peertoken = await peerToken.deploy(name, symbol);

  await peertoken.deployed();

  const tokenAddress = peertoken.address;

  const _joinAmount = 50 * (10 ** 18);
  const joinAmount = BigInt(_joinAmount);
  const _contributionAmount = 2 * (10 ** 18);
  const contributionAmount = BigInt(_contributionAmount);
  const successThreshold = 10;
  const _accessAmount = 0.5 * (10 ** 18);
  const accessAmount = BigInt(_accessAmount);

const DAOContract = await hre.ethers.getContractFactory("PeerDAO");
const daocontract = await DAOContract.deploy(tokenAddress, joinAmount, contributionAmount, successThreshold, accessAmount);

await daocontract.deployed();

const DAOaddress = daocontract.address;

const role = "Content Creator";


const allMembers = await daocontract.getAllMembers();

console.log(daocontract.address, peertoken.address, allMembers);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});