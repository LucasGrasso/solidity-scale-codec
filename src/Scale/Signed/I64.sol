// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { U64 } from "../Unsigned/U64.sol";

/// @title Scale Codec for the `int64` type.
/// @notice SCALE-compliant encoder/decoder for the `int64` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I64 {
    error OffsetOutOfBounds();

	/// @notice Encodes an `int64` into SCALE format (8-byte two's-complement little-endian).
    /// @param value The signed 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int64 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Returns the number of bytes that a `int64` struct would occupy when SCALE-encoded.
	/// @param data The byte sequence containing the encoded `int64`.
	/// @param offset The starting index in `data` from which to calculate the encoded size of the `int64`.
	/// @return The number of bytes that the `int64` struct would occupy when SCALE-encoded.
    function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256) {
        return U64.encodedSizeAt(data, offset);
    }

    /// @notice Decodes SCALE-encoded bytes into an `int64`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `int64`.
    function decode(bytes memory data) internal pure returns (int64) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int64` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `int64`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int64 value) {
        // Safety Check is done in the unsigned decoder.
        return int64(U64.decodeAt(data, offset));
    }

	/// @notice Converts an int64 to little-endian bytes8 (two's complement)
    /// @param value The signed 64-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
    function toLittleEndian(int64 value) internal pure returns (bytes8 result) {
        return U64.toLittleEndian(uint64(value));
    }
}