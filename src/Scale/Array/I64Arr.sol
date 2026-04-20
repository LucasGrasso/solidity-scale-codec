// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../Compact/Compact.sol";
import {I64} from "../Signed/I64.sol";

/// @title Scale Codec for the `int64[]` type.
/// @notice SCALE-compliant encoder/decoder for the `int64[]` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library I64Arr {
    error InvalidI64ArrLength();

    using I64 for int64;

    /// @notice Encodes an `int64[]` into SCALE format.
    /// @param arr The array of `int64` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int64[] memory arr) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; ++i) {
            result = bytes.concat(result, arr[i].encode());
        }
        return result;
    }

    /// @notice Returns the number of bytes that a `int64[]` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `int64[]`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `int64[]`.
    /// @return The number of bytes that the `int64[]` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        (uint256 count, uint256 prefixSize) = Compact.decodeAt(data, offset);
        uint256 totalSize = prefixSize + (count * 8);
        if (offset + totalSize > data.length) revert InvalidI64ArrLength();
        return totalSize;
    }

    /// @notice Decodes an `int64[]` from SCALE format.
    /// @param data The SCALE-encoded byte sequence.
    /// @return arr The decoded array of `int64`.
    /// @return bytesRead The total number of bytes read during decoding.
    function decode(
        bytes memory data
    ) internal pure returns (int64[] memory arr, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `int64[]` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return arr The decoded array of `int64`.
    /// @return bytesRead The total number of bytes read during decoding.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int64[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        if (pos + (length * 8) > data.length) revert InvalidI64ArrLength();

        arr = new int64[](length);
        for (uint256 i = 0; i < length; ++i) {
            arr[i] = I64.decodeAt(data, pos);
            pos += 8;
        }

        bytesRead = pos - offset;
    }
}
