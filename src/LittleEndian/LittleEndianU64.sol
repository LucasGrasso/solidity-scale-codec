// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title LittleEndianU64
/// @notice Gas-optimized library for converting U64 from big-endian to little-endian
library LittleEndianU64 {
    /// @notice Converts a `uint64` to little-endian `bytes8`
    /// @param value The `uint64` value to convert.
    /// @return result The little-endian representation of the input `uint64` as a `bytes8`.
    function toLE(uint64 value) internal pure returns (bytes8 result) {
        assembly {
            let v := value
            v := or(
                shl(8, and(v, 0x00FF00FF00FF00FF)),
                shr(8, and(v, 0xFF00FF00FF00FF00))
            )
            v := or(
                shl(16, and(v, 0x0000FFFF0000FFFF)),
                shr(16, and(v, 0xFFFF0000FFFF0000))
            )
            v := or(shl(32, v), shr(32, v))
            result := shl(192, v)
        }
    }

    /// @notice Reads a uint64 from `data` at `offset` (little-endian, 8 bytes).
    /// @param data   Raw byte buffer.
    /// @param offset Byte offset into `data`.
    /// @return value Decoded uint64.
    function fromLE(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint64 value) {
        assembly {
            let ptr := add(add(data, 32), offset)
            for {
                let i := 0
            } lt(i, 8) {
                i := add(i, 1)
            } {
                value := or(value, shl(mul(i, 8), shr(248, mload(add(ptr, i)))))
            }
        }
    }
}
