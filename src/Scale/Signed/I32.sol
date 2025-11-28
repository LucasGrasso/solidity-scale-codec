// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { U32 } from "../Unsigned/U32.sol";

/// @title Scale Codec for the `int32` type.
/// @notice SCALE-compliant encoder/decoder for the `int32` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I32 {
	/// @notice Encodes an `int32` into SCALE format (4-byte two's-complement little-endian).
    /// @param value The signed 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an `int32`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `int32`.
    function decode(bytes memory data) internal pure returns (int32) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int32` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `int32`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int32 value) {
        return int32(U32.decodeAt(data, offset));
    }

	/// @notice Converts an int32 to little-endian bytes4 (two's complement)
    function toLittleEndian(int32 value) internal pure returns (bytes4 result) {
        return U32.toLittleEndian(uint32(value));
    }
}