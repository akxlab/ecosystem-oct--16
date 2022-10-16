// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../oracles/Price.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";


abstract contract LiquidityLogic  {

    using SafeMath for uint256;
    using SafeCast for uint;

    address public priceOracle;

    string public symbol;
    address public ticker;
    uint256 public basePrice;
    uint256 public divider;

    bool internal priceInit;

   
    function __LiquidityLogic_init(string memory _symbol, address _ticker, address _oracle, uint256 _basePrice) internal {
        priceOracle = _oracle;
        symbol = _symbol;
        ticker = _ticker;
        priceInit = false;
        basePrice = _basePrice;
       
        divider = 1e6;
    }

    

    function price() external view returns(uint256 lastPrice) {
       (lastPrice, , ) = PriceOracle(priceOracle).lastUpdate(symbol);
    }

    function inflBase() public pure returns(uint256) {
        return SafeMath.mul(2, 1e7);
    }

    function calcInfl() internal {
        uint256 circulating = ERC20(ticker).totalSupply() == 0 ? 0 :  ERC20(ticker).totalSupply();
        uint256 val = circulating.mul(basePrice).mul(inflBase().mul(circulating));
        PriceOracle(priceOracle).updatePrice(symbol, basePrice + val.mul(circulating).div(1e7));
    }

    function priceETH() public view returns(uint256 lastPrice) {
    (lastPrice, , ) = PriceOracle(priceOracle).lastUpdate("AKXETH");
    }


    function addPriceETH(uint256 price_) internal  {
       
        PriceOracle(priceOracle).addNewTicker("AKXETH");
        PriceOracle(priceOracle).updatePrice("AKXETH",price_);
    }

}