// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Location} from "../Location.sol";

/// @notice Location to identify an asset.
struct AssetId {
    /// @custom:property The location of the asset.
    Location location;
}
