// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title Scale Codec for the `bytes16` type.
/// @notice SCALE-compliant encoder/decoder for the `bytes16` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Bytes16 {
    error InvalidBytes16Lenght();

    /// @notice Encodes an `bytes16` into SCALE format.
    /// @param value The `bytes16` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bytes16 value) internal pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    /// @notice Returns the number of bytes that a `bytes16` struct would occupy when SCALE-encoded.
	/// @param data The byte sequence containing the encoded `bytes16`.
	/// @param offset The starting index in `data` from which to calculate the encoded size of the `bytes16`.
	/// @return The number of bytes that the `bytes16` struct would occupy when SCALE-encoded.
    function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256) {
        if (data.length < offset + 16) {
            revert InvalidBytes16Lenght();
        }
        return 16;
    }


    /// @notice Decodes SCALE-encoded bytes into an `bytes16`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `bytes16`.
    function decode(bytes memory data) internal pure returns (bytes16) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `bytes16` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `bytes16`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (bytes16 value) {
        if (data.length < offset + 16) {
            revert InvalidBytes16Lenght();
        }
        assembly {
            value := mload(add(add(data, 32), offset))
        }
    }
}
