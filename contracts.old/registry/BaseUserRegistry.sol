// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../interfaces/IEIP721U.sol";
import "../modules/uds/UDS.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


abstract contract BaseUserRegistry is ERC721 {

    mapping(address => bool) public controllers;

    mapping(uint256 => mapping(uint256 => bool))  private registrationQueue;


    UDS internal uds;
    uint256 internal index;
    bytes32 public rootNodeAddress; // will be used in layer 2

    bytes4 public constant ERC721_ID =
    bytes4(
        keccak256("balanceOf(address)") ^
        keccak256("ownerOf(uint256)") ^
        keccak256("approve(address,uint256)") ^
        keccak256("getApproved(uint256)") ^
        keccak256("setApprovalForAll(address,bool)") ^
        keccak256("isApprovedForAll(address,address)") ^
        keccak256("transferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256,bytes)") ^
        keccak256("register(address)")
    );
    bytes4 public constant RECLAIM_ID = bytes4(keccak256("reclaim(uint256,address)"));
    bytes4 public constant REPUTATION_ID = bytes4(keccak256("reputation(uint256)"));

    function _isApprovedOrOwner(address spender, uint256 tokenId)
    internal
    view
    override
    returns (bool)
    {
        address _owner = ownerOf(tokenId);
        return (spender == _owner ||
        getApproved(tokenId) == spender ||
        isApprovedForAll(_owner, spender));
    }


    constructor(bytes32 rootNode, address _uds) ERC721("USER TOKEN AKX3","AKXU"){
        uds = UDS(_uds);
        rootNodeAddress = rootNode;
        index = 0;
    }

    modifier onlyLive() {
        require(uds.owner(rootNodeAddress) == msg.sender);
        _;
    }

    modifier onlyController() {
        require(controllers[msg.sender]);
        _;
    }

    function authorizeController(address controller) external  {
        controllers[controller] = true;
    }

    function deAuthorizeController(address controller) external  {
        controllers[controller] = false;
    }

    function setResolver(address resolver) external {
        uds.setResolver(rootNodeAddress, resolver);
    }





    function _register(uint256 tokenId, address _owner) internal  returns (uint256) {

        index += 1;

        registrationQueue[index][tokenId] = true;

        super._safeMint(_owner, tokenId);

        registrationQueue[index][tokenId] = false;


        return tokenId;

    }


}