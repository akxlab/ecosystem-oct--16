// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/utils/StorageSlot.sol";
abstract contract BaseController {


    address private _allowedController;

    struct Request {
        address sender;
        address to;
        bytes4 func;
        bytes params;
    }

    struct Response {
        uint requestId;
        address from;
        address to;
        bytes response;
        bool error;
        string msg;
    }

    function setImplementation(address _impl) internal virtual {
        bytes32 STORAGE_SLOT = keccak256("akx3.ecosystem.controller.implementation");
        StorageSlot.getAddressSlot(STORAGE_SLOT).value = _impl;
    }

    function getImplementation() internal virtual returns(address) {
        bytes32 STORAGE_SLOT = keccak256("akx3.ecosystem.controller.implementation");
        return StorageSlot.getAddressSlot(STORAGE_SLOT).value;
    }

    function _beforeRequest() internal virtual;

     function execute(address _contract, string memory func, Request memory req) public payable virtual;

    function setRequest(bytes memory data) internal virtual returns(Request memory req) {
        req = abi.decode(data, (Request));
    }

    constructor(address _impl) {
        setImplementation(_impl);
        _allowedController = address(this);
    }

    modifier onlyAllowedController() {
        require(msg.sender == _allowedController, "not allowed");
        _;
    }




}