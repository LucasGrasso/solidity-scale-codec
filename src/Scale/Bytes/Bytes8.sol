// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title Scale Codec for the `bytes8` type.
/// @notice SCALE-compliant encoder/decoder for the `bytes8` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Bytes8 {
    error InvalidBytes8Lenght();

    /// @notice Encodes an `bytes8` into SCALE format.
    /// @param value The `bytes8` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bytes8 value) internal pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    /// @notice Returns the number of bytes that a `bytes8` struct would occupy when SCALE-encoded.
	/// @param data The byte sequence containing the encoded `bytes8`.
	/// @param offset The starting index in `data` from which to calculate the encoded size of the `bytes8`.
	/// @return The number of bytes that the `bytes8` struct would occupy when SCALE-encoded.
    function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256) {
        if (data.length < offset + 8) {
            revert InvalidBytes8Lenght();
        }
        return 8;
    }


    /// @notice Decodes SCALE-encoded bytes into an `bytes8`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `bytes8`.
    function decode(bytes memory data) internal pure returns (bytes8) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `bytes8` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `bytes8`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (bytes8 value) {
        if (data.length < offset + 8) {
            revert InvalidBytes8Lenght();
        }
        assembly {
            value := mload(add(add(data, 32), offset))
        }
    }
}
