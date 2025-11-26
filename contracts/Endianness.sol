// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

/// @title Endianness
/// @notice Gas-optimized library for converting unsigned integers from big-endian to little-endian
/// @author Lucas Grasso
library Endianness {
    /// @notice Converts a uint8 to little-endian bytes1
    function toLittleEndian8(uint8 value) internal pure returns (bytes1) {
        return bytes1(value);
    }

    /// @notice Converts an int8 to little-endian bytes1 (two's complement)
    function toLittleEndiani8(int8 value) internal pure returns (bytes1) {
        return bytes1(uint8(value));
    }

    /// @notice Converts a uint16 to little-endian bytes2
    function toLittleEndian16(uint16 value) internal pure returns (bytes2) {
        return bytes2(uint16((value >> 8) | (value << 8)));
    }

    /// @notice Converts an int16 to little-endian bytes2 (two's complement)
    function toLittleEndiani16(int16 value) internal pure returns (bytes2) {
        return toLittleEndian16(uint16(value));
    }

    /// @notice Converts a uint32 to little-endian bytes4
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

    /// @notice Converts an int32 to little-endian bytes4 (two's complement)
    function toLittleEndiani32(int32 value) internal pure returns (bytes4) {
        return toLittleEndian32(uint32(value));
    }

    /// @notice Converts a uint64 to little-endian bytes8
    function toLittleEndian64(
        uint64 value
    ) internal pure returns (bytes8 result) {
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

    /// @notice Converts an int64 to little-endian bytes8 (two's complement)
    function toLittleEndiani64(int64 value) internal pure returns (bytes8) {
        return toLittleEndian64(uint64(value));
    }

    /// @notice Converts a uint128 to little-endian bytes16
    function toLittleEndian128(
        uint128 value
    ) internal pure returns (bytes16 result) {
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

    /// @notice Converts an int128 to little-endian bytes16 (two's complement)
    function toLittleEndiani128(int128 value) internal pure returns (bytes16) {
        return toLittleEndian128(uint128(value));
    }

    /// @notice Converts a uint256 to little-endian bytes32
    function toLittleEndian256(
        uint256 value
    ) internal pure returns (bytes32 result) {
        assembly {
            let v := value
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

    /// @notice Converts an int256 to little-endian bytes32 (two's complement)
    function toLittleEndiani256(int256 value) internal pure returns (bytes32) {
        return toLittleEndian256(uint256(value));
    }

    /// @notice Converts little-endian bytes1 to uint8
    function fromLittleEndian8(bytes1 value) internal pure returns (uint8) {
        return uint8(value);
    }

    /// @notice Converts little-endian bytes1 to int8
    function fromLittleEndiani8(bytes1 value) internal pure returns (int8) {
        return int8(uint8(value));
    }

    /// @notice Converts little-endian bytes2 to uint16
    function fromLittleEndian16(bytes2 value) internal pure returns (uint16) {
        return uint16(uint8(value[0])) | (uint16(uint8(value[1])) << 8);
    }

    /// @notice Converts little-endian bytes2 to int16
    function fromLittleEndiani16(bytes2 value) internal pure returns (int16) {
        return int16(fromLittleEndian16(value));
    }

    /// @notice Converts little-endian bytes4 to uint32
    function fromLittleEndian32(
        bytes4 value
    ) internal pure returns (uint32 result) {
        assembly {
            let v := shr(224, value)
            v := or(
                or(shl(24, and(v, 0xff)), shl(16, and(shr(8, v), 0xff))),
                or(shl(8, and(shr(16, v), 0xff)), and(shr(24, v), 0xff))
            )
            result := v
        }
    }

    /// @notice Converts little-endian bytes4 to int32
    function fromLittleEndiani32(bytes4 value) internal pure returns (int32) {
        return int32(fromLittleEndian32(value));
    }

    /// @notice Converts little-endian bytes8 to uint64
    function fromLittleEndian64(
        bytes8 value
    ) internal pure returns (uint64 result) {
        assembly {
            let v := shr(192, value)
            v := or(
                shl(8, and(v, 0x00FF00FF00FF00FF)),
                shr(8, and(v, 0xFF00FF00FF00FF00))
            )
            v := or(
                shl(16, and(v, 0x0000FFFF0000FFFF)),
                shr(16, and(v, 0xFFFF0000FFFF0000))
            )
            v := or(shl(32, v), shr(32, v))
            result := v
        }
    }

    /// @notice Converts little-endian bytes8 to int64
    function fromLittleEndiani64(bytes8 value) internal pure returns (int64) {
        return int64(fromLittleEndian64(value));
    }

    /// @notice Converts little-endian bytes16 to uint128
    function fromLittleEndian128(
        bytes16 value
    ) internal pure returns (uint128 result) {
        assembly {
            let v := shr(128, value)
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
            result := v
        }
    }

    /// @notice Converts little-endian bytes16 to int128
    function fromLittleEndiani128(
        bytes16 value
    ) internal pure returns (int128) {
        return int128(fromLittleEndian128(value));
    }

    /// @notice Converts little-endian bytes32 to uint256
    function fromLittleEndian256(
        bytes32 value
    ) internal pure returns (uint256 result) {
        assembly {
            let v := value
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

    /// @notice Converts little-endian bytes32 to int256
    function fromLittleEndiani256(
        bytes32 value
    ) internal pure returns (int256) {
        return int256(fromLittleEndian256(value));
    }
}
