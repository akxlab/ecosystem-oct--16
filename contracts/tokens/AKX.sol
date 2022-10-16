// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./Base/ERC20.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../Roles.sol";




contract AKX3 is ERC20("AKX ECOSYSTEM", "AKX"), ReentrancyGuard, AKXRoles {

    using SafeERC20 for ERC20;
    event Deposit(address indexed from, uint256 _value);
    uint256 public maxSupply = 300000000000 ether;
    string public name = "AKX ECOSYSTEM";
    string public constant  symbol = "AKX";
    uint8 public constant decimals = 18;
    error ZeroValueSent();

    bool canTransfer = false;

    constructor()  {
        initRoles();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(AKX_OPERATOR_ROLE, _msgSender());
        
    }

    function mint(address _sender, uint256 amount) public  onlyRole(AKX_OPERATOR_ROLE) {
    super._mint(_sender, amount);
    }



 function enableTransfer() public onlyRole(AKX_OPERATOR_ROLE) {
        canTransfer = true;
    }

    modifier isTransferable() {
        require(canTransfer != false || hasRole(AKX_OPERATOR_ROLE, msg.sender), "cannot trade or transfer");
        _;
    }

    function transfer(address _to, uint256 _value) public isTransferable virtual override returns (bool success) {
        if (_value > 0 && _value <= balanceOf[msg.sender]) {
           super.transfer(_to, _value);
            success = true;
        }
       revert("cannot transfer");
    }

    

    // withdraw function in case of emergency only executable by the operator and only transferable to the gnosis multisignature treasury wallet
    function withdraw(address to) external onlyRole(AKX_OPERATOR_ROLE) {
        payable(to).transfer(address(this).balance);
    }

    receive() external payable {
        if(msg.value <= 0) {
            revert ZeroValueSent();
        }
        emit Deposit(msg.sender, msg.value);
    }

}