// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IUserRegistry {

event UserCreated(address indexed user, bytes32 id);
event UserDeleted(address indexed user, bytes32 id);
event UserSuspended(address indexed user, bytes32 id);

struct User {
    address user;
    bytes32 id;
    bool active;
    bytes32 sha;
    uint timestamp;
}



function registerUser() external;

function deRegisterUser() external;

function suspendUser(address user, bytes32 id) external;

function recoverUser() external;

function verifyUser() external;

function resolve() external;

}