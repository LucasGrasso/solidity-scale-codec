// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {Bytes4} from "../../../Scale/Bytes/Bytes4.sol";
import {Bytes8} from "../../../Scale/Bytes/Bytes8.sol";
import {Bytes16} from "../../../Scale/Bytes/Bytes16.sol";
import {Bytes32} from "../../../Scale/Bytes/Bytes32.sol";
import {AssetInstance, AssetInstanceVariant} from "./AssetInstance.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `AssetInstance`
/// @notice SCALE-compliant encoder/decoder for the `AssetInstance` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library AssetInstanceCodec {
    error InvalidAssetInstanceLength();
    error InvalidAssetInstanceVariant(uint8 variant);

    /// @notice Encodes an `AssetInstance` struct into bytes.
    /// @param assetInstance The `AssetInstance` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `AssetInstance`.
    function encode(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(assetInstance.variant, assetInstance.payload);
    }

    /// @notice Returns the total number of bytes that an `AssetInstance` would occupy when encoded, based on the type and payload.
    /// @param data The byte sequence containing the encoded `AssetInstance`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The total number of bytes that the `AssetInstance` occupies in its encoded form, including the type byte and payload.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) {
            revert InvalidAssetInstanceLength();
        }
        uint8 variant = uint8(data[offset]);
        uint256 payloadLength;
        if (variant == uint8(AssetInstanceVariant.Index)) {
            payloadLength = Compact.encodedSizeAt(data, offset + 1);
        } else if (variant == uint8(AssetInstanceVariant.Array4)) {
            payloadLength = 4;
        } else if (variant == uint8(AssetInstanceVariant.Array8)) {
            payloadLength = 8;
        } else if (variant == uint8(AssetInstanceVariant.Array16)) {
            payloadLength = 16;
        } else if (variant == uint8(AssetInstanceVariant.Array32)) {
            payloadLength = 32;
        } else if (variant == uint8(AssetInstanceVariant.Undefined)) {
            payloadLength = 0;
        } else {
            revert InvalidAssetInstanceVariant(variant);
        }

        if (data.length < offset + 1 + payloadLength) {
            revert InvalidAssetInstanceLength();
        }

        return 1 + payloadLength;
    }

    /// @notice Decodes an `AssetInstance` struct from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `AssetInstance`.
    /// @return assetInstance The decoded `AssetInstance` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `AssetInstance`.
    function decode(
        bytes memory data
    )
        internal
        pure
        returns (AssetInstance memory assetInstance, uint256 bytesRead)
    {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `AssetInstance` struct from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `AssetInstance`.
    /// @param offset The starting index in `data` from which to decode the `AssetInstance`.
    /// @return assetInstance The decoded `AssetInstance` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `AssetInstance`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    )
        internal
        pure
        returns (AssetInstance memory assetInstance, uint256 bytesRead)
    {
        if (data.length < offset + 1) {
            revert InvalidAssetInstanceLength();
        }
        uint8 variant = uint8(data[offset]);
        if (variant > uint8(type(AssetInstanceVariant).max) + 1) {
            revert InvalidAssetInstanceVariant(variant);
        }
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // subtract 1 byte for the variant
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);

        assetInstance = AssetInstance({
            variant: AssetInstanceVariant(variant),
            payload: payload
        });
        bytesRead = 1 + payloadLength;
    }

    /// @notice Extracts the index value from an `Index` asset instance. Reverts if the asset instance is not of type `Index` or if the decoded index exceeds the maximum value for `uint128`.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Index`.
    /// @return idx The index value extracted from the asset instance.
    function asIndex(
        AssetInstance memory assetInstance
    ) internal pure returns (uint128 idx) {
        _assertVariant(assetInstance, AssetInstanceVariant.Index);
        (uint256 decodedIndex, ) = Compact.decode(assetInstance.payload);
        idx = UnsignedUtils.toU128(decodedIndex);
    }

    /// @notice Extracts the 4-byte data from an `Array4` asset instance. Reverts if the asset instance is not of type `Array4`.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Array4`.
    /// @return data The 4-byte data extracted from the asset instance.
    function asArray4(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes4 data) {
        _assertVariant(assetInstance, AssetInstanceVariant.Array4);
        return Bytes4.decode(assetInstance.payload);
    }

    /// @notice Extracts the 8-byte data from an `Array8` asset instance. Reverts if the asset instance is not of type `Array8`.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Array8`.
    /// @return data The 8-byte data extracted from the asset instance.
    function asArray8(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes8 data) {
        _assertVariant(assetInstance, AssetInstanceVariant.Array8);
        return Bytes8.decode(assetInstance.payload);
    }

    /// @notice Extracts the 16-byte data from an `Array16` asset instance. Reverts if the asset instance is not of type `Array16`.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Array16`.
    /// @return data The 16-byte data extracted from the asset instance.
    function asArray16(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes16 data) {
        _assertVariant(assetInstance, AssetInstanceVariant.Array16);
        return Bytes16.decode(assetInstance.payload);
    }

    /// @notice Extracts the 32-byte data from an `Array32` asset instance. Reverts if the asset instance is not of type `Array32`.
    /// @param assetInstance The `AssetInstance` struct to decode, which must have type `Array32`.
    /// @return data The 32-byte data extracted from the asset instance.
    function asArray32(
        AssetInstance memory assetInstance
    ) internal pure returns (bytes32 data) {
        _assertVariant(assetInstance, AssetInstanceVariant.Array32);
        return Bytes32.decode(assetInstance.payload);
    }

    function _assertVariant(
        AssetInstance memory assetInstance,
        AssetInstanceVariant expected
    ) private pure {
        if (assetInstance.variant != expected) {
            revert InvalidAssetInstanceVariant(uint8(assetInstance.variant));
        }
    }
}
