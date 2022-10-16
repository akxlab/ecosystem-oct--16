// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./ModuleRegistry.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "../Roles.sol";

abstract contract ModulesManager is ModuleRegistry, AKXRoles {

    mapping (uint256 => bool) private _enabledModules;
    mapping (uint256 => bool) private _installedModules;
    error moduleNotLoadedError();

    constructor() ModuleRegistry() {
        _setupRole(AKX_OPERATOR_ROLE, msg.sender);
        _grantRole(AKX_OPERATOR_ROLE, msg.sender);
    }

    function installModule(address _moduleAddress, string memory _modName) public onlyRole(AKX_OPERATOR_ROLE) {
        bytes32 _name = keccak256(abi.encodePacked(_modName));
        require(isInstalled(getModuleID(_name)) != true, "module already installed");
        _registerModule(_moduleAddress, _modName);
        _installedModules[getModuleID(_name)] = true;
    }


    function uninstallModule(address _moduleAddress, string memory _modName) public onlyRole(AKX_OPERATOR_ROLE) {
        bytes32 _name = keccak256(abi.encodePacked(_modName));
        require(isInstalled(getModuleID(_name)) == true, "module not installed");
        deregisterModule(_name);
        delete _enabledModules[getModuleID(_name)];
        delete _installedModules[getModuleID(_name)];
    }

    function isInstalled(uint256 modId) internal returns(bool) {
        return _enabledModules[modId] == true;
    }

    function loadModule(bytes32 modName) public onlyRole(AKX_OPERATOR_ROLE) returns(Module memory _module) {
        bytes32 _name = keccak256(abi.encodePacked(modName));
        if(isInstalled(getModuleID(_name)) != true) {
            revert moduleNotLoadedError();
        }
         _module = getModule(modName);
    }

    function moduleVersion(bytes32 modName) external returns(string memory) {

        return getModule(modName).version;
    }

    





}