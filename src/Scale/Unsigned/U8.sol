// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { LittleEndianU8 } from "../../LittleEndian/LittleEndianU8.sol";

/// @title Scale Codec for the `uint8` type.
/// @notice SCALE-compliant encoder/decoder for the `uint8` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U8 {
	error InvalidU8Length();

	/// @notice Encodes an `uint8` into SCALE format (1-byte little-endian).
    /// @param value The unsigned 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint8 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an `uint8`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `uint8`.
    function decode(bytes memory data) internal pure returns (uint8) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `uint8` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `uint8`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint8 value) {
        if (data.length < offset + 1) revert InvalidU8Length();
        return LittleEndianU8.fromLE(data, offset);
    }

	/// @notice Converts an `uint8` to little-endian bytes1
    /// @param value The unsigned 8-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
	function toLittleEndian(uint8 value) internal pure returns (bytes1 result) {
		return LittleEndianU8.toLE(value);
	}
}