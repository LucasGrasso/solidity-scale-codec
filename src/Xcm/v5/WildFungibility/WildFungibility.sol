// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @notice Classification of whether an asset is fungible or not.
enum WildFungibility {
    /// @custom:variant The asset is fungible.
    Fungible,
    /// @custom:variant The asset is not fungible.
    NonFungible
}
