// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title Scale Codec for the `bytes32` type.
/// @notice SCALE-compliant encoder/decoder for the `bytes32` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Bytes32 {
    error InvalidBytes32Length();

    /// @notice Encodes an `bytes32` into SCALE format.
    /// @param value The `bytes32` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bytes32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    /// @notice Returns the number of bytes that a `bytes32` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `bytes32`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `bytes32`.
    /// @return The number of bytes that the `bytes32` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 32) {
            revert InvalidBytes32Length();
        }
        return 32;
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
            revert InvalidBytes32Length();
        }
        assembly {
            value := mload(add(add(data, 32), offset))
        }
    }
}
