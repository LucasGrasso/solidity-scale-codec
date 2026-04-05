// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {U16} from "../Unsigned/U16.sol";

/// @title Scale Codec for the `int16` type.
/// @notice SCALE-compliant encoder/decoder for the `int16` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I16 {
    error OffsetOutOfBounds();

    /// @notice Encodes an `int16` into SCALE format (2-byte two's-complement little-endian).
    /// @param value The signed 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int16 value) internal pure returns (bytes memory) {
        return abi.encodePacked(toLittleEndian(value));
    }

    /// @notice Returns the number of bytes that a `int16` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `int16`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `int16`.
    /// @return The number of bytes that the `int16` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        return U16.encodedSizeAt(data, offset);
    }

    /// @notice Decodes SCALE-encoded bytes into an `int16`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `int16`.
    function decode(bytes memory data) internal pure returns (int16) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int16` at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `int16`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int16 value) {
        // Safety Check is done in the unsigned decoder.
        return int16(U16.decodeAt(data, offset));
    }

    /// @notice Converts an int16 to little-endian bytes2 (two's complement)
    /// @param value The signed 16-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
    function toLittleEndian(int16 value) internal pure returns (bytes2 result) {
        return U16.toLittleEndian(uint16(value));
    }
}
