// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./BaseResolver.sol";

abstract contract MetaDataResolver is BaseResolver {

   bytes4 constant public METADATA_INTERFACE_ID = 0xe3684e39;
   bytes4 constant public METAVALUE_INTERFACE_ID = 0x4dc34682;
   bytes4 constant public SETMETA_INTERFACE_ID = 0x08730f07;


   mapping(uint256 => bytes32) private _metadataIds;
   mapping(bytes32 => bool) private _idExists;
   mapping(bytes32 => mapping(string => bool)) private _keysAvailable;
   mapping(string => bytes32) private _keyNames;
   mapping(string => bool) private _keyExists;
   mapping(bytes32 => mapping(bytes32 => bytes)) private _keyValMetas;
   mapping(uint256 => address) private _metaOwners;
   
    enum DataTypes {
        PROFILE_STRING,
        IMAGE,
        HASH,
        SELECTION,
        URI,
        WALLET,
        NO_RENDER
    }

   struct KeyValMeta {
    bytes32 key;
    DataTypes dType;
    bytes dValue;
    bool editable;
    bool encrypted;
   }

   event MetaDataAdded(uint256 tokenid, bytes32 metaid, bytes32 keyid);


function metadata(uint256 tokenId) external view returns(bytes32) {
    return _metadataIds[tokenId];
}

function getMetaValue(bytes32 keyId, bytes32 id) internal view returns(bytes memory) {
    return _keyValMetas[keyId][id];
}

function metaValue(uint256 tokenId, string memory keyStr) external view returns(KeyValMeta memory kv) {
    bytes32 id = this.metadata(tokenId);
    bytes memory bVals = getMetaValue(metaKey(id, keyStr), id);
    kv = abi.decode(bVals, (KeyValMeta));
}

function metaKey(bytes32 metaId, string memory keyStr) internal view returns(bytes32) {
    if(!isKeyAvailable(metaId, keyStr)) {
        revert("invalid key requested");
    }
    return _keyNames[keyStr];
}

function isKeyAvailable(bytes32 metaId, string memory keyStr) internal view returns(bool) {
    return _keysAvailable[metaId][keyStr] == true;
}

function setMetaData(address _for, uint256 tokenId, string memory keyStr, uint _dtype, bytes memory value, bool editable, bool encrypted) public {
    require(_for == _metaOwners[tokenId], "only owner can set metas");
    bytes32 id = _metadataIds[tokenId];
    if(_keyExists[keyStr] != true) {
        _keyExists[keyStr] = true;
        _keyNames[keyStr] = keccak256(abi.encodePacked(keyStr));
    }
    bytes32 keyId = _keyNames[keyStr];
    KeyValMeta memory kv = KeyValMeta(keyId, DataTypes(_dtype), abi.encode(value), editable, encrypted);
    _keyValMetas[id][keyId] = abi.encode(kv);
    emit MetaDataAdded(tokenId, id, keyId);
}

    function setNewMetaDatas(uint256 tokenId, address tOwner) public  returns(bytes32) {
        _metaOwners[tokenId] = tOwner;
        bytes32 id = keccak256(abi.encode(tokenId));
        if(_idExists[id] != true) {
            _idExists[id] = true;
            _metadataIds[tokenId] = id;
        }
        return id;
    }



}