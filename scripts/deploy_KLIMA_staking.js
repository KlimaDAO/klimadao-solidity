const { ethers } = require("hardhat");

/*
   Deploys KLIMA staking contracts
 */
async function main() {
  const KlimaStaking = await ethers.getContractFactory("KlimaStaking_v2");
  const klimaStaking = await KlimaStaking.deploy(
    process.env.KLIMA_ERC20_ADDRESS,
    process.env.SKLIMA_ERC20_ADDRESS,
    11520, // epoch length in blocks
    0, // first epoch number
    0 // first epoch block
  );

  console.log("Klima Staking Deployed at: ", klimaStaking.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
