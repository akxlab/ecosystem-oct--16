// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {LiquidityLogic, PriceOracle} from "./LiquidityLogic.sol";
import {ReentrancyGuardUpgradeable, Initializable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {AKX3, AKXRoles, ERC20} from "../tokens/AKX.sol";

import {AKXMath} from "./AKXMath.sol";

contract AKXTokenLogic is
    Initializable,
    LiquidityLogic,
    AKXRoles,
    ReentrancyGuardUpgradeable,
    AKXMath
{
    using SafeERC20 for ERC20;

    uint256 public maxSupply;
    uint256 public presaleSupply;
    uint256 public presaleMaxDuration;
    uint256 public presaleStartedOn;
    uint256 public presaleEndedOn;

    address[] public founders;
    mapping(address => uint256) public founderAllocation;
    mapping(address => bool) public isFounder;
    mapping(address => uint256) public founderPercent;

    bool public isPresale;
    bool public canTransfer;
    bool public ownerIsContract;
    bool public decentralized;

    uint256 public numHolders;
    uint256 public circulating;
    uint256 public marketCap;
    uint256 public softCap;
    uint256 public currentPrice;

    address public pOracle;

    AKX3 internal _underlyingToken;

    address public feeWallet;
    address public treasury;

    event Deposit(address indexed _sender, uint256 amount);
    event BoughtWithEther(
        address indexed buyer,
        address indexed ethContractAddress,
        uint256 ethersSent,
        uint256 akxAmount
    );
    event TransferToPolygon(address indexed buyer, uint256 akxAmount);
    event TransferCompleted(address indexed buyer, uint256 akxAmount);
    event PresaleCompleted(uint256 onTimestamp);

    mapping(address => uint256) private _pendingBalance;

    mapping(address => uint256) public _balances;
    uint256 public ethInTreasury;
    uint256 public maticsInTreasury;
    mapping(address => uint256) public feeCollected;
    uint256 public pendingTransferToTreasury;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _symbol,
     
        address _ticker,
        address _oracle,
        uint256 _basePrice,
        address _fw,
        address _tw
    ) public initializer {
        __AKXTokenLogic_init(
            _symbol,
           
            _ticker,
            _oracle,
            _basePrice,
            _fw,
            _tw
        );
        initRoles();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AKX_OPERATOR_ROLE, msg.sender);
    }

    function __AKXTokenLogic_init(
        string memory _symbol,
        address _ticker,
        address _oracle,
        uint256 _basePrice,
        address _fw,
        address _tw
    ) public onlyInitializing {
        __LiquidityLogic_init(_symbol, _ticker, _oracle, _basePrice);
        _underlyingToken = AKX3(payable(_ticker));

        maxSupply = 3000000000 ether;
        presaleSupply = 65000000 ether; // presale ends when all presale supply is sold
        presaleMaxDuration = 180 days; // max duration to sell all presale supply is 6 months
        canTransfer = false;
        numHolders = 0;
        circulating = 0;
        marketCap = 0;
        softCap = 0;
        currentPrice = _basePrice;
        isPresale = true;
        presaleStartedOn = block.timestamp;
        pOracle = _oracle;
        init();
        feeWallet = _fw;
        treasury = _tw;
    }

    function updatePrice(uint256 newPrice) public onlyRole(AKX_OPERATOR_ROLE) {
        PriceOracle(pOracle).updatePrice("AKX", newPrice);
    }

    function setFeeWallet(address _fw) public onlyRole(AKX_OPERATOR_ROLE) {
        feeWallet = _fw;
    }

    function setTreasury(address _tw) public onlyRole(AKX_OPERATOR_ROLE) {
        treasury = _tw;
    }

    function endPresale() public onlyRole(AKX_OPERATOR_ROLE) returns (bool) {
        require(isPresale == true, "presale is not started");
        if (block.timestamp < presaleStartedOn + presaleMaxDuration) {
            if (maxSupply > _underlyingToken.totalSupply()) {
                return false;
            } else {
                _endPresale();
                return true;
            }
        } else {
            _endPresale();
            return true;
        }
    }

    function _endPresale() internal {
        isPresale = false;
        presaleEndedOn = block.timestamp;
        enableTransfer();
        withdrawToTreasury();
        emit PresaleCompleted(presaleEndedOn);
    }

    function temporaryPausePresale() onlyRole(AKX_OPERATOR_ROLE) public {
        isPresale = false;
    }

    function restart()  onlyRole(AKX_OPERATOR_ROLE) public {
        isPresale = true;
    }

    function enableTransfer() public onlyRole(AKX_OPERATOR_ROLE) {
        canTransfer = true;
        _underlyingToken.enableTransfer();
    }

    function disableTransfer() public onlyRole(AKX_OPERATOR_ROLE) {
        canTransfer = false;
        
    }

    function buyWithEther() public payable {
        require(
            block.chainid == 0x01 || block.chainid == 0x05,
            "not on mainnet or goerli!"
        );

        require(msg.sender != address(0x0), "no zero address");
        require(msg.value > 0, "you need to send some ethers!");
        uint256 akxToMint = msg.value * priceETH();
        uint256 fee = getTxFee(akxToMint);
        safeMint(_msgSender(), akxToMint - fee);
       
        emit BoughtWithEther(msg.sender, address(this), msg.value, akxToMint);
        _pendingBalance[msg.sender] = akxToMint;
    }

    function transferToPolygon(uint256 akxAmount, address sender)
        external
        onlyRole(AKX_OPERATOR_ROLE)
    {
        require(
            block.chainid == 0x13881 || block.chainid == 0x89,
            "not on polygon network!"
        );
        safeMint(sender, akxAmount);
    }

    function burnOnEthereum(address _sender, uint256 akxAmount)
        external
        onlyRole(AKX_OPERATOR_ROLE)
    {
        require(
            block.chainid == 0x01 || block.chainid == 0x05,
            "not on mainnet or goerli!"
        );
        _pendingBalance[_sender] = 0;
        emit TransferCompleted(_sender, akxAmount);
    }

    function buyPresale() public payable {
        require(!endPresale(), "presale is already ended");
        // require(block.chainid == 0x13881 || block.chainid == 0x89, "not on polygon network!");
        require(msg.sender != address(0x0), "no zero address");
        require(msg.value > 0, "you need to send some matics!");
        require(
            _underlyingToken.totalSupply() < this.presaleSupply(),
            "presale is over max supply minted"
        );
        //  calcInfl();
        uint256 toMint = (msg.value * basePrice) / 1e18;
       
        pendingTransferToTreasury += msg.value;
        safeMint(_msgSender(), toMint);
       
    }

    function deposit() external payable {
        require(msg.sender != address(0x0), "no zero address");
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawToTreasury() public onlyRole(AKX_OPERATOR_ROLE)  {
      
        payable(treasury).transfer(address(this).balance);
        maticsInTreasury += pendingTransferToTreasury;

    }

    function setEthPrice(uint256 _price) external onlyRole(AKX_OPERATOR_ROLE) {
        addPriceETH(_price);
    }

    function safeMint(address _sender, uint256 amount) internal {
        _underlyingToken.mint(msg.sender, amount);
 uint256 fee = getTxFee(amount);
 _underlyingToken.mint(feeWallet, fee);
        numHolders += 1;
        circulating += amount;
        feeCollected[_sender] = fee;
        executeAllocations(amount);
        
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

    function allocateToFounder(address founder, uint256 amount)
        public
        onlyRole(AKX_OPERATOR_ROLE)
    {
        founderAllocation[founder] = amount;
    }

    function addFounder(address founder, uint256 percent)
        public
        onlyRole(AKX_OPERATOR_ROLE)
    {
        isFounder[founder] = true;
        founderPercent[founder] = percent;
        founders.push(founder);
    }

    function founderHoldPercent(address founder)
        public
        view
        returns (uint percent)
    {
        uint256 amt = founderAllocation[founder] +
            _underlyingToken.balanceOf(founder);
        return (amt * _underlyingToken.totalSupply()) / 100;
    }

    receive() external payable {}

    fallback() external payable {}
}