// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../interfaces/Rewards.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Referrals is Rewards, Ownable {

    using SafeERC20 for IERC20;

    mapping(address => bool) public registeredReferrers;
    mapping(address => string) public referralCodes;
    mapping(string => address) public codesToReferrer;
    mapping(string => bool) private _codeExists;

    address private _referralLogic;
    ILogic private __logic;

    uint256 private _nonces;

    event NewReferrer(address indexed referrer, string code);


    constructor(address _token, address _rLogic) Rewards(_token) {
        setLogic(_rLogic);
        _nonces = 0;
    }

    modifier onlyRegistered() {
        require(registeredReferrers[msg.sender] == true, "not registered as a referrer");
        _;
    }

    modifier codeExists(string memory code) {
        require(_codeExists[code] == true, "invalid code");
        _;
    }

    function _calculateReward(uint256 amount, uint256 percentage) internal virtual override view returns (uint256) {
        return 0;
    }

    function canClaim() public virtual override view onlyRegistered returns (bool) {
        return true;
    }

    function canEarn() public virtual override view onlyRegistered returns (bool)  {
        return true;
    }

    function logic() internal virtual override {
        __logic = ILogic(_referralLogic);
    }

    function setLogic(address logicContract) public onlyOwner {
        _referralLogic = logicContract;
    }

    function claim() public virtual payable override {
        if (canClaim() != true) {
            revert("cannot claim");
        }
        RewardBeneficiary memory b = getBeneficiaryStorage(msg.sender);
        if(b._info.earned == b._info.claimed) {
            revert("nothing left to claim!");
        }
        int256 claimable = int256(b._info.earned) - int256(b._info.claimed);
        if(claimable <= 0) {
            revert("nothing to claim!");
        }
        IERC20(rewardToken).transfer(msg.sender, uint256(claimable));
        b._info.claimed += uint256(claimable);

    }

    function refer(string memory code, address referree, address referrer,uint256 amount) public codeExists(code) returns (bool) {

        Reward memory reward = setReward(code, referree, amount);
        /*
          struct DataRequest {
        address _sender;
        string code;
        address _referree;
        uint256 _amount;
    }
        */
        RewardBeneficiary memory b = getBeneficiaryStorage(referrer);
        RewardInfo memory ri = b._info;
        bytes memory _data = abi.encodePacked(referrer, code, referree, amount);
        require(__logic.execute(referrer, _data), "error executing logic");
        reward.pendingRewards += __logic.getResults(referrer);
        ri.earned = reward.pendingRewards;

        return true;

    }

    function setReward(string memory code, address referree, uint256 amount) internal returns (Reward memory reward) {

        reward = Reward(rewardToken, amount, 0, 0, 0);
    }

    function registerReferrer(address _referrer) public returns(string memory codeStr) {

        bytes memory code = abi.encodePacked(_referrer, _nonces);
        _nonces++;

        codeStr = Base64.encode(code);
        emit NewReferrer(_referrer, codeStr);

    }

    function getBeneficiaryStorage(address sender) internal returns(RewardBeneficiary memory  b) {
        return beneficiaries[sender];
    }


}