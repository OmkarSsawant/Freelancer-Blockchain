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
    

    // freelance.attach(dev)
    it("Registers Developer",async()=> {
        expect((await (await  freelance.registerDeveloper(
            ethers.encodeBytes32String("Sam Altman"),
            ethers.encodeBytes32String("ipfs://devloper_profile_photo"),
            ["react","flutter","blockchain","hardhat"].map(ethers.encodeBytes32String),
            ethers.encodeBytes32String("Full Stack Developer @ CoinDCX")
          ) ).wait())?.status).eq(1);    
           
      })

     it("Only Developer Signs Agreement",async()=> {
      expect((await(await  freelance.signAgreement(0)).wait())?.status).eq(1)
     })
     
     it("Gets Projects of developer none completed so must be empty",async()=> {
    const dev = (await ethers.getSigners())[2]

      expect((await  freelance.getProjectsOfDev(dev))).empty;
     })
     
     it("Gets  Completed Projects of developer Count",async()=> {
    const dev = (await ethers.getSigners())[2]

      expect((await  freelance.getCompletedProjectsCountOfDev(dev))).not.null;
     })

     it("Get Dev Bid Coins",async ()=> {
        const dev = (await ethers.getSigners())[2]
        expect((await  freelance.getDevBidTokens(dev))).not.eq(0);
     })

     it("Deducts bid token on bid placing",async()=> {
        const dev = (await ethers.getSigners())[2]
        const curTokens = await  freelance.getDevBidTokens(dev);
      await freelance.devPlaceBids(dev,1);
      expect(curTokens).not.eq(await  freelance.getDevBidTokens(dev))
     })
  })


