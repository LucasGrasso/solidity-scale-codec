// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title LittleEndianU256
/// @notice Gas-optimized library for converting U256 from big-endian to little-endian
library LittleEndianU256 {
    /// @notice Converts a `uint256` to little-endian `bytes32`
    /// @param value The `uint256` value to convert.
    /// @return result The little-endian representation of the input `uint256` as a `bytes32`.
    function toLittleEndian(
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

    /// @notice Reads a uint256 from `data` at `offset` (little-endian, 32 bytes).
    /// @param data   Raw byte buffer.
    /// @param offset Byte offset into `data`.
    /// @return value Decoded uint256.
    function fromLittleEndian(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256 value) {
        assembly {
            let ptr := add(add(data, 32), offset)
            for {
                let i := 0
            } lt(i, 32) {
                i := add(i, 1)
            } {
                value := or(value, shl(mul(i, 8), shr(248, mload(add(ptr, i)))))
            }
        }
    }
}
