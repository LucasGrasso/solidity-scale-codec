// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { U8 } from "../Unsigned/U8.sol";

/// @title Scale Codec for the `int8` type.
/// @notice SCALE-compliant encoder/decoder for the `int8` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I8 {
	/// @notice Encodes an `int8` into SCALE format (1-byte two's-complement little-endian).
    /// @param value The signed 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int8 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an `int8`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `int8`.
    function decode(bytes memory data) internal pure returns (int8) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int8` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `int8`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int8 value) {
        return int8(U8.decodeAt(data, offset));
    }

	/// @notice Converts an int8 to little-endian bytes1 (two's complement)
    function toLittleEndian(int8 value) internal pure returns (bytes1 result) {
        return U8.toLittleEndian(uint8(value));
    }
}