// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./BaseResolver.sol";

abstract contract ProfileResolver is BaseResolver {

   bytes4 constant public PROFILE_INTERFACE_ID = 0x72cd2b1a;

   mapping(uint256 => bytes32) private _profiles;
    mapping(uint256 => bool) private _profileExists;

    function profile(uint256 tokenId) public view returns(bytes32) {
        return _profiles[tokenId];
    }

    function setProfileID(uint256 tokenId) internal returns(bytes32) {
        require(_profileExists[tokenId] != true, "profile already exists");
        bytes32 id = _profiles[tokenId] = keccak256(abi.encodePacked(tokenId, PROFILE_INTERFACE_ID));
        return id;
    }




}