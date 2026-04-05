// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../Compact/Compact.sol";
import {I8} from "../Signed.sol";

/// @title Scale Codec for the `int8[]` type.
/// @notice SCALE-compliant encoder/decoder for the `int8[]` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I8Arr {
    error InvalidI8ArrLength();

    using I8 for int8;

    /// @notice Encodes an `int8[]` into SCALE format.
    /// @param arr The array of `int8` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int8[] memory arr) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; ++i) {
            result = bytes.concat(result, arr[i].encode());
        }
        return result;
    }

    /// @notice Returns the number of bytes that a `int8[]` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `int8[]`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `int8[]`.
    /// @return The number of bytes that the `int8[]` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        (uint256 count, uint256 prefixSize) = Compact.decodeAt(data, offset);
        uint256 totalSize = prefixSize + (count * 1);
        if (offset + totalSize > data.length) revert InvalidI8ArrLength();
        return totalSize;
    }

    /// @notice Decodes an `int8[]` from SCALE format.
    /// @param data The SCALE-encoded byte sequence.
    /// @return arr The decoded array of `int8`.
    /// @return bytesRead The total number of bytes read during decoding.
    function decode(
        bytes memory data
    ) internal pure returns (int8[] memory arr, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int8[]` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return arr The decoded array of `int8`.
    /// @return bytesRead The total number of bytes read during decoding.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int8[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        if (pos + (length * 1) > data.length) revert InvalidI8ArrLength();

        arr = new int8[](length);
        for (uint256 i = 0; i < length; ++i) {
            arr[i] = I8.decodeAt(data, pos);
            pos += 1;
        }

        bytesRead = pos - offset;
    }
}
