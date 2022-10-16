// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract AKXSetup {

    address internal labzToken;
    address internal identityRegistry;
    address internal dexService;
    address internal daoGovernor;
    address internal akxToken; // vote enabled token
    address internal refContract;
    address internal psl;
    address internal rootController;

    function _setLabzToken(address _tok) internal virtual {
        labzToken = _tok;
    }

    function _setIdentRegistry(address _idr) internal virtual {
        identityRegistry = _idr;
    }

    function _setDEX(address _dex) internal virtual {
        dexService = _dex;
    }

    function _setGov(address _gov) internal virtual {
        daoGovernor = _gov;
    }

    function _setAkxToken(address _akx) internal virtual {
        akxToken = _akx;
    }

    function _setReferralContract(address _ref) internal virtual {
        refContract = _ref;
    }

    function _setPrivateSaleLogic(address _psl) internal virtual {
        psl = _psl;
    }

    function _setRootController(address _ctrl) internal virtual {
        rootController = _ctrl;
    }
}