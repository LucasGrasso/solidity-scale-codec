// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Assets} from "../Assets/Assets.sol";
import {AssetsCodec} from "../Assets/AssetsCodec.sol";
import {WildAssetCodec, WildAsset} from "../WildAsset.sol";
import {AssetFilter, AssetFilterType} from "./AssetFilter.sol";

/// @title SCALE Codec for XCM v5 `AssetFilter`
/// @notice SCALE-compliant encoder/decoder for the `AssetFilter` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library AssetFilterCodec {
    error InvalidAssetFilterLength();
    error InvalidAssetFilterType(uint8 afType);
    error InvalidAssetFilterPayload();

    /// @notice Encodes an `AssetFilter` struct into a SCALE-compliant byte array.
    /// @param assetFilter The `AssetFilter` struct to encode.
    /// @return A byte array containing the SCALE-encoded representation of the `AssetFilter`.
    function encode(
        AssetFilter memory assetFilter
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(assetFilter.afType), assetFilter.payload);
    }

    /// @notice Returns the number of bytes that a `AssetFilter` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `AssetFilter`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `AssetFilter`.
    /// @return The number of bytes that the `AssetFilter` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) {
            revert InvalidAssetFilterLength();
        }
        uint8 afType = uint8(data[offset]);
        if (afType == uint8(AssetFilterType.Definite)) {
            return 1 + AssetsCodec.encodedSizeAt(data, offset + 1);
        } else if (afType == uint8(AssetFilterType.Wild)) {
            return 1 + WildAssetCodec.encodedSizeAt(data, offset + 1);
        } else {
            revert InvalidAssetFilterType(afType);
        }
    }

    /// @notice Decodes an `AssetFilter` struct from a SCALE-encoded byte array starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `AssetFilter`.
    /// @return assetFilter The decoded `AssetFilter` struct.
    function decode(
        bytes memory data
    ) internal pure returns (AssetFilter memory) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `AssetFilter` struct from a SCALE-encoded byte array starting at a given offset.
    /// @param data The byte sequence containing the encoded `AssetFilter`.
    /// @param offset The starting index in `data` from which to decode the `AssetFilter`.
    /// @return assetFilter The decoded `AssetFilter` struct.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (AssetFilter memory assetFilter) {
        if (data.length < offset + 1) {
            revert InvalidAssetFilterLength();
        }
        uint8 afType = uint8(data[offset]);
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // Subtract 1 byte for the afType
        if (data.length < offset + 1 + payloadLength) {
            revert InvalidAssetFilterLength();
        }
        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; i++) {
            payload[i] = data[offset + 1 + i];
        }
        assetFilter.afType = AssetFilterType(afType);
        assetFilter.payload = payload;
    }

    /// @notice Extracs the inner `Assets` collection. Reverts if the `AssetFilter` is not of the `Definite` variant.
    /// @param assetFilter The `AssetFilter` struct to decode, which must have the `Definite` variant.
    /// @return assets The `Assets` collection contained within the `AssetFilter` if it is of the `Definite` variant.
    function asDefinite(
        AssetFilter memory assetFilter
    ) internal pure returns (Assets memory assets) {
        if (assetFilter.afType != AssetFilterType.Definite) {
            revert InvalidAssetFilterPayload();
        }
        (assets, ) = AssetsCodec.decode(assetFilter.payload);
    }

    /// @notice Extracts the inner `WildAsset` wildcard. Reverts if the `AssetFilter` is not of the `Wild` variant.
    /// @param assetFilter The `AssetFilter` struct to decode, which must have the `Wild` variant.
    /// @return wA The `WildAsset` wildcard contained within the `AssetFilter` if it is of the `Wild` variant.
    function asWild(
        AssetFilter memory assetFilter
    ) internal pure returns (WildAsset memory wA) {
        if (assetFilter.afType != AssetFilterType.Wild) {
            revert InvalidAssetFilterPayload();
        }
        (wA, ) = WildAssetCodec.decode(assetFilter.payload);
    }
}
