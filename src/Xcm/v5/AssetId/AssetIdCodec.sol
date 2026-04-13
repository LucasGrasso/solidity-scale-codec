// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Location} from "../Location/Location.sol";
import {LocationCodec} from "../Location/LocationCodec.sol";
import {AssetId} from "./AssetId.sol";

/// @title SCALE Codec for XCM v5 `AssetId`
/// @notice SCALE-compliant encoder/decoder for the `AssetId` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library AssetIdCodec {
    /// @notice Encodes an `AssetId` struct into bytes.
    /// @param assetId The `AssetId` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `AssetId`.
    function encode(
        AssetId memory assetId
    ) internal pure returns (bytes memory) {
        return LocationCodec.encode(assetId.location);
    }

    /// @notice Returns the number of bytes that an `AssetId` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `AssetId`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `AssetId`.
    /// @return The number of bytes that the `AssetId` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        return LocationCodec.encodedSizeAt(data, offset);
    }

    /// @notice Decodes an `AssetId` struct from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `AssetId`.
    /// @return assetId The decoded `AssetId` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `AssetId`.
    function decode(
        bytes memory data
    ) internal pure returns (AssetId memory assetId, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `AssetId` struct from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `AssetId`.
    /// @param offset The starting index in `data` from which to decode the `AssetId`.
    /// @return assetId The decoded `AssetId` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `AssetId`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (AssetId memory assetId, uint256 bytesRead) {
        (Location memory location, uint256 locationBytesRead) = LocationCodec
            .decodeAt(data, offset);
        assetId = AssetId({location: location});
        bytesRead = locationBytesRead;
    }
}
