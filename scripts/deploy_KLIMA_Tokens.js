const { ethers } = require("hardhat");

/*
   Deploys KLIMA, sKLIMA, and wsKLIMA
 */
async function main() {
  const KlimaToken = await ethers.getContractFactory("KlimaToken");
  const klimaToken = await KlimaToken.deploy();

  console.log("Klima Token Deployed at: ", klimaToken.address);

  const sKlimaToken = await ethers.getContractFactory("sKLIMAv2");
  const sklimaToken = await sKlimaToken.deploy();

  console.log("sKlima Token Deployed at: ", sklimaToken.address);

  const wsKlimaToken = await ethers.getContractFactory("wsKLIMA");
  const wsklimaToken = await wsKlimaToken.deploy(sklimaToken.address);

  console.log("wsKlima Token Deployed at: ", wsklimaToken.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
