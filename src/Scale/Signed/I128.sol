// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {U128} from "../Unsigned/U128.sol";

/// @title Scale Codec for the `int128` type.
/// @notice SCALE-compliant encoder/decoder for the `int128` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I128 {
    error OffsetOutOfBounds();

    /// @notice Encodes an `int128` into SCALE format (16-byte two's-complement little-endian).
    /// @param value The signed 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int128 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Returns the number of bytes that a `int128` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `int128`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `int128`.
    /// @return The number of bytes that the `int128` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        return U128.encodedSizeAt(data, offset);
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
        // Safety Check is done in the unsigned decoder.
        return int128(U128.decodeAt(data, offset));
    }

    /// @notice Converts an int128 to little-endian bytes16 (two's complement)
    /// @param value The signed 128-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
    function toLittleEndian(
        int128 value
    ) internal pure returns (bytes16 result) {
        return U128.toLittleEndian(uint128(value));
    }
}
