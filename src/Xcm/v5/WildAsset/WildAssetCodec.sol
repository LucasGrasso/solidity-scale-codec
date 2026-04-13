// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {AssetIdCodec} from "../AssetId/AssetIdCodec.sol";
import {WildFungibilityCodec} from "../WildFungibility/WildFungibilityCodec.sol";
import {
    WildAsset,
    WildAssetVariant,
    AllOfParams,
    AllCountedParams,
    AllOfCountedParams
} from "./WildAsset.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `WildAsset`
/// @notice SCALE-compliant encoder/decoder for the `WildAsset` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library WildAssetCodec {
    error InvalidWildAssetLength();
    error InvalidWildAssetVariant(uint8 variant);
    error InvalidWildAssetPayload();

    /// @notice Encodes a `WildAsset` struct into bytes.
    /// @param wildAsset The `WildAsset` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `WildAsset`.
    function encode(
        WildAsset memory wildAsset
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(wildAsset.variant), wildAsset.payload);
    }

    /// @notice Returns the number of bytes that a `WildAsset` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `WildAsset`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `WildAsset`.
    /// @return The number of bytes that the `WildAsset` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (!(offset < data.length)) {
            revert InvalidWildAssetLength();
        }
        uint8 variant = uint8(data[offset]);
        if (variant > uint8(WildAssetVariant.AllOfCounted)) {
            revert InvalidWildAssetVariant(variant);
        }
        uint256 payloadLength;
        if (variant == uint8(WildAssetVariant.All)) {
            payloadLength = 0;
        } else if (variant == uint8(WildAssetVariant.AllOf)) {
            uint256 idSize = AssetIdCodec.encodedSizeAt(data, offset + 1);
            payloadLength =
                idSize +
                WildFungibilityCodec.encodedSizeAt(data, offset + 1 + idSize);
        } else if (variant == uint8(WildAssetVariant.AllCounted)) {
            payloadLength = Compact.encodedSizeAt(data, offset + 1);
        } else if (variant == uint8(WildAssetVariant.AllOfCounted)) {
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
            revert InvalidWildAssetVariant(variant);
        }
        return 1 + payloadLength; // 1 byte for the variant
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
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // subtract 1 byte for the variant
        uint8 variant = uint8(data[offset]);
        wildAsset.variant = WildAssetVariant(variant);
        wildAsset.payload = BytesUtils.copy(data, offset + 1, payloadLength);
        bytesRead = 1 + payloadLength;
    }

    /// @notice Decodes the parameters of a `WildAsset` with the `AllOf` variant from its payload.
    /// @param wildAsset The `WildAsset` struct. Must have the `AllOf` variant.
    /// @return params An `AllOfParams` struct containing the decoded parameters from the payload.
    function asAllOf(
        WildAsset memory wildAsset
    ) internal pure returns (AllOfParams memory params) {
        _assertVariant(wildAsset, WildAssetVariant.AllOf);
        uint256 bytesRead;
        (params.id, bytesRead) = AssetIdCodec.decode(wildAsset.payload);
        (params.fun, ) = WildFungibilityCodec.decodeAt(
            wildAsset.payload,
            bytesRead
        );
    }

    /// @notice Decodes the parameters of a `WildAsset` with the `AllCounted` variant from its payload.
    /// @param wildAsset The `WildAsset` struct. Must have the `AllCounted` variant.
    /// @return params An `AllCountedParams` struct containing the decoded parameters from the payload, including the count limit.
    function asAllCounted(
        WildAsset memory wildAsset
    ) internal pure returns (AllCountedParams memory params) {
        _assertVariant(wildAsset, WildAssetVariant.AllCounted);
        uint256 decodedCount;
        (decodedCount, ) = Compact.decode(wildAsset.payload);
        params.count = UnsignedUtils.toU32(decodedCount);
    }

    /// @notice Decodes the parameters of a `WildAsset` with the `AllOfCounted` variant from its payload.
    /// @param wildAsset The `WildAsset` struct. Must have the `AllOfCounted` variant.
    /// @return params An `AllOfCountedParams` struct containing the decoded parameters from the payload, including the asset class, fungibility, and count limit.
    function asAllOfCounted(
        WildAsset memory wildAsset
    ) internal pure returns (AllOfCountedParams memory params) {
        _assertVariant(wildAsset, WildAssetVariant.AllOfCounted);
        uint256 offset = 0;
        uint256 bytesRead;
        (params.id, bytesRead) = AssetIdCodec.decodeAt(
            wildAsset.payload,
            offset
        );
        offset += bytesRead;
        (params.fun, bytesRead) = WildFungibilityCodec.decodeAt(
            wildAsset.payload,
            offset
        );
        offset += bytesRead;
        uint256 decodedCount;
        (decodedCount, ) = Compact.decodeAt(wildAsset.payload, offset);
        params.count = UnsignedUtils.toU32(decodedCount);
    }

    function _assertVariant(
        WildAsset memory wildAsset,
        WildAssetVariant expected
    ) private pure {
        if (wildAsset.variant != expected) {
            revert InvalidWildAssetVariant(uint8(wildAsset.variant));
        }
    }
}
