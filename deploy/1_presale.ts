import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {ethers, upgrades} from 'hardhat';

const {utils} = require("ethers");


const presale: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

    const {deployments, getNamedAccounts} = hre;
	const {deploy} = deployments;
    const symbol = "AKX";
    const token = await deployments.get("AKX3");
    const oracle = await deployments.get("PriceOracle");
    const basePrice = ethers.utils.parseEther("8.40"); // price per 1 matic
    const deployers = await hre.ethers.getSigners();
    const deployer = process.env.DEPLOYER || "";
   // const deployer = deployers[0].address;
   
    const akx = await ethers.getContractFactory("AKXTokenLogic");
  const Presale = await upgrades.deployProxy(akx, [symbol, token.address, oracle.address, basePrice, '0x044e25f98fA9f46BEda68f1469E83dcDBF7C8d4A','0x5dA5aE3f9E4ee7682A2b0a233E4553A21b4f0044'],
       {kind:"transparent", initializer:"initialize", unsafeAllow:["constructor", "delegatecall", "state-variable-assignment"]}
  ); 

  await Presale.deployed();

    const a = await ethers.getContractAt("AKX3", token.address);
    await (await a.grantRole('0x49a42a47740a9060c9a9274a2a577b05376ac78e16f4e6059683e3adb436d2c4', Presale.address)).wait();

    const p = await ethers.getContractAt("AKXTokenLogic", Presale.address);
    await (await p.addFounder("0x670c2c3953bC3fa09e0d24D089cb3976967bac67", ethers.utils.parseUnits('4'))).wait();
    await (await p.addFounder("0xcd63a517dBACe7c597D275Afb8DcCaFbf073Cb63", ethers.utils.parseUnits('4'))).wait();

    console.log(p.address);


}

presale.tags = ['presale'];

export default presale;