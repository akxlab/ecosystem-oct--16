// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Pricing {

    uint256 internal mantissa;


    struct Price {
        uint currentValue;
        uint lastValue;
    }

    struct PricingStorage {
        mapping(uint256 => Price) _chainPrice;
    }

    bytes32 internal constant PRICING_STORAGE_ID = keccak256("akx.ecosystem.labz.pricing.storage");


    event PriceSet(uint256 priceForOne, uint256 chainId);
    event PriceUpdated(uint256 lastPrice, uint256 priceForOne, uint256 chainId);

    function pricingStorage() internal pure returns(PricingStorage storage ps) {
        bytes32 position = PRICING_STORAGE_ID;
        assembly {
            ps.slot := position
        }
    }

    function setPrice(uint priceForOne, uint256 chainId) internal {
        PricingStorage storage ps = pricingStorage();
        ps._chainPrice[chainId] = Price(priceForOne, 0);
        emit PriceSet(priceForOne, chainId);
    }

    function getPrice(uint256 chainId) internal view returns(uint) {
        PricingStorage storage ps = pricingStorage();
        uint256 p = ps._chainPrice[chainId].currentValue;
        return p;
    }

    function updatePrice(uint256 chainId, uint256 newPrice) internal {
        PricingStorage storage ps = pricingStorage();
        uint256 old = getPrice(chainId);
        ps._chainPrice[chainId] = Price(newPrice, old);
        emit PriceUpdated(old, newPrice, chainId);
    }




}