// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ChildAKX is ERC20, ERC20Burnable, Ownable {

    event ReceivedEthersForAKX(address indexed _sender, address indexed _fromBridgeContract, uint256 amount);
    event AKXMinted(address indexed _sender, address indexed _mintedFor, uint256 amount);
    event ETHTransferedToTreasury(address indexed treasury, uint256 amount, uint256 timestamp);

    mapping(address => uint256) public pendingMinting;
    uint256 public pendingTransferToTreasury;

    address internal ethTreasury;


    constructor(address ethTreasury_) ERC20("wAKX", "wAKX") {
        ethTreasury = ethTreasury_;
    }

    function sendEthersForAKX(address _mintFor,  uint256 amtAKX) external payable  {
         emit ReceivedEthersForAKX(_mintFor, msg.sender, msg.value);
         pendingMinting[_mintFor] += amtAKX;
         pendingTransferToTreasury += msg.value;
    }

    function mint(address _mintFor) external payable onlyOwner {
        super._mint(address(this), pendingMinting[_mintFor]);
        pendingMinting[_mintFor] = 0;
        emit AKXMinted(msg.sender, _mintFor, pendingMinting[_mintFor]);
    }

    function burnTokenAfterTransfer(uint256 amount) external payable onlyOwner {
        super.burn(amount);
    }

    function transferToEthTreasury(uint256 amount) external payable onlyOwner {

        require(amount <= pendingTransferToTreasury, "invalid amount");
       
         pendingTransferToTreasury -= amount;
         payable(ethTreasury).transfer(amount);
         emit ETHTransferedToTreasury(ethTreasury, amount, block.timestamp);

    }



    receive() external payable {
        
    }

}