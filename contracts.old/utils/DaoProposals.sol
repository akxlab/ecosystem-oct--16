// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


abstract contract DAOProposalsUtils {

      function SubmitOtherProposal(
        uint256 timestampChangeShouldTakePlace,
        string memory additionalReasons,
        address contractToProposeOrExampleContract
    ) external virtual;

    function approveNewProposalForVoting(address from, bytes4 proposalId) public virtual;
    function denyNewProposalForVoting(bytes4 proposalId) public virtual;



}
