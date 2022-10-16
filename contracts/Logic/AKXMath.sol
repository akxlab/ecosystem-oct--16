// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


import "hardhat/console.sol";

abstract contract AKXMath  {


   
    uint256 public MaxFounderPercent;
    uint256 public Reserve;
    uint256 public PreSalePercent;
    uint256 public Operations;
    uint256 public maxCirculating;
    uint256 public mantissa ;
    uint256 public txFee;
    uint256 public rewardRate;

    function init() internal {
        MaxFounderPercent = 4000;
        Reserve = 10000;
        PreSalePercent = 2000;
        Operations = 23000;
        maxCirculating = 46000;
        mantissa = 1e5;
        txFee = 1500;
        rewardRate = 18000;
    }

    function getPercentForFounder(uint256 supply) public view returns(uint256) {
        return supply * MaxFounderPercent / mantissa;
    }

    function getReserveAmount(uint256 supply) public view returns(uint256) {
        return supply * Reserve / mantissa;
    }
 
    function getPresaleSupply(uint256 supply) public view returns(uint256) {
         return supply * PreSalePercent / mantissa;
    }

    function getOperationAmount(uint256 supply) public view returns(uint256) {
        return supply * Operations / mantissa;
    }

    function getMaxCirculating(uint256 supply) public view returns(uint256) {
        return supply * maxCirculating / mantissa;
    }

    function getTxFee(uint256 amount) public view returns(uint256) {
        return amount * txFee / mantissa;
    }

    function getRewardRate(uint256 amount) public view returns(uint256) {
        return (amount * rewardRate / mantissa) / 365;
    }


    function getRatePercent(uint256 amount1, uint256 amount2) public pure returns(uint256) {
        if(amount1 > amount2) {
            return amount1 * 100 / amount2;
        }
        return amount2 * 100 / amount1;
    }


}