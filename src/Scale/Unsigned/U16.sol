// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { LittleEndianU16 } from "../../LittleEndian/LittleEndianU16.sol";

/// @title Scale Codec for the `uint16` type.
/// @notice SCALE-compliant encoder/decoder for the `uint16` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U16 {
	error InvalidU16Length();

	/// @notice Encodes an `uint16` into SCALE format (2-byte little-endian).
    /// @param value The unsigned 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint16 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an `uint16`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `uint16`.
    function decode(bytes memory data) internal pure returns (uint16) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `uint16` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `uint16`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint16 value) {
        if (data.length < offset + 2) revert InvalidU16Length();
        return LittleEndianU16.fromLE(data, offset);
    }

	/// @notice Converts an `uint16` to little-endian bytes2
    /// @param value The unsigned 16-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
	function toLittleEndian(uint16 value) internal pure returns (bytes2 result) {
		return LittleEndianU16.toLE(value);
	}
}