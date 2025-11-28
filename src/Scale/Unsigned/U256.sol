// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

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
        assembly { let ptr := add(add(data, 32), offset) value := 0 for { let i := 0 } lt(i, 32) { i := add(i, 1) } { let b := and(mload(add(ptr, i)), 0xFF) value := or(value, shl(mul(i, 8), b)) } }
    }

	/// @notice Converts an `uint256` to little-endian bytes32
	function toLittleEndian(uint256 value) internal pure returns (bytes32 result) {
		assembly { let v := value v := or(shl(8, and(v, 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF)), shr(8, and(v, 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00))) v := or(shl(16, and(v, 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF)), shr(16, and(v, 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000))) v := or(shl(32, and(v, 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF)), shr(32, and(v, 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000))) v := or(shl(64, and(v, 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF)), shr(64, and(v, 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000))) v := or(shl(128, v), shr(128, v)) result := v }
	}
}