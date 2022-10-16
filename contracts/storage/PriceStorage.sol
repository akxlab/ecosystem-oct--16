// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract PriceStorage  {

    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableMap for EnumerableMap.UintToUintMap;
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    using Counters for Counters.Counter;

    EnumerableMap.UintToAddressMap private addressIndex;
    EnumerableMap.AddressToUintMap private priceIndex;

    Counters.Counter private _aIndex;


    function addAddress(address value) internal returns(uint256) {

        uint256 curr = _aIndex.current();
        _aIndex.increment();
        addressIndex.set(curr, value);
        return curr;

    }

    function getAddress(uint256 value) internal view returns(bool success, address item) {
        (success, item) = addressIndex.tryGet(value);
    }

    function addPrice(address addr, uint256 value) internal  {
        priceIndex.set(addr, value);
    }

    function getPrice(address addr) internal view returns(bool success, uint256 item)  {
          (success, item) = priceIndex.tryGet(addr);
    }
   

}