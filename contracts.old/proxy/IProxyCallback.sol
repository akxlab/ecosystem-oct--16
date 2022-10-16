// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./AKXProxy.sol";

interface IProxyCreationCallback {
    function proxyCreated(
        AKXProxy proxy,
        address _singleton,
        bytes calldata initializer,
        uint256 saltNonce
    ) external;
}