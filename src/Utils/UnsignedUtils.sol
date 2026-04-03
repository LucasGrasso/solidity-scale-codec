// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @notice Utility functions for working with byte arrays, such as copying segments of bytes.
library UnsignedUtils {
    error NumberTooLarge(uint256 value, uint256 max);

    function toU8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert NumberTooLarge(value, type(uint8).max);
        }
        unchecked {
            return uint8(value);
        }
    }

    function toU16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert NumberTooLarge(value, type(uint16).max);
        }
        unchecked {
            return uint16(value);
        }
    }

    function toU32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert NumberTooLarge(value, type(uint32).max);
        }
        unchecked {
            return uint32(value);
        }
    }

    function toU64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert NumberTooLarge(value, type(uint64).max);
        }
        unchecked {
            return uint64(value);
        }
    }

    function toU128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert NumberTooLarge(value, type(uint128).max);
        }
        unchecked {
            return uint128(value);
        }
    }
}
