// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./BaseResolver.sol";

abstract contract IdentResolver is BaseResolver {
   
   bytes4 constant public IDENT_INTERFACE_ID = 0x0e2f9f10;

   mapping(uint256 => bytes32) private _idents; // external user identifier for ie database
    mapping(uint256 => bool) private _idExists;
   
    function ident(uint256 tokenId) external view returns (bytes32) {
        return _idents[tokenId];
    }

    function setIdent(uint256 tokenId, bytes32 identifier) public {
        require(_idExists[tokenId] != true, "ident already set");
        _idents[tokenId] = identifier;
    }


}