import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {ethers, upgrades} from 'hardhat';

const {utils} = require("ethers");


const toeth: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts} = hre;
	const {deploy} = deployments;
    const deployers = await hre.ethers.getSigners();
    //const deployer = process.env.DEPLOYER || "";
    const deployer = deployers[0].address;

    const token = await deploy("AKX3", {
        from: deployer,
        args: [],
        log: true,
        autoMine: true,
        waitConfirmations:2,
    });

    const akx = await ethers.getContractFactory("AKXTokenLogicEth");
    const Presale = await upgrades.deployProxy(akx, [token.address,  utils.parseEther("0.0000754"), '0x8236088bf233De07EF9CF411794dEc3f72BdB8aa','0x8236088bf233De07EF9CF411794dEc3f72BdB8aa'],
         {kind:"transparent", initializer:"initialize", unsafeAllow:["constructor", "delegatecall", "state-variable-assignment"]}
    ); 
  
    await Presale.deployed();
  
      const a = await ethers.getContractAt("AKX3", token.address);
    await (await a.grantRole('0x49a42a47740a9060c9a9274a2a577b05376ac78e16f4e6059683e3adb436d2c4', Presale.address)).wait();
  
     const p = await ethers.getContractAt("AKXTokenLogicEth", Presale.address);
      await (await p.addFounder("0xcbbfA35844900F9940beC9F9EB5EEE1228Da0E7F")).wait();
      await (await p.addFounder("0xcd63a517dBACe7c597D275Afb8DcCaFbf073Cb63")).wait();
  



}
toeth.tags = ['eth_setup'];
export default toeth;