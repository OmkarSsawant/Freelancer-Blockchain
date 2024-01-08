import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Freelance } from "../typechain-types";

describe("Freelance Contract", () => {
  const DAY_millis = 24 * 60 * 60 * 1000;

  async function deployFixedContract() {
    const signers = await ethers.getSigners();
    const freelanceFactory = await ethers.getContractFactory("Freelance", signers[0]);
    return freelanceFactory.deploy();
  }

  let freelance:Freelance; // Declare the variable outside the beforeEach block.

  before(async () => {
    freelance = await loadFixture(deployFixedContract);
    const signers = await ethers.getSigners();
      const deadline = BigInt(Date.now() + 2 * DAY_millis);
      const cp1 = await freelance.createProject(
        signers[1].address,
        ethers.encodeBytes32String("Sample Project 1"),
        ethers.encodeBytes32String("ipfs://mydocurl"),
        ethers.encodeBytes32String("mobile"),
        deadline,
        ethers.parseEther("0.02"),
        { value: ethers.parseEther("0.002") }
      );
   
      const cp2 = await freelance.createProject(
        signers[1].address,
        ethers.encodeBytes32String("Sample Project 1"),
        ethers.encodeBytes32String("ipfs://mydocurl"),
        ethers.encodeBytes32String("mobile"),
        deadline,
        ethers.parseEther("0.02"),
        { value: ethers.parseEther("0.002") }
      );
      
  });

  describe("About Project", () => {
    it("Created Project", async () => {
      const signers = await ethers.getSigners();
      const deadline = BigInt(Date.now() + 2 * DAY_millis);
      const created = await freelance.createProject(
        signers[1].address,
        ethers.encodeBytes32String("Sample Project 1"),
        ethers.encodeBytes32String("ipfs://mydocurl"),
        ethers.encodeBytes32String("mobile"),
        deadline,
        ethers.parseEther("0.02"),
        { value: ethers.parseEther("0.002") }
      );
      
      expect(created);
      console.log("Created Project");
    });

    it("Project Status is Uninit", async () => {
      const signers = await ethers.getSigners();
      const deadline = BigInt(Date.now() + 2 * DAY_millis);
      const created = await freelance.createProject(
        signers[1].address,
        ethers.encodeBytes32String("Sample Project 1"),
        ethers.encodeBytes32String("ipfs://mydocurl"),
        ethers.encodeBytes32String("mobile"),
        deadline,
        ethers.parseEther("0.02"),
        { value: ethers.parseEther("0.002") }
      );
      console.log(await freelance.getProjectStatus(1));
      expect(await freelance.getProjectStatus(1)).eq(0);
    });

    it("Get Projects of owner", async () => {
    const signers = await ethers.getSigners();

      const owner = signers[1].address;
      
      expect(await freelance.getProjectsOfOwner(owner)).not.empty;
    });


   
  });
});
