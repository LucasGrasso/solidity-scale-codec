// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title BytesUtils
/// @notice Utility functions for working with byte arrays, such as copying segments of bytes.
library BytesUtils {
    error InvalidBounds();

    /// @notice Copies a segment of bytes from a source byte array.
    /// @param src The source byte array from which to copy.
    /// @param from The starting index in the source array from which to begin copying.
    /// @param count The number of bytes to copy from the source array.
    function copy(
        bytes memory src,
        uint256 from,
        uint256 count
    ) internal pure returns (bytes memory) {
        if (src.length < from + count) {
            revert InvalidBounds();
        }
        bytes memory result = new bytes(count);
        for (uint256 i = 0; i < count; ++i) {
            result[i] = src[from + i];
        }
        return result;
    }
}
