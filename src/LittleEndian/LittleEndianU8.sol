// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title LittleEndianU8
/// @notice Gas-optimized library for converting U8 from big-endian to little-endian
library LittleEndianU8 {
    /// @notice Converts a `uint8` to little-endian `bytes1`
    /// @param value The `uint8` value to convert.
    /// @return result The little-endian representation of the input `uint8` as a `bytes1`.
    function toLE(uint8 value) internal pure returns (bytes1) {
        return bytes1(value);
    }

    /// @notice Reads a uint8 from `data` at `offset`.
    /// @param data   Raw byte buffer.
    /// @param offset Byte offset into `data`.
    /// @return value Decoded uint8.
    function fromLE(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint8 value) {
        assembly {
            value := shr(248, mload(add(add(data, 32), offset)))
        }
    }
}
