// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


abstract contract BaseStorage {

    struct uint256Values {
        mapping(uint256 => uint256) _values;
    }

    struct bytes32Values {
         mapping(uint256 => bytes32) _values;
    }

    struct addressValues {
        mapping(uint256 => address) _values;
    }

    struct StorageRecord {
       mapping(uint256 => bytes) _values;
    }
    function GetStorageSlot(bytes32 _implementationSlot) internal pure returns(StorageRecord storage s) { 

        bytes32 __IMPLEMENTATION_SLOT = _implementationSlot;

        assembly {
            s.slot := __IMPLEMENTATION_SLOT
        }

    }

}