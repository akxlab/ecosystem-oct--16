import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {ethers, upgrades} from 'hardhat';

const {utils} = require("ethers");


const identity: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
}

identity.tags = ['identity'];
export default identity;