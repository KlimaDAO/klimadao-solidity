const { ethers, upgrades } = require("hardhat");

/*
   Deploys pKLIMA to be mapped
 */

const chainManagerMumbai = "0xb5505a6d998549090530911180f38aC5130101c6";
const chainManagerMatic = "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa";
const KlimaAdmin = "0x693aD12DbA5F6E07dE86FaA21098B691F60A1BEa";

async function main() {
  const pKLIMAChild = await ethers.getContractFactory("PreKlimaTokenUpgradeableChild");

  const pKLIMAChildDeploy = await upgrades.deployProxy(pKLIMAChild,[KlimaAdmin, chainManagerMumbai], { initializer: false});
  await pKLIMAChildDeploy.deployed();
  console.log("Pklima Child Deployed at: ", pKLIMAChildDeploy.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
