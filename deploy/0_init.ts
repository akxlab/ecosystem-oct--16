import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {ethers, upgrades} from 'hardhat';

const {utils} = require("ethers");


const func0: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;
    const deployers = await hre.ethers.getSigners();
    //const deployer = process.env.DEPLOYER || "";
    const deployer = deployers[0].address;

    console.log("Deploying contracts with the account:", deployer);

    console.log("Account balance:", (await deployers[0].getBalance()).toString());

    const basePrice = ethers.utils.parseEther("8.45"); // price per 1 matic
    const symbol = "AKX";

  
    const token = await deploy("AKX3", {
        from: deployer,
        args: [],
        log: true,
        autoMine: true,
        waitConfirmations:2,
    });

   

    const oracle =  await deploy("PriceOracle", {
        from: deployer,
        args: [],
        log: true,
        autoMine: true,
        waitConfirmations:2
    });

  

    const iOracle = await ethers.getContractAt("PriceOracle", oracle.address);
    const tx = await iOracle['addNewTicker(address)'](token.address);
    await tx.wait();
    const tx2 = await iOracle.setPrice(symbol, basePrice);
    await tx2.wait();


    /*
      PriceOracle(_oracle).addNewTicker(ticker);
        PriceOracle(_oracle).updatePrice(symbol,basePrice);
    */



   /* const AKX = await deploy("AKXTokenLogic", {
        from: deployer,
        args: [symbol, feeLogic.address, token.address, oracle.address, basePrice],
        log: true,
        autoMine: true,
        waitConfirmations:2,
    });  

    const IDRegistry = await deploy("IdentityRegistry", {
        from: deployer,
        args: [],
        log: true,
        autoMine: true,
        waitConfirmations:2,
        //gasLimit: 20287350, gasPrice: "252873500"
    });

    const ProxyFactory = await deploy("AKXProxyFactory", {
        from: deployer,
        args: [],
        log: true,
        autoMine: true,
        waitConfirmations:2,
        //gasLimit: 20287350, gasPrice: "252873500"
    });
   
    const IProxy = await ethers.getContractAt("AKXProxyFactory", ProxyFactory.address);
    const proxy = await (await IProxy.createProxy(AKX.address, "")).wait();

    console.log(proxy.contractAddress);*/


 

}
func0.tags = ['setup'];
export default func0;