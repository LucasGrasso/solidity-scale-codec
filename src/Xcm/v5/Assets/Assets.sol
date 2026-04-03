// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Asset} from "../Asset/Asset.sol";

/// @notice An array of Assets.
/// @dev There are a number of invariants which the construction and mutation functions must ensure are maintained:
/// - It may contain no items of duplicate asset class.
/// - All items must be ordered.
/// - The number of items should grow no larger than `MAX_ITEMS_IN_ASSETS`.
struct Assets {
    /// @custom:property The items of the array.
    Asset[] items;
}

/// @notice Creates an `Assets` wrapper from a single `Asset`.
/// @param asset The asset to include.
/// @return An `Assets` struct containing one item.
function fromAsset(Asset memory asset) pure returns (Assets memory) {
    Asset[] memory items = new Asset[](1);
    items[0] = asset;
    return Assets({items: items});
}

/// @notice Creates an `Assets` wrapper from an asset array.
/// @param assets The assets to include.
/// @return An `Assets` struct containing `assets`.
function fromAssets(Asset[] memory assets) pure returns (Assets memory) {
    return Assets({items: assets});
}
