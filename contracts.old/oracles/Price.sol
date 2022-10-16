// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../storage/PriceStorage.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPriceOracle {
    struct tickerRecord {
        string symbol;
        uint256 chainId;
        uint8 decimals;
        address ticker;
        uint256 lastUpdated;
        uint256 basePrice;
        string basePriceSymbol;
    }

    struct PairRecord {
        string symbol;
        uint256 chainId;
        address pair1;
        address pair2;
        uint256 conversionRate; // how many pair2 for one pair1
        uint256 reverseConversion;
        uint256 lastUpdated;
    }

   function lastUpdate(string memory symbol)
        external
        returns (uint256, uint256, uint8);


    event PriceUpdate(address indexed ticker, uint256 oldPrice, uint256 newPrice, string basePriceSymbol, uint256 timestamp);

}

contract PriceOracle is IPriceOracle, PriceStorage, Ownable {
    mapping(string => address) private _currencyAddresses;
    mapping(string => uint256) private _basePrice;
    mapping(string => uint256) private _lastUpdate;

    constructor() {}

    function addNewTicker(address ticker)
        external
        returns (bool success)
    {
        uint256 aIndex = addAddress(ticker);
        string memory __name = ERC20(ticker).symbol();
        _basePrice[__name] = aIndex;
        _currencyAddresses[__name] = ticker;
        success = true;
    }

       function addNewTicker(string memory ticker)
        external
        returns (bool success)
    {
        uint256 aIndex = addAddress(address(uint160(bytes20(abi.encodePacked(ticker)))));
        string memory __name = ticker;
        _basePrice[__name] = aIndex;
        _currencyAddresses[__name] = address(uint160(bytes20(abi.encodePacked(ticker))));
        success = true;
    }



    function updatePrice(string memory ticker, uint256 price)
        external
        onlyOwner
    {
        (bool success, address aTicker) = getAddress(_basePrice[ticker]);
        require(success, "error updating price");
        uint256 _oldprice;
        (success, _oldprice) = getPrice(aTicker);
        require(success, "error getting old price while updating");
        addPrice(aTicker, price);
        _lastUpdate[ticker] = block.timestamp;
        emit PriceUpdate(aTicker, _oldprice, price, ticker, _lastUpdate[ticker]);
    }

    function setPrice(string memory ticker, uint256 price) external onlyOwner {
         (bool success, address aTicker) = getAddress(_basePrice[ticker]);
       
        uint256 _oldprice = 0;
       
        addPrice(aTicker, price);
        _lastUpdate[ticker] = block.timestamp;
        emit PriceUpdate(aTicker, _oldprice, price, ticker, _lastUpdate[ticker]);
    }

    function lastUpdate(string memory symbol)
        external view
        returns (uint256 price, uint256 timestamp, uint8 decimals)
    {
         (bool success, address aTicker) = getAddress(_basePrice[symbol]);
         require(success, "error getting price");
          (success, price) = getPrice(aTicker);
           require(success, "error getting price");
          timestamp = _lastUpdate[symbol];
          decimals = ERC20(aTicker).decimals();
    }

   
}