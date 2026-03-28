// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetCodec, Asset} from "./Asset.sol";

/// @notice An array of Assets.
/// @dev There are a number of invariants which the construction and mutation functions must ensure are maintained:
/// 	 - It may contain no items of duplicate asset class;
///	     - All items must be ordered;
////     - The number of items should grow no larger than 20 (constant `MAX_ITEMS_IN_ASSETS`).
struct Assets {
    /// @custom:property The items of the array.
    Asset[] items;
}

/// @title SCALE Codec for XCM v5 `Assets`
/// @notice SCALE-compliant encoder/decoder for the `Assets` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library AssetsCodec {
    /// @notice Encodes an `Assets` struct into bytes.
    /// @param assets The `Assets` struct to encode. Asumes that the `items` array is properly constructed according to the invariants specified in the `Assets` struct definition.
    /// @return SCALE-encoded byte sequence representing the `Assets`.
    function encode(Assets memory assets) internal pure returns (bytes memory) {
        bytes memory encoded = abi.encodePacked(uint8(assets.items.length));
        for (uint256 i = 0; i < assets.items.length; i++) {
            encoded = abi.encodePacked(
                encoded,
                AssetCodec.encode(assets.items[i])
            );
        }
        return encoded;
    }

    /// @notice Returns the number of bytes that an `Assets` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `Assets`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `Assets`.
    /// @return The number of bytes that the `Assets` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) {
            revert("Invalid Assets length");
        }
        uint8 length = uint8(data[offset]);
        uint256 currentOffset = offset + 1;
        for (uint256 i = 0; i < length; i++) {
            currentOffset += AssetCodec.encodedSizeAt(data, currentOffset);
        }
        return currentOffset - offset;
    }

    /// @notice Decodes an `Assets` struct from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `Assets`.
    /// @return assets The decoded `Assets` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `Assets`.
    function decode(
        bytes memory data
    ) internal pure returns (Assets memory assets, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `Assets` struct from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `Assets`.
    /// @param offset The starting index in `data` from which to decode the `Assets`.
    /// @return assets The decoded `Assets` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `Assets`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (Assets memory assets, uint256 bytesRead) {
        if (data.length < offset + 1) {
            revert("Invalid Assets length");
        }
        uint8 length = uint8(data[offset]);
        Asset[] memory items = new Asset[](length);
        uint256 currentOffset = offset + 1;
        for (uint256 i = 0; i < length; i++) {
            (Asset memory asset, uint256 assetBytesRead) = AssetCodec.decodeAt(
                data,
                currentOffset
            );
            items[i] = asset;
            currentOffset += assetBytesRead;
        }
        assets = Assets({items: items});
        bytesRead = 1 + currentOffset - offset - 1;
    }
}
