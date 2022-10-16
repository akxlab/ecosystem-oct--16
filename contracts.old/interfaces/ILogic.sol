// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ILogic {

    event LogicInitialized(address _logic);

    function setLogicData(bytes calldata _data) external;
    function execute(address _from, bytes memory _data) external returns(bool);
    function coreLogic(bytes calldata _data) external;
    function getResults(address _from) external returns(uint256);

}