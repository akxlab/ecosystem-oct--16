// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IAuth {

    
    event Authenticating(address _owner);
    event Authenticated(address _owner, bool result, bytes data);
    event AddedToNoBanWLEvent(address _owner);

    function authenticate(address _udsr) external returns(bool);
 


}