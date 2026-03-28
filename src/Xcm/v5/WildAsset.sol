// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../Scale/Compact.sol";
import {AssetIdCodec, AssetId} from "./AssetId.sol";
import {WildFungibilityCodec, WildFungibility} from "./WildFungibility.sol";

/// @notice Discriminant for the type of asset being specified in a `WildAsset`.
enum WildAssetType {
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

/// @notice Parameters for the `AllCounted` variant of `WildAsset`, specifying a limit of assets to match against.
struct AllCountedParams {
    /// @custom:property The asset class to match against.
    AssetId id;
    /// @custom:property The fungibility to match against.
    WildFungibility fun;
    /// @custom:property The limit of assets to match against.
    uint32 count;
}

/// @notice A wildcard representing a set of assets.
struct WildAsset {
    /// @custom:property The type of wild asset, determining how to interpret the payload. See `WildAssetType` enum for possible values.
    WildAssetType waType;
    /// @custom:property The encoded payload containing the wild asset data, whose structure depends on the `waType`.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `WildAsset`
/// @notice SCALE-compliant encoder/decoder for the `WildAsset` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library WildAssetCodec {
    error InvalidWildAssetLength();
    error InvalidWildAssetType(uint8 waType);
    error InvalidWildAssetPayload();

    /// @notice Creates a `WildAsset` struct representing the `All` variant, which matches all assets in Holding.
    /// @return A `WildAsset` with the `All` variant.
    function all() internal pure returns (WildAsset memory) {
        return WildAsset({waType: WildAssetType.All, payload: ""});
    }

    /// @notice Creates a `WildAsset` struct representing the `AllOf` variant, which matches all assets in Holding of a given fungibility and ID.
    /// @param id The `AssetId` struct specifying the asset class to match against.
    /// @param fun The `WildFungibility` struct specifying the fungibility to match against.
    /// @return A `WildAsset` with the `AllOf` variant and the encoded parameters in the payload.
    function allOf(
        AssetId memory id,
        WildFungibility fun
    ) internal pure returns (WildAsset memory) {
        return
            WildAsset({
                waType: WildAssetType.AllOf,
                payload: abi.encodePacked(
                    AssetIdCodec.encode(id),
                    WildFungibilityCodec.encode(fun)
                )
            });
    }

    /// @notice Creates a `WildAsset` struct representing the `AllCounted` variant, which matches all assets in Holding, up to `uint32` individual assets (different instances of non-fungibles are separate assets).
    /// @param count The limit of assets  against.
    /// @return A `WildAsset` with the `AllOfCounted` variant and the encoded parameters in the payload.
    function allCounted(uint32 count) internal pure returns (WildAsset memory) {
        return
            WildAsset({
                waType: WildAssetType.AllCounted,
                payload: abi.encodePacked(Compact.encode(count))
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
    ) internal pure returns (WildAsset memory) {
        return
            WildAsset({
                waType: WildAssetType.AllOfCounted,
                payload: abi.encodePacked(
                    AssetIdCodec.encode(id),
                    WildFungibilityCodec.encode(fun),
                    Compact.encode(count)
                )
            });
    }

    /// @notice Encodes a `WildAsset` struct into bytes.
    /// @param wildAsset The `WildAsset` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `WildAsset`.
    function encode(
        WildAsset memory wildAsset
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(wildAsset.waType), wildAsset.payload);
    }

    /// @notice Returns the number of bytes that a `WildAsset` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `WildAsset`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `WildAsset`.
    /// @return The number of bytes that the `WildAsset` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (offset >= data.length) {
            revert InvalidWildAssetLength();
        }
        uint8 waType = uint8(data[offset]);
        if (waType > uint8(WildAssetType.AllOfCounted)) {
            revert InvalidWildAssetType(waType);
        }
        uint256 payloadLength;
        if (waType == uint8(WildAssetType.All)) {
            payloadLength = 0;
        } else if (waType == uint8(WildAssetType.AllOf)) {
            uint256 idSize = AssetIdCodec.encodedSizeAt(data, offset + 1);
            payloadLength =
                idSize +
                WildFungibilityCodec.encodedSizeAt(data, offset + 1 + idSize);
        } else if (waType == uint8(WildAssetType.AllCounted)) {
            payloadLength = Compact.encodedSizeAt(data, offset + 1);
        } else if (waType == uint8(WildAssetType.AllOfCounted)) {
            uint256 idSize = AssetIdCodec.encodedSizeAt(data, offset + 1);
            uint256 funSize = WildFungibilityCodec.encodedSizeAt(
                data,
                offset + 1 + idSize
            );
            payloadLength =
                idSize +
                funSize +
                Compact.encodedSizeAt(data, offset + 1 + idSize + funSize);
        } else {
            revert InvalidWildAssetType(waType);
        }
        return 1 + payloadLength; // 1 byte for the waType
    }

    /// @notice Decodes a `WildAsset` instance from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `WildAsset`.
    /// @return wildAsset The decoded `WildAsset` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `WildAsset`.
    function decode(
        bytes memory data
    ) internal pure returns (WildAsset memory wildAsset, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `WildAsset` instance from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `WildAsset`.
    /// @param offset The starting index in `data` from which to decode the `WildAsset`.
    /// @return wildAsset The decoded `WildAsset` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `WildAsset`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (WildAsset memory wildAsset, uint256 bytesRead) {
        if (offset >= data.length) {
            revert InvalidWildAssetLength();
        }
        uint8 waType = uint8(data[offset]);
        if (waType > uint8(WildAssetType.AllOfCounted)) {
            revert InvalidWildAssetType(waType);
        }
        wildAsset.waType = WildAssetType(waType);
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // subtract 1 byte for the waType
        wildAsset.payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; i++) {
            wildAsset.payload[i] = data[offset + 1 + i];
        }
        bytesRead = 1 + payloadLength;
    }
}
