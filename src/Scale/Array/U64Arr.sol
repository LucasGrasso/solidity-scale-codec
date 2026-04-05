// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../Compact/Compact.sol";
import {U64} from "../Unsigned.sol";

/// @title Scale Codec for the `uint64[]` type.
/// @notice SCALE-compliant encoder/decoder for the `uint64[]` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library U64Arr {
    error InvalidU64ArrLength();

    using U64 for uint64;

    /// @notice Encodes an `uint64[]` into SCALE format.
    /// @param arr The array of `uint64` to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint64[] memory arr) internal pure returns (bytes memory) {
        bytes memory result = Compact.encode(arr.length);
        for (uint256 i = 0; i < arr.length; ++i) {
            result = bytes.concat(result, arr[i].encode());
        }
        return result;
    }

    /// @notice Returns the number of bytes that a `uint64[]` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `uint64[]`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `uint64[]`.
    /// @return The number of bytes that the `uint64[]` would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        (uint256 count, uint256 prefixSize) = Compact.decodeAt(data, offset);
        uint256 totalSize = prefixSize + (count * 8);
        if (offset + totalSize > data.length) revert InvalidU64ArrLength();
        return totalSize;
    }

    /// @notice Decodes an `uint64[]` from SCALE format.
    /// @param data The SCALE-encoded byte sequence.
    /// @return arr The decoded array of `uint64`.
    /// @return bytesRead The total number of bytes read during decoding.
    function decode(
        bytes memory data
    ) internal pure returns (uint64[] memory arr, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `uint64[]` from SCALE format at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return arr The decoded array of `uint64`.
    /// @return bytesRead The total number of bytes read during decoding.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint64[] memory arr, uint256 bytesRead) {
        (uint256 length, uint256 compactBytes) = Compact.decodeAt(data, offset);
        uint256 pos = offset + compactBytes;

        if (pos + (length * 8) > data.length) revert InvalidU64ArrLength();

        arr = new uint64[](length);
        for (uint256 i = 0; i < length; ++i) {
            arr[i] = U64.decodeAt(data, pos);
            pos += 8;
        }

        bytesRead = pos - offset;
    }
}
