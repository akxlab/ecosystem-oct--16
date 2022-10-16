import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {ethers, upgrades} from 'hardhat';

const {utils} = require("ethers");


const presale: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

    const {deployments, getNamedAccounts} = hre;
	const {deploy} = deployments;
    const symbol = "AKX";
    const token = await deployments.get("AKX3");
   // const oracle = await deployments.get("PriceOracle");
   // const basePrice = ethers.utils.parseEther("8.40"); // price per 1 matic
    const deployers = await hre.ethers.getSigners();
  //  const deployer = process.env.DEPLOYER || "";
  const deployer = deployers[0].address;
   
    const akx = await ethers.getContractFactory("AKXTokenLogicEth");
  const Presale = await deploy("AKXTokenLogicEth", { from: deployer,
  args: ['0xA0FfdA7eA0E7FAd61f0dd2F93CEbdF8E5CEcc85E', '0xa48C4b069D8c2FE71BbB8525D85D38Fca064a1F2', ethers.utils.parseEther('0.000075')],
  log: true,
  autoMine: true,
  waitConfirmations:2}
  ); 

 

    const a = await ethers.getContractAt("AKX3", token.address);
    await (await a.grantRole('0x49a42a47740a9060c9a9274a2a577b05376ac78e16f4e6059683e3adb436d2c4', Presale.address)).wait();

    const p = await ethers.getContractAt("AKXTokenLogicEth", Presale.address);
   // await (await p.addFounder("0x670c2c3953bC3fa09e0d24D089cb3976967bac67", ethers.utils.parseUnits('4'))).wait();
   // await (await p.addFounder("0xcd63a517dBACe7c597D275Afb8DcCaFbf073Cb63", ethers.utils.parseUnits('4'))).wait();

    // console.log(p.address);


}

presale.tags = ['presale'];

export default presale;