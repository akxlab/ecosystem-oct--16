// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
interface IEIP721U is IERC721 {

    event UserMigrated(
        uint256 indexed id,
        address indexed owner,
        uint256 ts
    );
    event UserRegistered(
        uint256 indexed id,
        address indexed owner,
        uint256 ts
    );
    event UserUpdated(uint256 indexed id, uint256 ts);

    function userCreatedDate(uint256 id) external returns(uint256);
    function available(uint256 id) external returns(bool);
    function reclaim(uint256 id, address owner) external;
    function reputation(uint256 id) external returns(uint256);
    function nativeValue(uint256 id) external returns(uint256);



}