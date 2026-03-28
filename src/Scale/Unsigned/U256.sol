// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { LittleEndianU256 } from "../../LittleEndian/LittleEndianU256.sol";

/// @title Scale Codec for the `uint256` type.
/// @notice SCALE-compliant encoder/decoder for the `uint256` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U256 {
	error InvalidU256Length();

	/// @notice Encodes an `uint256` into SCALE format (32-byte little-endian).
    /// @param value The unsigned 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint256 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Returns the number of bytes that a `uint256` struct would occupy when SCALE-encoded.
	/// @param data The byte sequence containing the encoded `uint256`.
	/// @param offset The starting index in `data` from which to calculate the encoded size of the `uint256`.
	/// @return The number of bytes that the `uint256` struct would occupy when SCALE-encoded.
    function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256) {
        if (data.length < offset + 32) {
            revert InvalidU256Length();
        }
        return 32;
    }

    /// @notice Decodes SCALE-encoded bytes into an `uint256`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `uint256`.
    function decode(bytes memory data) internal pure returns (uint256) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `uint256` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `uint256`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256 value) {
        if (data.length < offset + 32) revert InvalidU256Length();
        return LittleEndianU256.fromLE(data, offset);
    }

	/// @notice Converts an `uint256` to little-endian bytes32
    /// @param value The unsigned 256-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
	function toLittleEndian(uint256 value) internal pure returns (bytes32 result) {
		return LittleEndianU256.toLE(value);
	}
}