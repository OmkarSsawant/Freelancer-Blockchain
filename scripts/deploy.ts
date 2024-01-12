import { ethers } from "hardhat";

async function deployFreelanceContract(){
  const owner = (await ethers.getSigners())[0];
  const contractReq = await ethers.deployContract("Freelance",owner);
  const freelance = await contractReq.waitForDeployment()
  console.log((await ethers.provider.getNetwork()).chainId);
  
  console.log("Freelance Contract Deplyed at ",await freelance.getAddress());
}



async function main() {
    await deployFreelanceContract()
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
