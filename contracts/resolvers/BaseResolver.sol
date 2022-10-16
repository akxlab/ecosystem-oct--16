// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "../utils/BytesUtils.sol";


abstract contract BaseResolver is ERC165, BytesUtils {

bytes4 private constant INTERFACE_META_ID = 0x01ffc9a7;



}