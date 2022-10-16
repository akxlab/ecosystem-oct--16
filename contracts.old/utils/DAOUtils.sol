// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
using AddressUpgradeable for address;

abstract contract DAOUtils {

address public dao;

   function setDAOAddress(address _dao) internal virtual {
    dao = _dao;
   }


    function setVotingToken(address _target) internal virtual;

    function addProposal(bytes4 proposalId) internal virtual;

    function updateProposal(bytes4 proposalId, bytes calldata _updated) external virtual;




     modifier onlyDAO() {
        if(!msg.sender.isContract()) {
            revert("the dao should be a contract!");
        }
        if(msg.sender != dao) {
            revert("can be done only by the dao");
        }
        _;
    }
}