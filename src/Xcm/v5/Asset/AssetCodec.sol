// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetId} from "../AssetId/AssetId.sol";
import {AssetIdCodec} from "../AssetId/AssetIdCodec.sol";
import {Fungibility} from "../Fungibility/Fungibility.sol";
import {FungibilityCodec} from "../Fungibility/FungibilityCodec.sol";
import {Asset} from "./Asset.sol";

/// @title SCALE Codec for XCM v5 `Asset`
/// @notice SCALE-compliant encoder/decoder for the `Asset` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library AssetCodec {
    /// @notice Encodes an `Asset` struct into bytes.
    /// @param asset The `Asset` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `Asset`.
    function encode(Asset memory asset) internal pure returns (bytes memory) {
        bytes memory encodedId = AssetIdCodec.encode(asset.id);
        bytes memory encodedFungibility = FungibilityCodec.encode(
            asset.fungibility
        );
        return abi.encodePacked(encodedId, encodedFungibility);
    }

    /// @notice Returns the number of bytes that an `Asset` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `Asset`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `Asset`.
    /// @return The number of bytes that the `Asset` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        uint256 idSize = AssetIdCodec.encodedSizeAt(data, offset);
        uint256 fungibilitySize = FungibilityCodec.encodedSizeAt(
            data,
            offset + idSize
        );
        return idSize + fungibilitySize;
    }

    /// @notice Decodes an `Asset` struct from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `Asset`.
    /// @return asset The decoded `Asset` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `Asset`.
    function decode(
        bytes memory data
    ) internal pure returns (Asset memory asset, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `Asset` struct from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `Asset`.
    /// @param offset The starting index in `data` from which to decode the `Asset`.
    /// @return asset The decoded `Asset` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `Asset`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (Asset memory asset, uint256 bytesRead) {
        (AssetId memory id, uint256 idBytesRead) = AssetIdCodec.decodeAt(
            data,
            offset
        );
        (
            Fungibility memory fungibility,
            uint256 fungibilityBytesRead
        ) = FungibilityCodec.decodeAt(data, offset + idBytesRead);
        asset = Asset({id: id, fungibility: fungibility});
        bytesRead = idBytesRead + fungibilityBytesRead;
    }
}
