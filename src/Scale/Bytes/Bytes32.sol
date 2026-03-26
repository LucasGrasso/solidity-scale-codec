// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title Scale Codec for the `bytes32` type.
/// @notice SCALE-compliant encoder/decoder for the `bytes32` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Bytes32 {
    error InvalidBytes32Lenght();

    /// @notice Encodes an `bytes32` into SCALE format (20-byte little-endian).
    /// @param value The `bytes32` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bytes32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    /// @notice Decodes SCALE-encoded bytes into an `bytes32`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `bytes32`.
    function decode(bytes memory data) internal pure returns (bytes32) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `bytes32` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `bytes32`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (bytes32 value) {
        if (data.length < offset + 32) {
            revert InvalidBytes32Lenght();
        }
        for (uint256 i = 0; i < 32; i++) {
            value[i] = data[offset + i];
        }
    }
}
