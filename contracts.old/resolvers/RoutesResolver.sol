// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

struct Route {
        address _contract;
        bytes4 funcSelectorId;
        bool needsAuth;
        uint16 numParams;
}


abstract contract RoutesResolver {

    mapping(bytes32 => Route) internal _routeRegistry;
    mapping(address => bytes32) internal _contractRegistry;
    mapping(bytes32 => bool) internal _exists;

    error RouteNotExists();

    function registerRoute(address _contract, string memory routeString, bytes4 interfaceId, uint16 numParams, bool needsAuth) internal {
        
        bytes32 routeName = keccak256(abi.encodePacked(routeString));
        require(_exists[routeName] != true, "route already exists");
        _contractRegistry[_contract] = routeName;
        Route memory _r = Route(_contract, interfaceId, needsAuth, numParams);
        _routeRegistry[routeName] = _r;
        _exists[routeName] = true;
    }

    function deRegisterRoute(bytes32 _routeName) internal {
        require(_exists[_routeName], "invalid route");
        Route memory _r = _routeRegistry[_routeName];
        address _c = _r._contract;
        delete _contractRegistry[_c];
        delete _exists[_routeName];
        delete _routeRegistry[_routeName];
    }

    function _beforeRouting(bytes32 _routeName) internal virtual;

    function _useRoute(bytes32 _routeName) internal returns(Route memory) {
        if(_exists[_routeName] != true) {
            revert RouteNotExists();
        }
        _beforeRouting(_routeName);

        return _routeRegistry[_routeName];

    }



}