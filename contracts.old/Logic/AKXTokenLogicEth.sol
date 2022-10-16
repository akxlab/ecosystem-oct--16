///  SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title AKX Token General and Presale TX Logic
/// @author AKX3 ECOSYSTEM (akx3.com) 
/// @repository https://github.com/akxlab/ecosystem1/
/// @date Sunday October 9th, 2022
/// @notice This contract manages AKX presale conditions and the general token sell and buy logic on ethereum Mainnet
/// @notice AKX Token is on Ethereum mainnet: 0x0f14c121922df116f9635E4C8302FF15d88E7422
/// @notice GNOSIS VAULT MULTISIGNATURE WALLET (TREASURY): 0x39b9fdA7d6cfE6987126c9010aaA56635E224bdB
/// @notice GNOSIS VAULT MULTISIGNATURE WALLET (FEES VAULT): 0x05ceA7862778589c6ebcB6DE7ef2465a3e634468

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {AKX3, AKXRoles, ERC20} from "../tokens/AKX.sol";


import {AKXMath} from "./AKXMath.sol";

error NoZeroAddress();
error  EmptyOrZeroEthSend();
error ContractCannotBuy();
error ContractCannotDeposit();
error  NotEnoughtSupply();

contract AKXTokenLogicEth is
    AKXRoles,
    ReentrancyGuard,
    AKXMath
{

    using SafeERC20 for ERC20;
    using Address for address;


    /// @notice maximum supply allowed to be minted or token supply available for presale (65 Million AKX)
    /// @dev this is setup in the initializer to avoid upgradability issues
    uint256 public presaleSupply;
    /// @notice maximum duration of presale is 180 days or until all available presale supply is sold
    /// @dev this is setup in the initializer to avoid upgradability issues
    uint256 public presaleMaxDuration;

    /// @notice when the presale did end if its expired
    /// @dev this is setup in the initializer to avoid upgradability issues
    uint256 public presaleEndedOn;

    /// @notice AKX founders addresses
    /// @dev this is setup during deployment calling the addFounder function
    address[] public founders;
    /// @notice AKX founders allocations in AKX tokens
    /// @dev this should never be preminted it is only allocated when tokens are sold and a maximum of 4% of available supply is allowed per founder
    mapping(address => uint256) public founderAllocation;
    /// @notice To check if an address is a founder
    mapping(address => bool) public isFounder;


    /// @notice true if transfer is allowed, false if it is not
    bool public canTransfer;

    /// @notice current AKX price in Ether (1 AKX = Price in ether)
    /// @dev price will be calculated externally to reduce gas fees and internal calculations
    uint256 public price;



    /// @notice AKX ERC20 Token
    AKX3 internal _underlyingToken;

    address internal feeWallet;
    address internal treasury;

    event FeeWalletSet(address indexed fwAddress);
    event TreasurySet(address indexed twAddress);
    event Deposit(address indexed _sender, uint256 amount);
    event FeeCollected(
        address indexed from,
        address indexed feeVault,
        uint256 amount
    );
    event Buy(
        address indexed buyer,
        uint256 ethAmount,
        uint256 akxAmount,
        bool isPresale
    );
    event Sell(address indexed seller, uint256 amountAkx, uint256 amountEth);
    event Lock(address indexed wallet, uint256 akxAmount, uint256 unlockTime);
    event PriceUpdated(address indexed from, uint256 oldPrice, uint256 price);

    event PresaleCompleted(uint256 onTimestamp);
    event PresaleStarted(uint256 onTimestamp);
    event PresalePaused(uint256 onTimestamp);
    event WithdrawToTreasury(
        uint256 onTimestamp,
        uint256 amount,
        address indexed treasuryWallet
    );

    /// @notice Ether is not transfered automatically to the treasury. It is sitting in this variable until a pull withdrawal request is made using the withdrawtoTreasury function from the Treasury wallet only.
    uint256 public pendingTransferToTreasury;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor()  {
        _disableInitializers();
      }

    function initialize(
        address _ticker,
        uint256 _basePrice,
        address _fw,
        address _tw
    ) public initializer {
        __AKXTokenLogic_init(_ticker, _basePrice, _fw, _tw);
        initRoles();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AKX_OPERATOR_ROLE, msg.sender);
    }

    function __AKXTokenLogic_init(
        address _ticker,
        uint256 _basePrice,
        address _fw,
        address _tw
    ) public onlyInitializing {
        _underlyingToken = AKX3(payable(_ticker));

        presaleSupply = 650000000 ether; ///  65M AKX for presale: presale ends when all presale supply is sold
  
        canTransfer = false;
        price = _basePrice;

        init();
        feeWallet = _fw;
        treasury = _tw;

    }

    /// @notice updates AKX price in ether
    /// @dev only the operator can update the price which needs to be calculated externally emits PriceUpdated event
    /// @param newPrice the new price to set
    function updatePrice(uint256 newPrice) public onlyRole(AKX_OPERATOR_ROLE) {
        uint256 _oldPrice = price;
        price = newPrice;
        emit PriceUpdated(msg.sender, _oldPrice, newPrice);
    }

    /// @notice updates the fee wallet address
    /// @dev only the operator can update the fee wallet address. This function should never be used and is there only in case of wallet malfunction and mitigate damages if it happens.
    /// @param _fw fee wallet address
    function setFeeWallet(address _fw) public onlyRole(AKX_OPERATOR_ROLE) {
        feeWallet = _fw;
        emit FeeWalletSet(_fw);
    }

    /// @notice updates the treasury wallet address
    /// @dev only the operator can update the treasury wallet address. This function should never be used and is there only in case of wallet malfunction and mitigate damages if it happens.
    /// @param _tw treasury wallet address
    function setTreasury(address _tw) public onlyRole(AKX_OPERATOR_ROLE) {
        treasury = _tw;
    }

    function endPresale(uint64 ts) public onlyRole(AKX_OPERATOR_ROLE) returns (bool) {
     
        if (ts < ts + 180 days) {
            if (presaleSupply > _underlyingToken.totalSupply()) {
                return false;
            } else {
                _endPresale(ts);
                return true;
            }
        } else {
            _endPresale(ts);
            return true;
        }
    }

    function _endPresale(uint64 ts) internal {
        presaleEndedOn = ts;
        enableTransfer();
        withdrawToTreasury();
        emit PresaleCompleted(presaleEndedOn);
    }



    function enableTransfer() public onlyRole(AKX_OPERATOR_ROLE) {
        canTransfer = true;
        _underlyingToken.enableTransfer();
    }

    function disableTransfer() public onlyRole(AKX_OPERATOR_ROLE) {
        canTransfer = false;
    }

    /// to buy AKX token during presale and after can be called by wallets only not contracts. 
    /// will revert if sender is zero address, value is 0, or if caller is a contract or if caller is trying to buy more than available
    function buy(uint64 ts) public payable {
        if (msg.sender == address(0)) {
            revert NoZeroAddress();
        }
        if (msg.value <= 0) {
            revert EmptyOrZeroEthSend();
        }
        if (msg.sender.isContract()) {
            revert ContractCannotBuy();
        }

     
        uint256 akxToMint = (msg.value * price) / 1e18;
        uint256 fee = getTxFee(akxToMint);

        if (mintOverflowCheck(akxToMint + fee, ts)) {
            pendingTransferToTreasury += msg.value;
            safeMint(_msgSender(), akxToMint);
        }
        emit Buy(msg.sender, msg.value, akxToMint - fee,true);
    }

    function mintOverflowCheck(uint256 amount, uint64 ts)
        internal
        view
        returns (bool success)
    {
        if (presaleMaxDuration < ts + 25 seconds) {
            if (amount > presaleSupply) {
                revert NotEnoughtSupply();
            }
        } else {
            if (amount > 300000000000 * 1e18) {
                revert NotEnoughtSupply();
            }
        }
        success = true;
    }


   
    function safeMint(address _sender, uint256 amount) internal {
        _underlyingToken.mint(_sender, amount);
        mintFees(_sender, amount);
     
    }

    function mintFees(address _sender, uint256 amount) internal {
        uint256 fee = getTxFee(amount);
        _underlyingToken.mint(feeWallet, fee);
           emit FeeCollected(_sender, feeWallet, fee);
    }



    function addFounder(address founder)
        public
        onlyRole(AKX_OPERATOR_ROLE)
    {
        isFounder[founder] = true;
        founders.push(founder);
    }


    function allocateToFounder(address founder, uint256 amount)
        public
        onlyRole(AKX_OPERATOR_ROLE)
    {
        founderAllocation[founder] = amount;
    }


    function executeAllocations(uint256 amt) internal {
        uint j = 0;
        for (j == 0; j < founders.length; j++) {
            unchecked {
                address f = founders[j];
                if (isFounder[f]) {
                    uint256 amount = getPercentForFounder(amt);
                    allocateToFounder(f, amount);
                    _underlyingToken.mint(f, amount);
                }
            }
        }
    }

     /// see pendingtotreasury public state for description
    function withdrawToTreasury()
        public
        nonReentrant
        onlyRole(AKX_OPERATOR_ROLE)
    {
        payable(treasury).transfer(address(this).balance);
        pendingTransferToTreasury = 0;
    }

    function deposit(address _sender, uint256 _amt) public nonReentrant {
        if (_sender == address(0)) {
            revert NoZeroAddress();
        }
        if (_amt <= 0) {
            revert EmptyOrZeroEthSend();
        }
        if (_sender.isContract()) {
            revert ContractCannotDeposit();
        }
        emit Deposit(_sender, _amt);
    }


    receive() external payable {
        deposit(msg.sender, msg.value);
    }
}
