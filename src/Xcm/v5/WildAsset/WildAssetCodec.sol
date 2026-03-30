// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {AssetIdCodec} from "../AssetId/AssetIdCodec.sol";
import {WildFungibilityCodec} from "../WildFungibility/WildFungibilityCodec.sol";
import {AssetId} from "../AssetId/AssetId.sol";
import {WildFungibility} from "../WildFungibility/WildFungibility.sol";
import {
    WildAsset,
    WildAssetType,
    AllOfParams,
    AllOfCountedParams
} from "./WildAsset.sol";

/// @title SCALE Codec for XCM v5 `WildAsset`
/// @notice SCALE-compliant encoder/decoder for the `WildAsset` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library WildAssetCodec {
    error InvalidWildAssetLength();
    error InvalidWildAssetType(uint8 waType);
    error InvalidWildAssetPayload();

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

    /// @notice Decodes the parameters of a `WildAsset` with the `AllOf` variant from its payload.
    /// @param wildAsset The `WildAsset` struct. Must have the `AllOf` variant.
    /// @return params An `AllOfParams` struct containing the decoded parameters from the payload.
    function asAllOf(
        WildAsset memory wildAsset
    ) internal pure returns (AllOfParams memory params) {
        if (wildAsset.waType != WildAssetType.AllOf) {
            revert InvalidWildAssetType(uint8(wildAsset.waType));
        }
        uint256 bytesRead;
        (params.id, bytesRead) = AssetIdCodec.decode(wildAsset.payload);
        (params.fun, ) = WildFungibilityCodec.decodeAt(
            wildAsset.payload,
            bytesRead
        );
    }

    /// @notice Decodes the parameters of a `WildAsset` with the `AllCounted` variant from its payload.
    /// @param wildAsset The `WildAsset` struct. Must have the `AllCounted` variant.
    /// @return count The `count` parameter decoded from the payload, representing the limit of assets to match against.
    function asAllCounted(
        WildAsset memory wildAsset
    ) internal pure returns (uint32 count) {
        if (wildAsset.waType != WildAssetType.AllCounted) {
            revert InvalidWildAssetType(uint8(wildAsset.waType));
        }
        uint256 decodedCount;
        (decodedCount, ) = Compact.decode(wildAsset.payload);
        count = uint32(decodedCount);
    }

    /// @notice Decodes the parameters of a `WildAsset` with the `AllOfCounted` variant from its payload.
    /// @param wildAsset The `WildAsset` struct. Must have the `AllOfCounted` variant.
    /// @return params An `AllOfCountedParams` struct containing the decoded parameters from the payload, including the asset class, fungibility, and count limit.
    function asAllOfCounted(
        WildAsset memory wildAsset
    ) internal pure returns (AllOfCountedParams memory params) {
        if (wildAsset.waType != WildAssetType.AllOfCounted) {
            revert InvalidWildAssetType(uint8(wildAsset.waType));
        }
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
        params.count = uint32(decodedCount);
    }
}
