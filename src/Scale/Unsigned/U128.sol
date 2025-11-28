// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/// @title Scale Codec for the `uint128` type.
/// @notice SCALE-compliant encoder/decoder for the `uint128` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U128 {
	error InvalidU128Length();

	/// @notice Encodes an `uint128` into SCALE format (16-byte little-endian).
    /// @param value The unsigned 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint128 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an `uint128`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `uint128`.
    function decode(bytes memory data) internal pure returns (uint128) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `uint128` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `uint128`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint128 value) {
        if (data.length < offset + 16) revert InvalidU128Length();
        assembly { let ptr := add(add(data, 32), offset) value := 0 for { let i := 0 } lt(i, 16) { i := add(i, 1) } { let b := and(mload(add(ptr, i)), 0xFF) value := or(value, shl(mul(i, 8), b)) } }
    }

	/// @notice Converts an `uint128` to little-endian bytes16
	function toLittleEndian(uint128 value) internal pure returns (bytes16 result) {
		assembly { let v := value v := or(shl(8, and(v, 0x00FF00FF00FF00FF00FF00FF00FF00FF)), shr(8, and(v, 0xFF00FF00FF00FF00FF00FF00FF00FF00))) v := or(shl(16, and(v, 0x0000FFFF0000FFFF0000FFFF0000FFFF)), shr(16, and(v, 0xFFFF0000FFFF0000FFFF0000FFFF0000))) v := or(shl(32, and(v, 0x00000000FFFFFFFF00000000FFFFFFFF)), shr(32, and(v, 0xFFFFFFFF00000000FFFFFFFF00000000))) v := or(shl(64, v), shr(64, v)) result := shl(128, v) }
	}
}