// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IUserRecord {

    event NewUserRecordAdded(address indexed owner, address indexed resolver, bytes32 id);
  

    struct Record {
        bytes32 recordId;
        address owner;
        address resolver;
    }

    function setOwner(address owner) external;
    function setResolver(address resolver) external;
    function addRecord() external returns(bytes32);
    function count() external returns(uint256);
    function getRecord(bytes32 recordId) external returns(Record memory);


}