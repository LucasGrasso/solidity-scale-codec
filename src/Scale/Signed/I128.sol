// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { U128 } from "../Unsigned/U128.sol";

/// @title Scale Codec for the `int128` type.
/// @notice SCALE-compliant encoder/decoder for the `int128` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I128 {
	/// @notice Encodes an `int128` into SCALE format (16-byte two's-complement little-endian).
    /// @param value The signed 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int128 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an `int128`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `int128`.
    function decode(bytes memory data) internal pure returns (int128) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int128` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `int128`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int128 value) {
        return int128(U128.decodeAt(data, offset));
    }

	/// @notice Converts an int128 to little-endian bytes16 (two's complement)
    function toLittleEndian(int128 value) internal pure returns (bytes16 result) {
        return U128.toLittleEndian(uint128(value));
    }
}