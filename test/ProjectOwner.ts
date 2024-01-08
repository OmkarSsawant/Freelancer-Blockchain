import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
  import { expect } from "chai";
  import { ethers } from "hardhat";
import { Freelance } from "../typechain-types";
  describe("Developer Tests", ()=>{
    const DAY_millis = 24 * 60 * 60 * 1000;
    async function deployFixedContract(){
      const signers = await ethers.getSigners();
      const freelanceFactory = await ethers.getContractFactory("Freelance",signers[2]);
       return freelanceFactory.deploy();
    }
    var freelance:Freelance
   
    before(async () => {
        freelance = await loadFixture(deployFixedContract);
        const signers = await ethers.getSigners();
        freelance.attach(signers[1])
        expect((await(await freelance.registerProjectOwner(
            b32("ZukerBerg") ,
            b32("zukerberg@insta.fb"),
            9999999999999,
            b32("ipfs://licence_mine.pdf"),
            false,
            b32("visionDev"),
            b32("https://visionDev.com"),
            2,
            b32("ipfs://company_profile_pic")
     )).wait())?.status).eq(1);

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
    const b32 = (s:string) =>ethers.encodeBytes32String(s)

      it("Registers Project Owner",async()=> {
        
                expect((await(await freelance.registerProjectOwner(
                    b32("ZukerBerg") ,
                    b32("zukerberg@insta.fb"),
                    9999999999999,
                    b32("ipfs://licence_mine.pdf"),
                    false,
                    b32("visionDev"),
                    b32("https://visionDev.com"),
                    2,
                    b32("ipfs://company_profile_pic")
             )).wait())?.status).eq(1);
       })

       it("finalizes Project Bid",async()=>{
            const dev = (await ethers.getSigners())[2];
            expect((await(await freelance.finalizeProjectBid(ethers.parseEther("0.01"),0,"I have already developed such apps",[],dev )).wait())?.status).eq(1);
        })

       it("Updates Project Status",async()=>{
        await(   await freelance.addWorksAndPays(0,["Create UI/UX","Develop App","Publish App"],[
            ethers.parseEther("0.001"),
            ethers.parseEther("0.002"),
            ethers.parseEther("0.003"),
           ])).wait();
           const dev = (await ethers.getSigners())[2];
            expect((await(await freelance.finalizeProjectBid(ethers.parseEther("0.01"),0,"I have already developed such apps",[],dev )).wait())?.status).eq(1);  
        expect((await(await freelance.updateProjectStatus(0)).wait())?.status).eq(1);

       })

       it("Only Project Owner adds Review",async()=>{
        expect((await(await freelance.addReview(
                0,"Great Work , Very Hardworking "
            )).wait())?.status).eq(1);
       })
    });