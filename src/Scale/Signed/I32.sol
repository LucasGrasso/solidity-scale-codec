// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { U32 } from "../Unsigned/U32.sol";

/// @title Scale Codec for the `int32` type.
/// @notice SCALE-compliant encoder/decoder for the `int32` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I32 {
    error OffsetOutOfBounds();

	/// @notice Encodes an `int32` into SCALE format (4-byte two's-complement little-endian).
    /// @param value The signed 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Returns the number of bytes that a `int32` would occupy when SCALE-encoded.
	/// @param data The byte sequence containing the encoded `int32`.
	/// @param offset The starting index in `data` from which to calculate the encoded size of the `int32`.
	/// @return The number of bytes that the `int32` would occupy when SCALE-encoded.
    function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256) {
        return U32.encodedSizeAt(data, offset);
    }

    /// @notice Decodes SCALE-encoded bytes into an `int32`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `int32`.
    function decode(bytes memory data) internal pure returns (int32) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int32` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `int32`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int32 value) {
        // Safety Check is done in the unsigned decoder.
        return int32(U32.decodeAt(data, offset));
    }

	/// @notice Converts an int32 to little-endian bytes4 (two's complement)
    /// @param value The signed 32-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
    function toLittleEndian(int32 value) internal pure returns (bytes4 result) {
        return U32.toLittleEndian(uint32(value));
    }
}