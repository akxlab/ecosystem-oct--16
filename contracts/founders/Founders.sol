///  SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {AKXMath}  from "../Logic/AKXMath.sol";
import {AKXRoles} from "../Roles.sol";
import {AKX3} from "../tokens/AKX.sol";

contract Founders is AKXMath, AKXRoles {
    /// @notice AKX founders addresses
    /// @dev this is setup during deployment calling the addFounder function
    address[] public founders;
    /// @notice AKX founders allocations in AKX tokens
    /// @dev this should never be preminted it is only allocated when tokens are sold and a maximum of 4% of available supply is allowed per founder
    mapping(address => uint256) public founderAllocation;
    /// @notice To check if an address is a founder
    mapping(address => bool) public isFounder;
    event AllocationSentToFounder(address indexed founder, uint256 value);

    AKX3 internal _underlyingToken;

    constructor(address payable _token) {
        _underlyingToken = AKX3(_token);
        initRoles();
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


    function executeAllocations(uint256 amt) public onlyRole(AKX_OPERATOR_ROLE) {
        uint j = 0;
        for (j == 0; j < founders.length; j++) {
            unchecked {
                address f = founders[j];
                if (isFounder[f]) {
                    uint256 amount = getPercentForFounder(amt);
                    allocateToFounder(f, amount);
                    _underlyingToken.mint(f, amount);
                    emit AllocationSentToFounder(f, amount);
                }
            }
        }
    }

}