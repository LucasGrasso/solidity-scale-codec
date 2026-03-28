// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { LittleEndianU64 } from "../../LittleEndian/LittleEndianU64.sol";

/// @title Scale Codec for the `uint64` type.
/// @notice SCALE-compliant encoder/decoder for the `uint64` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U64 {
	error InvalidU64Length();

	/// @notice Encodes an `uint64` into SCALE format (8-byte little-endian).
    /// @param value The unsigned 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint64 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Returns the number of bytes that a `uint64` struct would occupy when SCALE-encoded.
	/// @param data The byte sequence containing the encoded `uint64`.
	/// @param offset The starting index in `data` from which to calculate the encoded size of the `uint64`.
	/// @return The number of bytes that the `uint64` struct would occupy when SCALE-encoded.
    function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256) {
        if (data.length < offset + 8) {
            revert InvalidU64Length();
        }
        return 8;
    }

    /// @notice Decodes SCALE-encoded bytes into an `uint64`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `uint64`.
    function decode(bytes memory data) internal pure returns (uint64) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `uint64` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `uint64`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint64 value) {
        if (data.length < offset + 8) revert InvalidU64Length();
        return LittleEndianU64.fromLE(data, offset);
    }

	/// @notice Converts an `uint64` to little-endian bytes8
    /// @param value The unsigned 64-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
	function toLittleEndian(uint64 value) internal pure returns (bytes8 result) {
		return LittleEndianU64.toLE(value);
	}
}