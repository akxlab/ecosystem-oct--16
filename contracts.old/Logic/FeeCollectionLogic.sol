// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

 enum FeeTypes {
        DEFAULT,
        TX_FEE,
        TX_PREMIUM,
        DAO,
        DEX
    }

contract FeeCollectionLogic is Ownable {

    address payable public feeEscrow;
    ERC20 internal feeToken;

    using SafeERC20 for ERC20;

   

    struct TxAmounts {
        uint256 amountIn;
        uint256 amountOut;
    }

    struct FeeDetails {
        FeeTypes feeType;
        TxAmounts txIO;
        uint256 fee;
    }

    mapping(address => mapping(uint256 => FeeDetails))  private _feesByAddress;
    mapping(address => uint256) private _indexes;
    mapping(address => uint256) private _totalFeePaid;

    mapping(bytes32 => uint128) private _feeTypes;
  

    uint128 public constant Mantissa = 1e6;
    uint128 public constant PercentDefault = 150000; // 1.5% or 0.015 * Mantissa default tx fee on public sale
    uint128 public constant PercentPerPledge = 10 * Mantissa;  // 10% goes for overheads in private sale pledges
    uint128 public constant FeeRedistributionPercent = 60 * Mantissa; // 60% of fees are redistributed to holders
    

    bytes32 private constant DEFAULT_FEE = keccak256("DEFAULT_FEE");
    bytes32 private constant TX_FEE = keccak256("TX_FEE");
    bytes32 private constant TX_PREMIUM = keccak256("TX_PREMIUM");
    bytes32 private constant DAO_FEE = keccak256("DAO_FEE");
    bytes32 private constant DEX_FEE = keccak256("DEX_FEE");

    event FeeCollected(address indexed from, address indexed to, uint256 origAmt, uint256 feeAmt);

    constructor(address payable __feeToken) {
        feeToken = ERC20(__feeToken);
      
        _feeTypes[DEFAULT_FEE] = PercentDefault;
        _feeTypes[TX_FEE] = PercentDefault;
        _feeTypes[TX_PREMIUM] = PercentPerPledge;
        _feeTypes[DAO_FEE] = 0; // not active yet
        _feeTypes[DEX_FEE] = 0; // not active yet
    }

    function GetFee(bytes32 feeType, uint256 amount) public view  returns(uint256) {
        
        uint128 feePercent = _feeTypes[feeType];
   
        uint256 fee = uint256(_calculateFee(amount, feePercent));
        return uint256(fee);

    }

    function _calculateFee(uint256 _amt, uint256 _percent) internal pure returns(uint) {
        return _amt * _percent / Mantissa;
    }




}