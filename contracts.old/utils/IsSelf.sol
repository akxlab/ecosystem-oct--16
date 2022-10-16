// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


abstract contract IsSelf {

    function _isSelf(address _self) internal view returns (bool) {
        return _self == address(this);
    }

    modifier onlySelf() {
        require(msg.sender == address(this), "only self allowed");
        _;
    }

}