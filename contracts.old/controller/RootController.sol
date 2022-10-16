// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./BaseController.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract RootController is BaseController {

   // using Address for address;

    constructor(address impl_) BaseController(impl_) {}

    function _beforeRequest(Request memory req) internal virtual  {}
     function _beforeRequest() internal virtual override {}

    
    function execute(address _contract, string memory func, Request memory req) public payable override onlyAllowedController {

        (bool success, bytes memory data) = _contract.delegatecall(abi.encodeWithSignature(func, req.params));

    }

    function setResponse(bytes memory data) internal {
        /*
        struct Response {
        uint requestId;
        address from;
        address to;
        bytes response;
        bool error;
        string msg;
    }
        */
    }



}