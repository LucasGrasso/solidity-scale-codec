// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title LittleEndianU16
/// @notice Gas-optimized library for converting U16 from big-endian to little-endian
library LittleEndianU16 {
    /// @notice Converts a `uint16` to little-endian `bytes2`
    /// @param value The `uint16` value to convert
    /// @return result The little-endian representation of the input `uint16` as a `bytes2`
    function toLittleEndian(uint16 value) internal pure returns (bytes2) {
        return bytes2(uint16((value >> 8) | (value << 8)));
    }

    /// @notice Reads a uint16 from `data` at `offset` (little-endian, 2 bytes).
    /// @param data   Raw byte buffer.
    /// @param offset Byte offset into `data`.
    /// @return value Decoded uint16.
    function fromLittleEndian(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint16 value) {
        assembly {
            let ptr := add(add(data, 32), offset)
            let b0 := shr(248, mload(ptr))
            let b1 := shr(248, mload(add(ptr, 1)))
            value := or(b0, shl(8, b1))
        }
    }
}
