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
    const token = await deployments.get("AKX3");

    const founders = await deploy("Founders", {
        from: deployer,
        args: ['0x5FbDB2315678afecb367f032d93F642f64180aa3'],
        log: true,
        autoMine: true,
        waitConfirmations:2}
    )

    
    const a = await ethers.getContractAt("AKX3", token.address);
    await (await a.grantRole('0x49a42a47740a9060c9a9274a2a577b05376ac78e16f4e6059683e3adb436d2c4', founders.address)).wait();



}
toeth.tags = ['eth_setup'];
export default toeth;