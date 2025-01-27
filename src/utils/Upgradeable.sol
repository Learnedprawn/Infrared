// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {AccessControlUpgradeable} from
    "@openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {
    UUPSUpgradeable,
    ERC1967Utils
} from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {Errors} from "./Errors.sol";

/**
 * @title Upgradeable
 * @notice Provides base upgradeability functionality using UUPS and access control.
 */
abstract contract Upgradeable is UUPSUpgradeable, AccessControlUpgradeable {
    // Access control constants.
    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    /**
     * @notice Modifier to restrict access to KEEPER_ROLE.
     */
    modifier onlyKeeper() {
        _checkRole(KEEPER_ROLE);
        _;
    }

    /**
     * @notice Modifier to restrict access to GOVERNANCE_ROLE.
     */
    modifier onlyGovernor() {
        _checkRole(GOVERNANCE_ROLE);
        _;
    }

    modifier whenInitialized() {
        uint64 _version = _getInitializedVersion();
        if (_version == 0 || _version == type(uint64).max) {
            revert Errors.NotInitialized();
        }
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers(); // Ensure the contract cannot be initialized through the logic contract
    }

    /**
     * @notice Initialize the upgradeable contract.
     */
    function __Upgradeable_init() internal onlyInitializing {
        __UUPSUpgradeable_init();
        __AccessControl_init();
    }

    /**
     * @dev Restrict upgrades to only the governor.
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyGovernor
    {
        // allow only owner to upgrade the implementation
        // will be called by upgradeToAndCall
    }

    /**
     * @notice Returns the current implementation address.
     */
    function currentImplementation() external view returns (address) {
        return ERC1967Utils.getImplementation();
    }

    /**
     * @notice Alias for `currentImplementation` for clarity.
     */
    function implementation() external view returns (address) {
        return ERC1967Utils.getImplementation();
    }
}
