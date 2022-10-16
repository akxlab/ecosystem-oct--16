// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./BaseResolver.sol";

abstract contract NameResolver is BaseResolver {
   
   bytes4 constant public NAME_INTERFACE_ID = 0x00ad800c;

   mapping(uint256 => string) private _names; // external user identifier
    mapping(address => string) private addressToNames;
    mapping(string => address) private nameToAddress;
   
    function getName(uint256 tokenId) external view returns (string memory) {
        return _names[tokenId];
    }

    function getName(address _owner) external view returns (string memory) {
        return addressToNames[_owner];
    }

    function getName() external view returns (string memory) {
        return addressToNames[msg.sender];
    }

    function nameOwner(string memory _name) external view returns (address) {
        return nameToAddress[_name];
    }


    function setOptionalName(address owner, uint256 tokenId, string memory accountName) internal {
        _names[tokenId] = accountName;
        addressToNames[owner] = accountName;
        nameToAddress[accountName] = owner;
    }

}