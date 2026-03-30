// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import { U256 } from "../Unsigned/U256.sol";

/// @title Scale Codec for the `int256` type.
/// @notice SCALE-compliant encoder/decoder for the `int256` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I256 {
    error OffsetOutOfBounds();

	/// @notice Encodes an `int256` into SCALE format (32-byte two's-complement little-endian).
    /// @param value The signed 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int256 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Returns the number of bytes that a `int256` would occupy when SCALE-encoded.
	/// @param data The byte sequence containing the encoded `int256`.
	/// @param offset The starting index in `data` from which to calculate the encoded size of the `int256`.
	/// @return The number of bytes that the `int256` would occupy when SCALE-encoded.
    function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256) {
        return U256.encodedSizeAt(data, offset);
    }

    /// @notice Decodes SCALE-encoded bytes into an `int256`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `int256`.
    function decode(bytes memory data) internal pure returns (int256) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int256` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `int256`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int256 value) {
        // Safety Check is done in the unsigned decoder.
        return int256(U256.decodeAt(data, offset));
    }

	/// @notice Converts an int256 to little-endian bytes32 (two's complement)
    /// @param value The signed 256-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
    function toLittleEndian(int256 value) internal pure returns (bytes32 result) {
        return U256.toLittleEndian(uint256(value));
    }
}