// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title Scale Codec for the `bytes4` type.
/// @notice SCALE-compliant encoder/decoder for the `bytes4` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Bytes4 {
    error InvalidBytes4Length();

    /// @notice Encodes an `bytes4` into SCALE format.
    /// @param value The `bytes4` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bytes4 value) internal pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    /// @notice Returns the number of bytes that a `bytes4` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `bytes4`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `bytes4`.
    /// @return The number of bytes that the `bytes4` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 4) {
            revert InvalidBytes4Length();
        }
        return 4;
    }

    /// @notice Decodes SCALE-encoded bytes into an `bytes4`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `bytes4`.
    function decode(bytes memory data) internal pure returns (bytes4) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `bytes4` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `bytes4`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (bytes4 value) {
        if (data.length < offset + 4) {
            revert InvalidBytes4Length();
        }
        assembly {
            value := mload(add(add(data, 32), offset))
        }
    }
}
