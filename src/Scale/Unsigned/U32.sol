// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { LittleEndianU32 } from "../../LittleEndian/LittleEndianU32.sol";

/// @title Scale Codec for the `uint32` type.
/// @notice SCALE-compliant encoder/decoder for the `uint32` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U32 {
	error InvalidU32Length();

	/// @notice Encodes an `uint32` into SCALE format (4-byte little-endian).
    /// @param value The unsigned 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Returns the number of bytes that a `uint32` would occupy when SCALE-encoded.
	/// @param data The byte sequence containing the encoded `uint32`.
	/// @param offset The starting index in `data` from which to calculate the encoded size of the `uint32`.
	/// @return The number of bytes that the `uint32` would occupy when SCALE-encoded.
    function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256) {
        if (data.length < offset + 4) {
            revert InvalidU32Length();
        }
        return 4;
    }

    /// @notice Decodes SCALE-encoded bytes into an `uint32`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `uint32`.
    function decode(bytes memory data) internal pure returns (uint32) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `uint32` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `uint32`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint32 value) {
        if (data.length < offset + 4) revert InvalidU32Length();
        return LittleEndianU32.fromLE(data, offset);
    }

	/// @notice Converts an `uint32` to little-endian bytes4
    /// @param value The unsigned 32-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
	function toLittleEndian(uint32 value) internal pure returns (bytes4 result) {
		return LittleEndianU32.toLE(value);
	}
}