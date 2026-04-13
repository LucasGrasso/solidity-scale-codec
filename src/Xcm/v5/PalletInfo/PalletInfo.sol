// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @notice Information about a pallet on a Substrate-based chain.
struct PalletInfo {
    /// @custom:property The index which identifies the pallet.
    uint32 index;
    /// @custom:property The major version of the crate which implements the pallet.
    uint32 major;
    /// @custom:property The minor version of the crate which implements the pallet.
    uint32 minor;
    /// @custom:property The patch version of the crate which implements the pallet.
    uint32 patch;
    /// @custom:property The name of the pallet. Max length is `MAX_PALLET_NAME_LEN`.
    bytes name;
    /// @custom:property The module name of the pallet. Max length is `MAX_PALLET_NAME_LEN`.
    bytes moduleName;
}
