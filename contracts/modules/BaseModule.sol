// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


import "../interfaces/IModule.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

abstract contract BaseModule is IModule, Initializable {

    string private _moduleType;
    bytes32 public _moduleName;
    string public _moduleVersion;
    address public _moduleContract;
    bytes32 public _moduleAuthor;
    bool public _loaded;

    function __init_module() internal virtual;

    function moduleType() external view returns(string memory) {
        return _moduleType;
    }
    function moduleName() external view returns(bytes32) {
        return _moduleName;
    }
    function moduleVersion() external view returns(string memory) {
        return _moduleVersion;
    }
    function moduleAuthor() external view returns(bytes32) {
        return _moduleAuthor;
    }
    function moduleHash() external view returns(bytes32) {
        return keccak256(abi.encodePacked(_moduleName, _moduleVersion));
    }
    function moduleContract() external view returns(address) {
        return _moduleContract;
    }
    function compareVersions(string memory v1, string memory v2) external pure returns(bool) {
        return keccak256(abi.encodePacked(v1)) == keccak256(abi.encodePacked(v2));
    }

    function _load() internal virtual;

    function _unload() internal virtual;


}