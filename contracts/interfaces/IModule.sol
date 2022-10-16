// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


interface IModule {
    event ModuleAdded(bytes32 _name);
    event ModuleRemoved(bytes32 _name);

    function moduleName(address modAddress) external view returns(uint256);
    function moduleVersion() external view returns(string memory);
    function moduleAuthor() external view returns(bytes32);
    function moduleHash() external view returns(bytes32);
    function moduleContract() external view returns(address);

}