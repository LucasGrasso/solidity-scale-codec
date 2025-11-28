// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/// @title Scale Codec for the `uint64` type.
/// @notice SCALE-compliant encoder/decoder for the `uint64` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U64 {
	error InvalidU64Length();

	/// @notice Encodes an `uint64` into SCALE format (8-byte little-endian).
    /// @param value The unsigned {{bitsize}} integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint64 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
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
        assembly { let ptr := add(add(data, 32), offset) value := 0 for { let i := 0 } lt(i, 8) { i := add(i, 1) } { let b := and(mload(add(ptr, i)), 0xFF) value := or(value, shl(mul(i, 8), b)) } }
    }

	/// @notice Converts an `uint64` to little-endian bytes8
	function toLittleEndian(uint64 value) internal pure returns (bytes8 result) {
		assembly { let v := value v := or(shl(8, and(v, 0x00FF00FF00FF00FF)), shr(8, and(v, 0xFF00FF00FF00FF00))) v := or(shl(16, and(v, 0x0000FFFF0000FFFF)), shr(16, and(v, 0xFFFF0000FFFF0000))) v := or(shl(32, v), shr(32, v)) result := shl(192, v) }
	}
}