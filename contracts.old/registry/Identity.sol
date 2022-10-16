// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Roles.sol";

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import {SignMessageLogic} from "../Logic/SignMessage.sol";
interface IIdentity {

    function getData(bytes32 key) external returns(string memory value);
    function setData(bytes32 key, string memory value) external returns(bool success);


}

abstract contract IdentitySigner is IIdentity,  SignMessageLogic {

}

contract Identity is Initializable, IdentitySigner, EIP712Upgradeable, AKXRoles {

    // keccak256("Identity(address)")
    bytes32 private constant IDENTITY_TYPE_HASH = 0x5539daaa46b59a520a05bd9b6beef0b7e376dd7dedd3073653e7a68f34a22737;
    uint private nonce;
    bytes32 private constant AKX_MSG_TYPEHASH= 0xef3da448ef037ebfba3b01faf85e69692b03cfc21278b48c6f12f50fae34c548;

    mapping(bytes32 => string) private _kvStore;
    mapping(string => bytes32) private _strToKey;
    mapping(bytes32 => bool) private _keyExists;
    string private avatar;
    string private customName;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
   

    function initialize(string memory name, string memory version)  public initializer {
        __Identity_init(name, version);
        __SigMessageLogic_init(_domainSeparatorV4());
    }

    function __Identity_init(string memory name, string memory version) public onlyInitializing {
        __EIP712_init(name, version);
    }

    function getCustomName() public view returns(string memory) {
        return customName;
    }

    function setCustomName(string memory _customName) public onlyOwner  {
        customName = _customName;
    }

    function getAvatar() public view returns(string memory) {
        return avatar;
    }

    function setAvatar(string memory avatarUri) public onlyOwner {
        avatar = avatarUri;
    }

    function getData(bytes32 key) public override view returns(string memory value) {
        checkDataNotExists(key);
        return _kvStore[key];
    }
    function setData(bytes32 key, string memory value) public  override onlyOwner returns(bool success) {
        checkDataExists(key);
        Identity(address(this)).signMessage(abi.encodePacked(key, value));
        success = true;
    }

    function checkDataNotExists(bytes32 key) internal view {
        require(_keyExists[key] == true, "invalid data key");
    }

    function checkDataExists(bytes32 key) internal view {
        require(_keyExists[key] != true, "invalid data key");
    }

    function getDomainSeparator() public view returns(bytes32) {
        return _domainSeparatorV4();
    }

 function getMessageHash(bytes memory message) public view returns (bytes32) {
        bytes32 akxMessageHash = keccak256(abi.encode(AKX_MSG_TYPEHASH, keccak256(message)));
        return
            keccak256(abi.encodePacked(bytes1(0x19), bytes1(0x01), Identity(payable(address(this))).domainSeparator, akxMessageHash));
    }

function checkSignatures(
        bytes32 dataHash,
        bytes memory data,
        bytes memory signatures
    ) public view {
      
        checkNSignatures(dataHash, data, signatures, 1);
    }


}