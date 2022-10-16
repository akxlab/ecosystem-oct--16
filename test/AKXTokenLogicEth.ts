import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";


const testDeployer = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
const recipientTx = '0x70997970C51812dc3A010C7d01b50e0d17dc79C8';

const opts = {from: testDeployer, gasPrice: ethers.utils.parseUnits('31', 'gwei'), gasLimit: ethers.utils.parseUnits('350000', 'wei')}
const optsBuy = {value: ethers.utils.parseEther('1'), gasPrice: ethers.utils.parseUnits('31', 'gwei'), gasLimit: ethers.utils.parseUnits('350000', 'wei')}
describe("AKX3Presale", function() {

    async function deployTokenFixture() {
        const akx3 = await ethers.getContractFactory("AKX3");
        const Token = await akx3.deploy();
        await Token.deployed();
        return Token;
    }

    async function deployPresaleContract() {
        const akx3 = await ethers.getContractFactory("AKX3");
        const Token = await akx3.deploy();
        await Token.deployed();
        const presale = await ethers.getContractFactory("AKXTokenLogicEth");
        const args = [testDeployer,recipientTx,ethers.utils.parseEther('1')]; // for testing purpose lets make the price 1:1 (1 akx for 1 ether);
        const p = await presale.deploy(`${args[0]}`,`${args[1]}`,args[2]);
        await p.deployed();
        const signer = await getSigner(0);

        await p.grantRole('0x414b585f4f50455241544f525f524f4c45000000000000000000000000000000', signer.address);
        await Token.grantRole('0x49a42a47740a9060c9a9274a2a577b05376ac78e16f4e6059683e3adb436d2c4', p.address);
        
        await p.setUnderlyingToken(Token.address, opts);
        return {p, Token};
    }

    async function getSigner(id:number) {
        const signers = await ethers.getSigners();
        return signers[id]
    }

    describe("Deployment",  function() {
        it("should be deployed and have an address", async function()  {
       
         const {p,Token} = await loadFixture(deployPresaleContract);
            expect(p.address).to.not.be.undefined;
        });

        it("should not be able to initialize without proper role", async function() {
            const token = await loadFixture(deployTokenFixture);
            const tokenAddress = token.address;
           
            const {p,Token} = await loadFixture(deployPresaleContract);
            const signer = await getSigner(0);
         
           await expect(p.setUnderlyingToken(tokenAddress, opts)).to.not.be.revertedWith('AccessControl: account 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 is missing role 0x414b585f4f50455241544f525f524f4c45000000000000000000000000000000');

        });
        it("should be able to assign role and initialize", async function () {
            const akx3 = await ethers.getContractFactory("AKX3");
          
           
            const {p,Token} = await loadFixture(deployPresaleContract);
            const signer = await getSigner(0);

           await p.grantRole('0x414b585f4f50455241544f525f524f4c45000000000000000000000000000000', signer.address);
           Token.grantRole('0x414b585f4f50455241544f525f524f4c45000000000000000000000000000000', signer.address);
         
           await expect(p.setUnderlyingToken(Token.address, opts)).to.not.be.reverted;
        });
      

      
    });
    describe("Founders", function() {
        it("should be able to add founders", async function() {

            const founders = await ethers.getContractFactory("Founders");
            const akx3 = await ethers.getContractFactory("AKX3");
            const Token = await akx3.deploy();
            await Token.deployed();
            const tokenAddress = Token.address;
            const f = await founders.deploy(tokenAddress);
            const f1 = await getSigner(1);
            const f2 = await getSigner(2);
            const f3 = await getSigner(3);
            const signer = await getSigner(0);

            const foundersArr = [f1.address, f2.address, f3.address];

            f.grantRole('0x414b585f4f50455241544f525f524f4c45000000000000000000000000000000', signer.address);

            expect(await f.addFounder(foundersArr[0])).to.not.be.reverted;
            expect(await f.addFounder(foundersArr[1])).to.not.be.reverted;
            expect(await f.addFounder(foundersArr[2])).to.not.be.reverted;

        });
    });

    describe("Buying and transfering", function() {
        it("should be able to buy akx", async function() {
           
        
           
            const {p,Token}= await loadFixture(deployPresaleContract);
            const signer = await getSigner(0);
           const date = Math.floor(new Date().getTime()/1000);
           expect(await p.buy(date, optsBuy)).to.emit(Token,"Buy(address,uint256,uint256)");
           console.log(await Token.balanceOf(signer.address));
           expect(await Token.balanceOf(signer.address)).to.equal(ethers.utils.parseEther('1'));

        });
        it("should not be able to transfer while locked", async function() {
            const {p,Token}= await loadFixture(deployPresaleContract);
            const signer = await getSigner(0);

            await expect(Token.transfer(recipientTx, ethers.utils.parseEther('0.5'), {from: signer.address})).to.be.reverted;

        });
    })
});