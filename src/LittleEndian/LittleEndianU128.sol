// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title LittleEndianU128
/// @notice Gas-optimized library for converting U128 from big-endian to little-endian
library LittleEndianU128 {
    /// @notice Converts a `uint128` to little-endian `bytes16`
    /// @param value The `uint128` value to convert.
    /// @return result The little-endian representation of the input `uint128` as a `bytes16`.
    function toLE(uint128 value) internal pure returns (bytes16 result) {
        assembly {
            let v := value
            v := or(
                shl(8, and(v, 0x00FF00FF00FF00FF00FF00FF00FF00FF)),
                shr(8, and(v, 0xFF00FF00FF00FF00FF00FF00FF00FF00))
            )
            v := or(
                shl(16, and(v, 0x0000FFFF0000FFFF0000FFFF0000FFFF)),
                shr(16, and(v, 0xFFFF0000FFFF0000FFFF0000FFFF0000))
            )
            v := or(
                shl(32, and(v, 0x00000000FFFFFFFF00000000FFFFFFFF)),
                shr(32, and(v, 0xFFFFFFFF00000000FFFFFFFF00000000))
            )
            v := or(shl(64, v), shr(64, v))
            result := shl(128, v)
        }
    }

    /// @notice Reads a uint128 from `data` at `offset` (little-endian, 16 bytes).
    /// @param data   Raw byte buffer.
    /// @param offset Byte offset into `data`.
    /// @return value Decoded uint128.
    function fromLE(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint128 value) {
        assembly {
            let ptr := add(add(data, 32), offset)
            for {
                let i := 0
            } lt(i, 16) {
                i := add(i, 1)
            } {
                value := or(value, shl(mul(i, 8), shr(248, mload(add(ptr, i)))))
            }
        }
    }
}
