// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


abstract contract InitModifiers {

bool internal initialized;

modifier onlyNotInitialized() {
    require(initialized != true, "already initialized");
    _;
}

modifier onlyInitialized() {
    require(initialized == true, "not initialized");
    _;
}

function setInitialized() internal virtual onlyNotInitialized {
    initialized = true;
}

}