// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


import "./ModuleStorage.sol";
import "../utils/BytesUtils.sol";

abstract contract ModuleRegistry is ModuleStorage, BytesUtils {
    mapping(bytes32 => uint256) private _moduleByName;
    mapping(address => uint256) private _moduleByAddress;
    mapping(uint256 => bytes32) private _moduleResolver;
    mapping(bytes32 => uint256) private _rModuleResolver;
    mapping(address => bool) private _registeredAddress;
    mapping(bytes32 => bool) private _registeredName;

    constructor() {}

    function _registerModule(address _module, string memory _sName) internal {
        bytes32 _name = keccak256(abi.encodePacked(_sName));
        require(
            this.isRegisteredModuleAddress(_module) != true,
            "address already registered"
        );
        require(
            this.isRegisteredModuleName(_name) != true,
            "name already registered"
        );


        uint256 _id = _setModule(_module, _name);
        _moduleByName[_name] = _id;
        _moduleResolver[_id] = _name;
        _rModuleResolver[_name] = _id;
        _moduleByAddress[_module] = _id;
        _registeredAddress[_module] = true;
        _registeredName[_name] = true;
        emit ModuleRegistered(_module, _name);
    }

    function _setModule(address _module, bytes32 _name) internal returns(uint256) {
        /*
    struct Module {
        bytes32 name;
        string version;
        string author;
        address contractAddr;
        bytes32 mHash;
    }
    */
       


        string memory ver = IModule(_module).moduleVersion();
        bytes32 author = IModule(_module).moduleAuthor();

        bytes32 mHash = keccak256(abi.encodePacked(_name, ver, author));

        uint256 __id = _store(_module, _name, ver, author, mHash);
        return __id;
    }

    function deregisterModule(bytes32 _name) internal {
        Module memory _module = getModule(_name);
        delete _moduleByName[_name];

        delete _moduleByAddress[_module.contractAddr];
        delete _registeredAddress[_module.contractAddr];
        delete _registeredName[_name];
        delete _moduleByName[_name];

        emit ModuleDeRegistered(_module.contractAddr);
    }

    function getModuleID(bytes32 _modName) internal view returns(uint256) {
        return _moduleByName[_modName];
    }

    function getModuleID(address _modAddress) internal view returns(uint256) {
        return _moduleByAddress[_modAddress];
    }

    function moduleName(address _module)
        external
        view
      override
      
        returns (uint256)
    {
        return _moduleByAddress[_module];
    }


    function isRegisteredModuleAddress(address _module)
        external
        view
        returns (bool)
    {
        return _registeredAddress[_module] == true;
    }

    function isRegisteredModuleName(bytes32 _name)
        external
        view
        returns (bool)
    {
        return _registeredName[_name] == true;
    }

    function getModule(bytes32 _name) public returns(Module memory) {
        uint256 _id = _moduleByName[_name];
        return _retrieveModule(_id);
    }
}
