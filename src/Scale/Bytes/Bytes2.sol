// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title Scale Codec for the `bytes2` type.
/// @notice SCALE-compliant encoder/decoder for the `bytes2` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Bytes2 {
    error InvalidBytes2Lenght();

    /// @notice Encodes an `bytes2` into SCALE format.
    /// @param value The `bytes2` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bytes2 value) internal pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    /// @notice Returns the number of bytes that a `bytes2` would occupy when SCALE-encoded.
	/// @param data The byte sequence containing the encoded `bytes2`.
	/// @param offset The starting index in `data` from which to calculate the encoded size of the `bytes2`.
	/// @return The number of bytes that the `bytes2` would occupy when SCALE-encoded.
    function encodedSizeAt(bytes memory data, uint256 offset) internal pure returns (uint256) {
        if (data.length < offset + 2) {
            revert InvalidBytes2Lenght();
        }
        return 2;
    }


    /// @notice Decodes SCALE-encoded bytes into an `bytes2`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `bytes2`.
    function decode(bytes memory data) internal pure returns (bytes2) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `bytes2` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `bytes2`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (bytes2 value) {
        if (data.length < offset + 2) {
            revert InvalidBytes2Lenght();
        }
        assembly {
            value := mload(add(add(data, 32), offset))
        }
    }
}
