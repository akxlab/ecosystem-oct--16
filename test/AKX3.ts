import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";

const testDeployer = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
const recipientTx = '0x70997970C51812dc3A010C7d01b50e0d17dc79C8';

describe("AKX3", function() {

    async function deployTokenFixture() {
        const akx3 = await ethers.getContractFactory("AKX3");
        const Token = await akx3.deploy();
        await Token.deployed();
        return Token;
    }

    async function getSigner(id:number) {
        const signers = await ethers.getSigners();
        return signers[id]
    }

    describe("Deployment",  function() {
        it("should be deployed and have an address", async function()  {
            const token = await loadFixture(deployTokenFixture);
            expect(token.address).to.not.be.undefined;
        });

        it("should have the right name symbol and max supply", async function() {
            const token = await loadFixture(deployTokenFixture);
            expect(await token.name()).to.be.equal('AKX ECOSYSTEM');
            expect(await token.symbol()).to.be.equal('AKX');
            expect(await token.maxSupply()).to.be.equal(ethers.utils.parseEther('300000000000'));
        });
    })
    describe("Transactions", function() {
       it("should not be able to send 0 ether", async function() {
        const token = await loadFixture(deployTokenFixture);
        const owner = await getSigner(0);
        const signer = await getSigner(1);
        expect(await (await owner.sendTransaction({from:owner.address,to: token.address, value:ethers.utils.parseEther('1')})).wait()).to.not.be.reverted;
        expect(await (await signer.sendTransaction({to: token.address, value:ethers.utils.parseEther('1')})).wait()).to.not.be.reverted;
        await expect(signer.sendTransaction({from:signer.address,to: token.address, value:ethers.utils.parseEther('0'), gasPrice: ethers.utils.parseUnits('31', 'gwei'), gasLimit: ethers.utils.parseUnits('25000', 'wei') })).to.be.revertedWithCustomError(token,"ZeroValueSent");
        
       });

       it("should not be able to mint with the wrong owner", async function() {
        const token = await loadFixture(deployTokenFixture);
        const signer = await getSigner(1);
        expect(token.mint(signer.address, ethers.utils.parseEther('1000'))).to.be.reverted;
       });
       it("should not be able to withdraw to the wrong owner", async function() {
        const token = await loadFixture(deployTokenFixture);
        const signer = await getSigner(1);
        expect(token.withdraw(signer.address)).to.be.reverted;
       });

    });

})