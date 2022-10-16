// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../resolvers/AllResolvers.sol";
import "./UDS.sol";
import "../../registry/BaseUserRegistry.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../../Roles.sol";

contract UserDataServiceResolver is AllResolvers,BaseUserRegistry, ReentrancyGuard, AKXRoles {


    /**
 * A mapping of authorisations. An address that is authorised for a profile name
 * may make any changes to the name that the _owner could, but may not update
 * the set of authorisations.
 * (node,  _owner, caller) => isAuthorised
 */
    mapping(bytes32 => mapping(address => mapping(address => bool))) public authorisations;
    bytes4 private constant INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));

    event AuthorisationChanged(bytes32 indexed profileId, address indexed  _owner, address indexed target, bool isAuthorised);
    event NewAccountCreated(bytes32 identity, address indexed  _owner, uint256 tokenId);
    event Log(string message);
    event AlreadyRegisteredEvent(bytes32 identity, uint256 tokenId, bytes32 metasId);

    mapping(address => bool) private alreadyReg;
    mapping(address => uint256) private tokenId;

    mapping(address => AccountInfo) private _info;

    using Counters for Counters.Counter;

   Counters.Counter internal _tokenIndex;

    struct AccountInfo {
        uint256 tokenId;
        bytes32 identity;
        address owner;
        bytes32 metasId;
        uint256 timestamp;
    }

    constructor(bytes32 rootNode, address _uds) BaseUserRegistry(rootNode, _uds){
        _setupRole( DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(AKX_OPERATOR_ROLE, msg.sender);
        _grantRole(AKX_OPERATOR_ROLE, msg.sender);
    }


    function setAuthorisation(bytes32 profileId, address target, bool _isAuthorised) public onlyRole(AKX_OPERATOR_ROLE) {
        authorisations[profileId][msg.sender][target] = _isAuthorised;
        emit AuthorisationChanged(profileId, msg.sender, target, _isAuthorised);
    }

    function isAuthorised(bytes32 profileId) internal view returns (bool) {
        address _owner = uds.owner(profileId);
        return _owner == msg.sender || authorisations[profileId][_owner][msg.sender];
    }


    function multicall(bytes[] calldata data) internal returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success);
            results[i] = result;
        }
        return results;
    }

    function createNewAccount(address _accountWalletAddress, string memory accountName) public  returns(uint256)  {
        if(alreadyRegistered(_accountWalletAddress)) {
            AccountInfo memory __info = getAccountInfo(_accountWalletAddress);
            emit AlreadyRegisteredEvent(__info.identity, __info.tokenId, __info.metasId);
            return 0;
        }
        require(_createNewAccount(_accountWalletAddress), "error registering new account");
        uint256 _tid = _tokenIndex.current();
        setOptionalName(_accountWalletAddress, _tid, accountName);
        _tokenIndex.increment();
        return _tid;

    }

    /*function createNewAccount(address _accountWalletAddress)  public onlyRole(AKX_OPERATOR_ROLE) {
        emit Log("create new account requested");
        require(_createNewAccount(_accountWalletAddress), "error registering new account");
_tokenIndex.increment();
    }*/

    function _createNewAccount(address accountOwner) internal returns (bool) {

        super._register(_tokenIndex.current(), accountOwner);
        emit Log("super._register is successful... requesting ident");
        bytes32 _ident = sha256(abi.encodePacked(_tokenIndex.current(), accountOwner));
        super.setIdent(_tokenIndex.current(), _ident);

        //bytes32 metasId = setNewMetaDatas(_tokenIndex.current(), accountOwner);
        //AccountInfo memory Info = setAccountInfoRecord(_tokenIndex.current(), _ident, accountOwner, metasId);
        emit NewAccountCreated(_ident, accountOwner, _tokenIndex.current());

        return true;
    }

    function setAccountInfoRecord(uint256 __tokenId,
        bytes32 identity,
        address  _owner,
        bytes32 metasId) internal returns (AccountInfo memory){
        AccountInfo memory Info = AccountInfo(__tokenId, identity,  _owner, metasId, block.timestamp);
        _info[_owner] = Info;
        return Info;
    }

    function getAccountInfo(address infoOwner) public view returns(AccountInfo memory Info) {
        Info = _info[infoOwner];
    }

    function alreadyRegistered(address _subject) public view returns(bool) {
        return alreadyReg[_subject] == true;
    }


    function supportsInterface(bytes4 interfaceID)
    public
    view
    override(ERC721, AllResolvers, AccessControlEnumerable)
    returns (bool)
    {

        return super.supportsInterface(interfaceID);
    }


}