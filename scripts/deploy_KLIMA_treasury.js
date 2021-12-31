const { ethers } = require("hardhat");

/*
   Deploys KLIMA treasury
 */
async function main() {
  const KlimaTreasury = await ethers.getContractFactory("KlimaTreasury");
  const klimaTreasury = await KlimaTreasury.deploy(
    process.env.KLIMA_ERC20_ADDRESS,
    process.env.BCT_ERC20_ADDRESS,
    34560 // amount of blocks needed to queue txs before they can be executed
  );

  console.log("Klima Treasury Deployed at: ", klimaTreasury.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
