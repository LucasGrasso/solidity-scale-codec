// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title Scale Codec for the `address` type.
/// @notice SCALE-compliant encoder/decoder for the `address` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Address {
    error InvalidAddressLenght();

    /// @notice Encodes an `address` into SCALE format (20-byte little-endian).
    /// @param value The `address` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(address value) internal pure returns (bytes memory) {
        return abi.encodePacked(value);
    }

    /// @notice Returns the number of bytes that an `address` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `address`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `address`.
    /// @return The number of bytes that the `address` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 20) {
            revert InvalidAddressLenght();
        }
        return 20;
    }

    /// @notice Decodes SCALE-encoded bytes into an `address`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded `address`.
    function decode(bytes memory data) internal pure returns (address) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `address` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return The decoded `address`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (address) {
        if (data.length < offset + 20) {
            revert InvalidAddressLenght();
        }
        bytes memory addrBytes = new bytes(20);
        for (uint256 i = 0; i < 20; i++) {
            addrBytes[i] = data[offset + i];
        }
        return address(bytes20(addrBytes));
    }
}
