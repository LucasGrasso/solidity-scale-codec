// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Assets} from "../Assets/Assets.sol";
import {AssetsCodec} from "../Assets/AssetsCodec.sol";
import {WildAssetCodec, WildAsset} from "../WildAsset.sol";

/// @notice Discriminant for the type of asset filter being specified in an `AssetFilter`.
enum AssetFilterType {
    /// @custom:variant Specify the filter as being everything contained by the given `Assets` inner.
    Definite,
    /// @custom:variant Specify the filter as the given `WildAsset` wildcard.
    Wild
}

/// @notice `Asset` collection, defined either by a number of `Assets` or a single wildcard.
struct AssetFilter {
    /// @custom:property The type of asset filter, determining how to interpret the payload. See `AssetFilterType` enum for possible values.
    AssetFilterType afType;
    /// @custom:property The encoded payload containing the asset filter data, whose structure depends on the `afType`.
    bytes payload;
}

// ============ Factory Functions ============

/// @notice Creates an `AssetFilter` struct representing the `Definite` variant, which matches all assets contained by the given `Assets` inner.
/// @param assets The `Assets` inner to use as the basis for the filter.
/// @return An `AssetFilter` with the `Assets` variant and the given `Assets` inner as its payload.
function definite(Assets memory assets) pure returns (AssetFilter memory) {
    return
        AssetFilter({
            afType: AssetFilterType.Definite,
            payload: AssetsCodec.encode(assets)
        });
}

/// @notice Creates an `AssetFilter` struct representing the `Wild` variant, which matches all assets contained by the given `WildAsset` wildcard.
/// @param wA The `WildAsset` wildcard to use as the basis for the filter.
/// @return An `AssetFilter` with the `Wild` variant and the given `WildAsset` wildcard as its payload.
function wild(WildAsset memory wA) pure returns (AssetFilter memory) {
    return
        AssetFilter({
            afType: AssetFilterType.Wild,
            payload: WildAssetCodec.encode(wA)
        });
}
