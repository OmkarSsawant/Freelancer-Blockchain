import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";




describe("Freelace Contract",()=>{
const DAY_millis =  24 * 60 * 60 * 1000;
  async function deployFixedContract(){
    const signers = await ethers.getSigners();
    const freelanceFactory = await ethers.getContractFactory("Freelance",signers[0]);
     return freelanceFactory.deploy();
  }


  describe("Project Related Tests",()=>{
    it("Creates a project",async()=>{
      const freelance = await loadFixture(deployFixedContract);
      const signers = await ethers.getSigners();
      const deadline = BigInt( Date.now() +  2 * DAY_millis) ; 
      const created = await freelance.createProject(
          signers[1].address,
          ethers.encodeBytes32String("Sample Project 1"),
          ethers.parseEther("0.002"),
          ethers.encodeBytes32String("ipfs://mydocurl"),
          ethers.encodeBytes32String("mobile"),
           deadline,
           ethers.parseEther("0.02"),
      {value:ethers.parseEther("0.002")});

      expect(created);
      console.log("Created Project");
      })

  })


});
