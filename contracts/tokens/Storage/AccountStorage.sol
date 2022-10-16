// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract AccountStorage is Initializable, ContextUpgradeable, AccessControlEnumerableUpgradeable, UUPSUpgradeable {

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _accountIndex;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    struct Account {
        address owner;
        uint256 index;
        uint256 creationDate;
    }

    mapping(address => uint256) private _index;
    mapping(uint256 => uint256) private _tokenIdToIndex;
    mapping(uint256 => Account) private _data;
    mapping(uint256 => bytes32) private _sha;
    mapping(address => bool) private _hasAccount;
    mapping(uint256 => bool) private _tokenIdAssociated;

    event AccountStorageInitialized(address indexed target);




    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyRole(UPGRADER_ROLE)
    override
    {}

    function initialize() initializer public {
        __Context_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    function create(address owner_, uint256 tokenId_) public onlyRole(OPERATOR_ROLE) returns(bool) {
      return initNewAccountStorage(owner_, tokenId_);
    }

    function initNewAccountStorage(address owner_, uint256 tokenId_) internal noAccountOnly(owner_, tokenId_) returns (bool ok) {
        uint256 date = block.timestamp;
        uint256 i = _accountIndex.current();
        Account memory a = Account(owner_, i, date);
        bytes32 h = calculateAccountHash(a);
        require(save(i, a, tokenId_, h), "error while saving account");
        _hasAccount[owner_] = true;
        _tokenIdAssociated[tokenId_] = true;
        _accountIndex.increment();
        emit AccountStorageInitialized(owner_);
        ok = true;
    }

    function save(uint256 index_, Account memory a_, uint256 tokenId_, bytes32 h) internal returns (bool) {
        _index[a_.owner] = index_;
        _tokenIdToIndex[tokenId_] = index_;
        _data[index_] = a_;
        _sha[index_] = h;
        return true;
    }

    function calculateAccountHash(Account memory a_) internal returns (bytes32 shaKeccak) {
        bytes memory acctBytes = abi.encode(a_);
        shaKeccak = sha256(acctBytes);
    }

    modifier noAccountOnly(address target, uint256 tokenId_) {
        require(_hasAccount[target] != true && _tokenIdAssociated[tokenId_] != true, "already have an account");
        _;
    }

    modifier hasAccountOnly(address target, uint256 tokenId_) {
        require(_hasAccount[target] == true && _tokenIdAssociated[tokenId_] == true, "no account exists");
        _;
    }

    function updateOperator(address _newOperator) public onlyRole(OPERATOR_ROLE) {
        _grantRole(OPERATOR_ROLE, _newOperator);
        _revokeRole(OPERATOR_ROLE, _msgSender());
    }

    function dataByAddress(address target) internal view virtual returns (Account memory a) {
        uint256 _index = _index[target];
        a = dataByIndex(_index);
    }

    function dataByTokenId(uint256 tokenId_) internal view virtual returns (Account memory a) {
        uint256 _index = _tokenIdToIndex[tokenId_];
        a = dataByIndex(_index);
    }

    function dataByIndex(uint256 _index) internal view virtual returns (Account memory a) {
        a = _data[_index];
    }

    function data(address owner_, uint256 tokenId_) public hasAccountOnly(owner_, tokenId_) virtual returns (Account memory a) {
        Account memory a1 = dataByAddress(owner_);

            Account memory a2 = dataByTokenId(tokenId_);
            require(dataIntegrityCheck(a1, a2), "data failed integrity check.");
            delete a2;
        a = a1;
    }

    function data(address owner_) public view virtual returns(Account memory a1) {
        require(_hasAccount[owner_] == true, "no account exists");
       a1 = dataByAddress(owner_);
    }

    function data(uint256 tokenId_) public view virtual returns(Account memory a1) {
        require(_tokenIdAssociated[tokenId_] == true, "no account exists");
        a1  = dataByTokenId(tokenId_);
    }
    function dataIntegrityCheck(Account memory a1, Account memory a2) internal returns (bool ok) {
        bytes32 h1 = calculateAccountHash(a1);
        bytes32 h2 = calculateAccountHash(a2);
        ok = h1 == h2;
    }


}