// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interfaces/IModule.sol";
import "../interfaces/IModuleRegistry.sol";



abstract contract ModuleStorage is IModule, IModuleRegistry {


    struct Len {
    uint256 _value;
}

    function _moduleStorage() internal returns (Module[] storage _ms) {

        bytes32 position = keccak256('akx3.ecosystem.modules.storage');
        assembly {
            _ms.slot := position

        }
    }

    function _length() internal view returns(Len storage len) {
bytes32 position = keccak256('akx3.ecosystem.modules.storage.len');

    assembly {
    len.slot := position
    }
}

    function _incrementLength() internal {
        Len storage length = _length();
        length._value = length._value + 1;
    }

    function _store(address addr, bytes32 _bName, string memory __ver, bytes32 _author, bytes32 _mHash) internal returns(uint256 __id) {
        /*
            struct Module {
                bytes32 name;
                string version;
                bytes32 author;
                address contractAddr;
                bytes32 mHash;
            }
        */
        Len storage length = _length();
        if(length._value == 0) {
            length._value = 1;
        }
        Module[] storage ms = _moduleStorage();
        uint256 __id = length._value;
        ms[__id].name = _bName;
        ms[__id].version = __ver;
        ms[__id].author = _author;
        ms[__id].contractAddr = addr;
        ms[__id].mHash = _mHash;
        _incrementLength();
        return __id;

    }

    function _retrieveModule(uint256 _id) internal returns (Module memory) {
        Len storage length = _length();
        if(length._value < _id) {
            revert("invalid module id");
        }
        Module[] storage ms = _moduleStorage();
        return ms[_id];
    }

}