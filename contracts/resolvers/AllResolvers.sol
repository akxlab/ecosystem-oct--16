// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./IdentResolver.sol";
import "./NameResolver.sol";
import "./ProfileResolver.sol";
import "./MetaDataResolver.sol";
import "./RoutesResolver.sol";

bytes32 constant IDENT_RESOLVER = keccak256(abi.encodePacked("IDENT_RESOLVER"));
bytes32 constant NAME_RESOLVER = keccak256(abi.encodePacked("NAME_RESOLVER"));
bytes32 constant PROFILE_RESOLVER = keccak256(abi.encodePacked("PROFILE_RESOLVER"));
bytes32 constant ROUTES_RESOLVER = keccak256(abi.encodePacked("ROUTES_RESOLVER"));
bytes32 constant METADATA_RESOLVER = keccak256(abi.encodePacked("METADATA_RESOLVER"));

abstract contract AllResolvers is IdentResolver, NameResolver, ProfileResolver, MetaDataResolver {
  function supportsInterface(bytes4 interfaceID) virtual override public view returns(bool) {
        return super.supportsInterface(interfaceID);
    }
}