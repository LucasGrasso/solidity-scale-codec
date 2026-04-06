// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title Scale Codec for the `bool` type.
/// @notice SCALE-compliant encoder/decoder for `bool`.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Bool {
    error InvalidBoolLength();

    /// @notice Encodes a `bool` into SCALE format (1-byte).
    /// @param value The boolean to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bool value) internal pure returns (bytes memory) {
        return abi.encodePacked(value ? bytes1(0x01) : bytes1(0x00));
    }

    /// @notice Returns the number of bytes that a `bool` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `bool`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `bool`.
    /// @return The number of bytes that the `bool` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidBoolLength();
        return 1;
    }

    /// @notice Decodes SCALE-encoded bytes into a `bool`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded boolean.
    function decode(bytes memory data) internal pure returns (bool) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a boolean at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `bool`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (bool value) {
        if (data.length < offset + 1) revert InvalidBoolLength();
        return data[offset] != 0x00;
    }
}
