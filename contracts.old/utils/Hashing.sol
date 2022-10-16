// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


abstract contract Hashing {

    string private _secSalt;

    constructor() {
        _secSalt = "Pluto is a planet dare you say no and ill send you there.";
    }

    function _calculateHash(address _addr, uint blockNum) internal virtual returns(bytes32) {
    
           return sha256(abi.encodePacked(abi.encode(0x61), abi.encode(_addr), abi.encodePacked(blockNum), abi.encodePacked(_secSalt)));
    }

}