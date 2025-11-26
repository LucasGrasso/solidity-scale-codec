// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/// @title Endianness
/// @notice Gas-optimized library for converting unsigned integers from big-endian to little-endian
/// @author Lucas Grasso
library Endianness {
    /// @notice Converts a uint8 to little-endian bytes1
    /// @dev Identity operation - single byte has no endianness
    /// @param value The big-endian uint8 value
    /// @return The little-endian bytes1 representation
    function toLittleEndian8(uint8 value) internal pure returns (bytes1) {
        return bytes1(value);
    }

    /// @notice Converts a uint16 to little-endian bytes2
    /// @dev Swaps the two bytes: 0xAABB → 0xBBAA
    /// @param value The big-endian uint16 value
    /// @return The little-endian bytes2 representation
    function toLittleEndian16(uint16 value) internal pure returns (bytes2) {
        return bytes2(uint16((value >> 8) | (value << 8)));
    }

    /// @notice Converts a uint32 to little-endian bytes4
    /// @dev Reverses 4 bytes using bitwise operations
    /// @param value The big-endian uint32 value
    /// @return result The little-endian bytes4 representation
    function toLittleEndian32(
        uint32 value
    ) internal pure returns (bytes4 result) {
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

    /// @notice Converts a uint64 to little-endian bytes8
    /// @dev Uses parallel swap algorithm: swap bytes, then 2-byte pairs, then 4-byte halves
    /// @param value The big-endian uint64 value
    /// @return result The little-endian bytes8 representation
    function toLittleEndian64(
        uint64 value
    ) internal pure returns (bytes8 result) {
        assembly {
            let v := value
            // Swap bytes pairwise
            v := or(
                shl(8, and(v, 0x00FF00FF00FF00FF)),
                shr(8, and(v, 0xFF00FF00FF00FF00))
            )
            // Swap 2-byte pairs
            v := or(
                shl(16, and(v, 0x0000FFFF0000FFFF)),
                shr(16, and(v, 0xFFFF0000FFFF0000))
            )
            // Swap 4-byte halves
            v := or(shl(32, v), shr(32, v))
            result := shl(192, v) // Shift to bytes8 position
        }
    }

    /// @notice Converts a uint128 to little-endian bytes16
    /// @dev Extends parallel swap to 128 bits with 4 swap stages
    /// @param value The big-endian uint128 value
    /// @return result The little-endian bytes16 representation
    function toLittleEndian128(
        uint128 value
    ) internal pure returns (bytes16 result) {
        assembly {
            let v := value
            // Byte swap using parallel operations
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

    /// @notice Converts a uint256 to little-endian bytes32
    /// @dev Full 256-bit parallel swap with 5 stages
    /// @param value The big-endian uint256 value
    /// @return result The little-endian bytes32 representation
    function toLittleEndian256(
        uint256 value
    ) internal pure returns (bytes32 result) {
        assembly {
            let v := value
            // Parallel byte swap for 256 bits
            v := or(
                shl(
                    8,
                    and(
                        v,
                        0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF
                    )
                ),
                shr(
                    8,
                    and(
                        v,
                        0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
                    )
                )
            )
            v := or(
                shl(
                    16,
                    and(
                        v,
                        0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
                    )
                ),
                shr(
                    16,
                    and(
                        v,
                        0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000
                    )
                )
            )
            v := or(
                shl(
                    32,
                    and(
                        v,
                        0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF
                    )
                ),
                shr(
                    32,
                    and(
                        v,
                        0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000
                    )
                )
            )
            v := or(
                shl(
                    64,
                    and(
                        v,
                        0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF
                    )
                ),
                shr(
                    64,
                    and(
                        v,
                        0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000
                    )
                )
            )
            v := or(shl(128, v), shr(128, v))
            result := v
        }
    }
}
