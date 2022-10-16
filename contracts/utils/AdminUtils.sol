// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "./IsSelf.sol";
import "./InitModifiers.sol";
import "../Roles.sol";

using AddressUpgradeable for address;

abstract contract AdminUtils is  IsSelf, InitModifiers, AKXRoles {

    mapping(address => bool) private _allowedAdmins;
    mapping(address => bool) private _blacklisted;


    mapping(address => bool) public pendingAdminRightsAcceptance;
    mapping(address => uint256) private _pendingQueueIds;
    mapping(uint256 => address) private _addrToQids;
    mapping(address => bool) public deniedAdmins;
    mapping(address => bool) public approvedAdmins;
    mapping(uint256 => bool) internal toDeny;
    mapping(uint256 => bool) internal toApprove;

    uint256 internal queueIndex;


    function authorizeAdmin(address _adminCandidate) public view notBlacklisted(_adminCandidate) onlySelf returns(bool authorized) {
        require(_allowedAdmins[_adminCandidate] == true, "unauthorized admin");
        authorized = true;
    }

    function __AdminUtils_init(address _sysAdmin) public onlyNotInitialized {

       
        _setupRole(SYSADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_HELPER_ROLE, msg.sender);
        _grantRole(SYSADMIN_ROLE, _sysAdmin);

        setInitialized();

    }

    function addSysAdminToPendingQueue(address _adminCandidate) public onlyAuthorized(msg.sender) notBlacklisted(_adminCandidate) notSuspectedContract(_adminCandidate) returns(bool success) {

        uint256 _qi = queueIndex;
        queueIndex++;
        require(pendingAdminRightsAcceptance[_adminCandidate] != true, "candidate already in queue");
        require(approvedAdmins[_adminCandidate] != true, "candidate already an admin");
        require(deniedAdmins[_adminCandidate] != true, "candidate already denied as admin");
        pendingAdminRightsAcceptance[_adminCandidate] = true;
        _pendingQueueIds[_adminCandidate] = _qi;
        _addrToQids[_qi] = _adminCandidate;
       
        success = true;


    }

    function ProcessAllQueueItems() public onlyAuthorized(msg.sender) {
        processAdminQueue();
    }

    function processAdminQueue() internal {
        uint256 j = 0;
          uint256 _qi = queueIndex;
        for(j = 0; j < _qi; j++) {
            address queueItem = _addrToQids[j];
            if(toDeny[_qi] == true) {
                deniedAdmins[queueItem] = true;
                 delete pendingAdminRightsAcceptance[queueItem];
            delete _pendingQueueIds[queueItem];
            delete _addrToQids[_qi];
            delete toDeny[_qi];
            }
            else if(toApprove[_qi] == true) {
            approvedAdmins[queueItem] = true;
            _allowedAdmins[queueItem] = true;
            delete pendingAdminRightsAcceptance[queueItem];
            delete _pendingQueueIds[queueItem];
            delete _addrToQids[_qi];
            delete toApprove[_qi];
            } else {
            revert("not in any pending states!");
            }
        }
    }

    function addToApprovePendingList( uint256 qid) internal {
        toApprove[qid] = true;
    }

       function addToDenyPendingList( uint256 qid) internal {
        toDeny[qid] = true;
    }

    modifier notSuspectedContract(address target) {
        if(target.isContract()) {
            revert("cannot use a contract suspected address");
        }
        _;
    }

    modifier notBlacklisted(address target) {
       if(_blacklisted[target] == true) {
        revert("blacklisted address not authorized");
       }
        _;
    }

    modifier onlyAuthorized(address target) {
        if(authorizeAdmin(target) != true) {
            revert("not authorized");
        }
        _;
    }

    receive() payable external {
        revert("cannot send to this contract");
    }

}