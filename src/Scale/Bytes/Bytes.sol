// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../Scale/Compact.sol";

/// @title Scale Codec for the `bytes` type.
/// @notice SCALE-compliant encoder/decoder for the `bytes` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library Bytes {
    error InvalidBytesLength();

    /// @notice Encodes an `bytes` into SCALE format.
    /// @param value The `bytes` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bytes memory value) internal pure returns (bytes memory) {
        return abi.encodePacked(Compact.encode(value.length), value);
    }

    /// @notice Returns the number of bytes that a `bytes` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `bytes`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `bytes`.
    /// @return The number of bytes that the `bytes` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        (uint256 length, uint256 lengthBytes) = Compact.decodeAt(data, offset);
        if (data.length < offset + lengthBytes + length) {
            revert InvalidBytesLength();
        }
        return lengthBytes + length;
    }

    /// @notice Decodes SCALE-encoded bytes into an `bytes`.
    /// @param data The SCALE-encoded byte sequence.
    /// @return value The decoded `bytes`.
    /// @return bytesRead The number of bytes read from the input.
    function decode(
        bytes memory data
    ) internal pure returns (bytes memory value, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `bytes` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded `bytes`.
    /// @return bytesRead The number of bytes read from the input.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (bytes memory value, uint256 bytesRead) {
        (uint256 length, uint256 lengthBytes) = Compact.decodeAt(data, offset);
        if (data.length < offset + lengthBytes + length) {
            revert InvalidBytesLength();
        }
        value = new bytes(length);
        bytesRead = lengthBytes + length;
        for (uint256 i = 0; i < length; i++) {
            value[i] = data[offset + lengthBytes + i];
        }
    }
}
