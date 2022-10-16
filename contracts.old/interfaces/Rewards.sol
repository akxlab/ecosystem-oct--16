// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../utils/InitModifiers.sol";
import "../interfaces/ILogic.sol";

abstract contract Rewards is InitModifiers {

    enum RewardTypes {
        REFERRAL,
        STAKING,
        OTHER
    }

    struct Reward {
        address token;
        uint256 amount;
        uint256 pendingRewards;
        uint256 recoverableAmt;
        uint256 claimed;
    }

    struct RewardInfo {
        RewardTypes _type;
        uint256 consolidatedPerUnit;
        uint256 earned;
        uint256 claimed;
    }

    struct RewardBeneficiary {
        uint256 consolidatedEarnings;
        address beneficiary;
        RewardInfo _info;
    }

    mapping(address => RewardBeneficiary) public beneficiaries;

    address public rewardToken;

    constructor(address rewardToken_) {
        rewardToken = rewardToken_;
    }

    function _calculateReward(uint256 amount, uint256 percentage) internal virtual view returns(uint256);

    function canClaim() public virtual view returns(bool);

    function canEarn() public virtual view returns(bool);

    function logic() internal virtual;

    function claim() external virtual payable {}

    function earned() public virtual view returns(uint256) {
      return beneficiaries[msg.sender]._info.earned;
    }

    function claimed() public virtual view returns(uint256) {
        return beneficiaries[msg.sender]._info.claimed;
    }









}