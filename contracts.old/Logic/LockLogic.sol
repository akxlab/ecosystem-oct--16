// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LockLogic is Ownable, ReentrancyGuard {


    using SafeERC20 for ERC20;

    ERC20 private _token;

    constructor(address _lockedToken) {
        _token = ERC20(_lockedToken);
    }

 uint256 public lockDuration;
    mapping(address => uint256) internal _lastBuyTime;
    mapping(address => bool) internal _vipHolders;
    mapping(address => bool) internal _isUnlocked;
    mapping(address => uint256) public lockedBalance;
    mapping(address => uint256) public unlockedBalance;
    bool public canSell;


       function verifySellPermissions(address _sender, uint256 amount)
        internal
        returns (bool)
    {
        // @notice vip holders funds are locked for 90 days from the time of the last buy they made as stated in the whitepaper
        // @notice this only affects purchase made during the vip sale
        if (
            _vipHolders[_sender] == true &&
            canSell == true &&
            _lastBuyTime[_sender] + lockDuration > block.timestamp + 25 seconds
        ) {
            lockedBalance[_sender] = 0;
            _isUnlocked[_sender] = true;
            return true;
        } else if (!isHavingAvailableBalance(_sender)) {
            return false;
        } else if (amount > availableBalance(_sender)) {
            return false;
        } else if (_isUnlocked[_sender] == true) {
            return true;
        } else {
            return canSell;
        }
    }

    function availableBalance(address _sender) public view returns (uint256) {
        uint256 _locked = lockedBalance[_sender];
        uint256 bal = _token.balanceOf(_sender);
        return bal - _locked;
    }

    function isHavingAvailableBalance(address _sender)
        public
        view
        returns (bool)
    {
        return availableBalance(_sender) > 0;
    }

    function lockTokens(address _sender, uint256 amount) public onlyOwner {
        lockedBalance[_sender] = amount;
        _lastBuyTime[_sender] = block.timestamp;
    }

    function unlockTokensFor(address _sender, uint256 _amount) public onlyOwner {
        require(verifySellPermissions(_sender, _amount) == true, "cannot unlock tokens");
        lockedBalance[_sender] -= _amount;
        unlockedBalance[_sender] += _amount;
    }

    function withdrawUnlockedTokens(address _sender) external payable nonReentrant {
        require(unlockedBalance[_sender] > 0, "no unlocked balance available");
        _token.safeTransfer(_sender, unlockedBalance[_sender]);
    }
} 
 
