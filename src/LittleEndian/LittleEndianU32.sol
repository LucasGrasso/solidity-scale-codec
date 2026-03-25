// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title LittleEndianU32
/// @notice Gas-optimized library for converting U32 from big-endian to little-endian
library LittleEndianU32 {
    /// @notice Converts a `uint32` to little-endian `bytes4`
    /// @param value The `uint32` value to convert
    /// @return result The little-endian representation of the input `uint32` as a `bytes4`
    function toLE(uint32 value) internal pure returns (bytes4 result) {
        assembly {
            let v := or(
                or(
                    shl(24, and(value, 0xff)),
                    shl(16, and(shr(8, value), 0xff))
                ),
                or(shl(8, and(shr(16, value), 0xff)), and(shr(24, value), 0xff))
            )
            result := shl(224, v) // Shift to bytes4 position (left-align in 256-bit word)
        }
    }

    /// @notice Reads a uint32 from `data` at `offset` (little-endian, 4 bytes).
    /// @param data   Raw byte buffer.
    /// @param offset Byte offset into `data`.
    /// @return value Decoded uint32.
    function fromLE(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint32 value) {
        assembly {
            let ptr := add(add(data, 32), offset)
            for {
                let i := 0
            } lt(i, 4) {
                i := add(i, 1)
            } {
                value := or(value, shl(mul(i, 8), shr(248, mload(add(ptr, i)))))
            }
        }
    }
}
