// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/// @title Scale Codec for the `uint32` type.
/// @notice SCALE-compliant encoder/decoder for the `uint32` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U32 {
	error InvalidU32Length();

	/// @notice Encodes an `uint32` into SCALE format (4-byte little-endian).
    /// @param value The unsigned {{bitsize}} integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
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
        assembly { let ptr := add(add(data, 32), offset) let b0 := and(mload(ptr), 0xFF) let b1 := and(mload(add(ptr, 1)), 0xFF) let b2 := and(mload(add(ptr, 2)), 0xFF) let b3 := and(mload(add(ptr, 3)), 0xFF) value := or(or(b0, shl(8, b1)), or(shl(16, b2), shl(24, b3))) }
    }

	/// @notice Converts an `uint32` to little-endian bytes4
	function toLittleEndian(uint32 value) internal pure returns (bytes4 result) {
		assembly { let v := or(or(shl(24, and(value, 0xff)), shl(16, and(shr(8, value), 0xff))), or(shl(8, and(shr(16, value), 0xff)), and(shr(24, value), 0xff))) result := shl(224, v) }
	}
}