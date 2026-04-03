// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {U8Arr} from "../../../Scale/Array.sol";
import {MaybeErrorCode, MaybeErrorCodeVariant} from "./MaybeErrorCode.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";

/// @title SCALE Codec for XCM v3 `MaybeErrorCode`
/// @notice SCALE-compliant encoder/decoder for the `MaybeErrorCode` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v3 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v3/index.html
library MaybeErrorCodeCodec {
    error InvalidMaybeErrorCodeLength();
    error InvalidMaybeErrorCodeVariant(uint8 variant);

    /// @notice Encodes a `MaybeErrorCode` struct into SCALE bytes.
    /// @param me The `MaybeErrorCode` struct to encode.
    /// @return SCALE-encoded bytes representing the `MaybeErrorCode`.
    function encode(
        MaybeErrorCode memory me
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(me.variant), me.payload);
    }

    /// @notice Returns the number of bytes that a `MaybeErrorCode` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `MaybeErrorCode`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded `MaybeErrorCode`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidMaybeErrorCodeLength();
        uint8 variant = uint8(data[offset]);
        if (variant == uint8(MaybeErrorCodeVariant.Success)) {
            return 1;
        } else if (
            variant == uint8(MaybeErrorCodeVariant.Error) ||
            variant == uint8(MaybeErrorCodeVariant.TruncatedError)
        ) {
            return 1 + U8Arr.encodedSizeAt(data, offset + 1);
        } else {
            revert InvalidMaybeErrorCodeVariant(variant);
        }
    }

    /// @notice Decodes a `MaybeErrorCode` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded `MaybeErrorCode`.
    /// @return me The decoded `MaybeErrorCode` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    ) internal pure returns (MaybeErrorCode memory me, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `MaybeErrorCode` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `MaybeErrorCode`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return me The decoded `MaybeErrorCode` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (MaybeErrorCode memory me, uint256 bytesRead) {
        if (data.length < offset + 1) revert InvalidMaybeErrorCodeLength();
        uint8 variant = uint8(data[offset]);
        if (variant > uint8(MaybeErrorCodeVariant.TruncatedError))
            revert InvalidMaybeErrorCodeVariant(variant);
        uint256 size = encodedSizeAt(data, offset);
        uint256 payloadLength = size - 1;
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        me = MaybeErrorCode({
            variant: MaybeErrorCodeVariant(variant),
            payload: payload
        });
        bytesRead = size;
    }

    /// @notice Decodes the dispatch error bytes from an `Error` or `TruncatedError` MaybeErrorCode.
    /// @param me The `MaybeErrorCode` struct to decode. Must be of type `Error` or `TruncatedError`.
    /// @return errorBytes The decoded dispatch error bytes.
    function decodeError(
        MaybeErrorCode memory me
    ) internal pure returns (uint8[] memory errorBytes) {
        if (
            me.variant != MaybeErrorCodeVariant.Error &&
            me.variant != MaybeErrorCodeVariant.TruncatedError
        ) revert InvalidMaybeErrorCodeVariant(uint8(me.variant));
        (errorBytes, ) = U8Arr.decode(me.payload);
    }
}
