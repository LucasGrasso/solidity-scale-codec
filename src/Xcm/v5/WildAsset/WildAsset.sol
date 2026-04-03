// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {AssetId} from "../AssetId/AssetId.sol";
import {AssetIdCodec} from "../AssetId/AssetIdCodec.sol";
import {WildFungibility} from "../WildFungibility/WildFungibility.sol";
import {WildFungibilityCodec} from "../WildFungibility/WildFungibilityCodec.sol";

/// @notice Discriminant for the type of asset being specified in a `WildAsset`.
enum WildAssetVariant {
    /// @custom:variant All assets in Holding.
    All,
    /// @custom:variant All assets in Holding of a given fungibility and ID.
    AllOf,
    /// @custom:variant All assets in Holding, up to `uint32` individual assets (different instances of non-fungibles are separate assets).
    AllCounted,
    /// @custom:variant All assets in Holding of a given fungibility and ID up to `count` individual assets (different instances of non-fungibles are separate assets).
    AllOfCounted
}

/// @notice Parameters for the `AllOf` variant of `WildAsset`, specifying a particular asset class and fungibility to match against.
struct AllOfParams {
    /// @custom:property The asset class to match against.
    AssetId id;
    /// @custom:property The fungibility to match against.
    WildFungibility fun;
}

/// @notice Parameters for the `AllOfCounted` variant of `WildAsset`, specifying a limit of assets to match against.
struct AllOfCountedParams {
    /// @custom:property The asset class to match against.
    AssetId id;
    /// @custom:property The fungibility to match against.
    WildFungibility fun;
    /// @custom:property The limit of assets to match against.
    uint32 count;
}

/// @notice Parameters for the `AllCounted` variant of `WildAsset`.
struct AllCountedParams {
    /// @custom:property The upper bound of matched assets.
    uint32 count;
}

/// @notice A wildcard representing a set of assets.
struct WildAsset {
    /// @custom:property The type of wild asset, determining how to interpret the payload. See `WildAssetVariant` enum for possible values.
    WildAssetVariant variant;
    /// @custom:property The encoded payload containing the wild asset data, whose structure depends on the `variant`.
    bytes payload;
}

// ============ Factory Functions ============

/// @notice Creates a `WildAsset` struct representing the `All` variant, which matches all assets in Holding.
/// @return A `WildAsset` with the `All` variant.
function all() pure returns (WildAsset memory) {
    return WildAsset({variant: WildAssetVariant.All, payload: ""});
}

/// @notice Creates a `WildAsset` struct representing the `AllOf` variant, which matches all assets in Holding of a given fungibility and ID.
/// @param id The `AssetId` struct specifying the asset class to match against.
/// @param fun The `WildFungibility` struct specifying the fungibility to match against.
/// @return A `WildAsset` with the `AllOf` variant and the encoded parameters in the payload.
function allOf(
    AssetId memory id,
    WildFungibility fun
) pure returns (WildAsset memory) {
    return
        WildAsset({
            variant: WildAssetVariant.AllOf,
            payload: abi.encodePacked(
                AssetIdCodec.encode(id),
                WildFungibilityCodec.encode(fun)
            )
        });
}

/// @notice Creates a `WildAsset` struct representing the `AllCounted` variant, which matches all assets in Holding, up to `uint32` individual assets (different instances of non-fungibles are separate assets).
/// @param params Parameters for the all-counted variant.
/// @return A `WildAsset` with the `AllOfCounted` variant and the encoded parameters in the payload.
function allCounted(
    AllCountedParams memory params
) pure returns (WildAsset memory) {
    return
        WildAsset({
            variant: WildAssetVariant.AllCounted,
            payload: abi.encodePacked(Compact.encode(params.count))
        });
}

/// @notice Creates a `WildAsset` struct representing the `AllOfCounted` variant, which matches all assets in Holding of a given fungibility and ID up to `count` individual assets (different instances of non-fungibles are separate assets).
/// @param id The `AssetId` struct specifying the asset class to match against.
/// @param fun The `WildFungibility` struct specifying the fungibility to match against.
/// @param count The limit of assets  against.
/// @return A `WildAsset` with the `AllOfCounted` variant and the encoded parameters in the payload.
function allOfCounted(
    AssetId memory id,
    WildFungibility fun,
    uint32 count
) pure returns (WildAsset memory) {
    return
        WildAsset({
            variant: WildAssetVariant.AllOfCounted,
            payload: abi.encodePacked(
                AssetIdCodec.encode(id),
                WildFungibilityCodec.encode(fun),
                Compact.encode(count)
            )
        });
}
