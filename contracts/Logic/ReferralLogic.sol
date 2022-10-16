// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


import "../interfaces/ILogic.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReferralLogic is ILogic, Ownable {

    struct DataRequest {
        address _sender;
        string code;
        address _referree;
        uint256 _amount;
    }

    uint256 private _index;
    uint256 private mantissa = 1e6;

    mapping(uint256 => DataRequest) private _reqById;
    mapping(address => uint256) private _currentReqIdByAddress;
    mapping(uint256 => bool) private _pending;
    mapping(uint256 => bool) private _failed;
    mapping(uint256 => bool) private _done;
    mapping(uint256 => uint256) private _results;
    mapping(address => uint256) private _percent;
    mapping(address => uint256) private _multiplier;

    constructor() {
        _index = 0;
      
    }

    function setLogicData(bytes memory _data) public override onlyOwner {

        DataRequest memory _d  = abi.decode(_data, (DataRequest));
        uint256 _i = _index;
        _index += 1;
        _reqById[_i] = _d;
        _currentReqIdByAddress[_d._sender] = _i;
        _pending[_i] = true;

    }

    function execute(address _from, bytes memory _data) public override onlyOwner returns(bool) {
        coreLogic(_data);
        uint256 req = _currentReqIdByAddress[_from];
        delete _pending[req];
        _done[req] = true;
        return true;
    }

    function coreLogic(bytes memory _data) public override onlyOwner  {
        setLogicData(_data);
        DataRequest memory _req = _reqById[_index-1];
        address sender = _req._sender;
        uint256 reqId = _currentReqIdByAddress[_req._sender];
        _results[reqId] = 0; // we initialize _results
        uint256 percentage = _percent[sender] * mantissa;
        uint256 multiplier = _multiplier[sender] * mantissa;
        uint256 amount = _req._amount / mantissa;
        uint256 amt = amount * (percentage * multiplier) / mantissa;
        _results[reqId] = amt;
    }

    function getResults(address _from) external returns(uint256) {
        uint256 req = _currentReqIdByAddress[_from];
        require(_done[req] == true, "request is pending...");
        return _results[req];
    }
}