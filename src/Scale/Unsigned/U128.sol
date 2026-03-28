// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LittleEndianU128} from "../../LittleEndian/LittleEndianU128.sol";

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

    /// @notice Returns the number of bytes that a `uint128` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `uint128`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `uint128`.
    /// @return The number of bytes that the `uint128` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 16) {
            revert InvalidU128Length();
        }
        return 16;
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
        return LittleEndianU128.fromLittleEndian(data, offset);
    }

    /// @notice Converts an `uint128` to little-endian bytes16
    /// @param value The unsigned 128-bit integer to convert.
    /// @return result Little-endian byte representation of the input value.
    function toLittleEndian(
        uint128 value
    ) internal pure returns (bytes16 result) {
        return LittleEndianU128.toLittleEndian(value);
    }
}
