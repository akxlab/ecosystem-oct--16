// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IModuleRegistry {

    event ModuleRegistered(address _module, bytes32 _name);
    event ModuleDeRegistered(address _module);


    function isRegisteredModuleAddress(address _module) external view returns (bool);
        function isRegisteredModuleName(bytes32 _name) external view returns (bool);

    struct Module {
        bytes32 name;
        string version;
        bytes32 author;
        address contractAddr;
        bytes32 mHash;
    }
}