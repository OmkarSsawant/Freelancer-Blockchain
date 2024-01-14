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
        ethers.encodeBytes32String("Sample Project 1"),
        ethers.encodeBytes32String("mobile"),
        deadline,
        ethers.parseEther("0.02"),
        ethers.encodeBytes32String("mobile app"),
        { value: ethers.parseEther("0.002") }
      );
   
     console.log(`Core Project Created ${cp1}`);
     
      
  });

  describe("About Project", () => {
    it("Add  Project Details to recent", async () => {
      const signers = await ethers.getSigners();
      const deadline = BigInt(Date.now() + 2 * DAY_millis);
      const created = await freelance.addProjectDetails(
        "A description",
        ["flutter","web"].map((e)=>ethers.encodeBytes32String(e)),
        ethers.encodeBytes32String("ipfs://sample"),
        "Eligible",["roler skates"],["w1","w2","w3"],[1,2,3]
      );
      
      expect(created);
      console.log(`Details to Project added ${created}`);
    });

    it("Gets Tasks And Pays Of Project Updates",async()=>{
         console.log(await freelance.getTasksAndPays(0));
      var txn =await freelance.updateProjectStatus(0);
      var u = await freelance.getTasksAndPays(0);
      console.log("u1",u);
      var txn =await freelance.updateProjectStatus(0);
      console.log("u2",await freelance.getTasksAndPays(0));
      expect(u[2]!=BigInt(0),"not Updated");
        })

    // it("Project Status is Uninit", async () => {
    //   const signers = await ethers.getSigners();
    //   const deadline = BigInt(Date.now() + 2 * DAY_millis);
   
    //   console.log(await freelance.getProjectStatus(1));
    //   expect(await freelance.getProjectStatus(1)).eq(0);
    // });

    // it("Get Projects of owner", async () => {
    // const signers = await ethers.getSigners();

    //   const owner = signers[1].address;
      
    //   expect(await freelance.getProjectsOfOwner(owner)).not.empty;
    // });

    // it("Adds Works and assoc. payment",async ()=> {
    //   expect((await(   await freelance.addWorksAndPays(0,["Create UI/UX","Develop App","Publish App"],[
    //     ethers.parseEther("0.001"),
    //     ethers.parseEther("0.002"),
    //     ethers.parseEther("0.003"),
    //    ])).wait())?.status).eq(1);
    // })
   
  });
});
