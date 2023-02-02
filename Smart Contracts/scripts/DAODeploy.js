const hre = require("hardhat");

async function main() {
    const tokenAddress = token.address;

    const _joinAmount = 50 * (10 ** 18);
    const joinAmount = BigInt(_joinAmount);
    const _contributionAmount = 2 * (10 ** 18);
    const contributionAmount = BigInt(_contributionAmount);
    const successThreshold = 10;
    const _accessAmount = 0.5 * (10 ** 18);
    const accessAmount = BigInt(_accessAmount);

  const DAOContract = await hre.ethers.getContractFactory("peerToken");
  const daocontract = await DAOContract.deploy(tokenAddress, joinAmount, contributionAmount, successThreshold, accessAmount);

  await daocontract.deployed();

  console.log(daocontract.address);
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
