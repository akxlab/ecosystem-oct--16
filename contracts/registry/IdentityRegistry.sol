// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {ISignatureValidator} from "../Logic/SignMessage.sol";
import {AKXRoles, Identity} from "./Identity.sol";

contract IdentityRegistry is ISignatureValidator, AKXRoles {
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;
    bytes4 internal constant FAILURE = 0xffffffff;

    using EnumerableSet for EnumerableSet.AddressSet;

    event IdentityRegistered(address indexed _owner, address identity, bytes32 msgHash);
    event AssetRegistered(address indexed identity, address indexed asset);

    mapping(address => address) private _owners;
    mapping(address => address) private _identities;
     mapping(address => mapping(address => bool)) private ownedAssets;
     mapping(address => bool) private _exists;
  

    constructor() {}

    function identityOwner(address identity) public view returns (address) {
        return _owners[identity];
    }

    function createIdentity(address _from, string memory name) public returns(address) {
        if(_exists[_from]) {
            return _identities[_from];
        }
        Identity ident = new Identity();
       // ident.transferOwnership(_from);
        registerIdentity(address(ident));
        return address(ident);
    }

    function registerIdentity(address identity) internal {

        Identity _ident = Identity(identity);
      //  _ident.signMessage(abi.encodePacked("identity registered for", _ident.owner()));
      //  _owners[identity] = _ident.owner();
     //   bytes32 hash = _ident.getMessageHash(abi.encodePacked("identity registered for", _ident.owner()));
        _identities[_owners[identity]] = identity;
    //    _exists[_ident.owner()] = true;
       // emit IdentityRegistered(_ident.owner(), identity, hash);
    }

    function registerOwnedAsset(address asset_, address identity_) public onlyOwner {
        ownedAssets[identity_][asset_] = true;
        emit AssetRegistered(identity_, asset_);
    }

    function assetBelongsToIdent(address asset_, address identity_) public view returns(bool) {
        return ownedAssets[identity_][asset_] ==  true;
    }

    function getIdentity(address owner_) public view returns(address) {
        return _identities[owner_];
    }

    function isValidSignature(bytes memory _data, bytes memory _signature) public view override returns (bytes4) {
        // Caller should be an identity
        Identity _ident = Identity(payable(msg.sender));
        bytes32 messageHash = _ident.getMessageHash(_data);
        if (_signature.length == 0) {
            require(_ident.signedMessages(messageHash) != 0, "Hash not approved");
        } else {
            _ident.checkSignatures(messageHash, _data, _signature);
        }
        return EIP1271_MAGIC_VALUE;
    }

    

  
    /*function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        return interfaceID == MAGICVALUE;
    }*/
}
