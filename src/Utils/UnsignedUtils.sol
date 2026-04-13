// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @title UnsignedUtils
/// @notice Utility functions for safely downcasting `uint256` values to smaller unsigned integer types.
library UnsignedUtils {
    error NumberTooLarge(uint256 value, uint256 max);

    /// @notice Safely downcasts a `uint256` to `uint8`, reverting if the value exceeds `uint8`'s maximum.
    /// @param value The `uint256` value to downcast.
    /// @return The downcasted `uint8` value.
    function toU8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert NumberTooLarge(value, type(uint8).max);
        }
        unchecked {
            return uint8(value);
        }
    }

    /// @notice Safely downcasts a `uint256` to `uint16`, reverting if the value exceeds `uint16`'s maximum.
    /// @param value The `uint256` value to downcast.
    /// @return The downcasted `uint16` value.
    function toU16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert NumberTooLarge(value, type(uint16).max);
        }
        unchecked {
            return uint16(value);
        }
    }

    /// @notice Safely downcasts a `uint256` to `uint32`, reverting if the value exceeds `uint32`'s maximum.
    /// @param value The `uint256` value to downcast.
    /// @return The downcasted `uint32` value.
    function toU32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert NumberTooLarge(value, type(uint32).max);
        }
        unchecked {
            return uint32(value);
        }
    }

    /// @notice Safely downcasts a `uint256` to `uint64`, reverting if the value exceeds `uint64`'s maximum.
    /// @param value The `uint256` value to downcast.
    /// @return The downcasted `uint64` value.
    function toU64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert NumberTooLarge(value, type(uint64).max);
        }
        unchecked {
            return uint64(value);
        }
    }

    /// @notice Safely downcasts a `uint256` to `uint128`, reverting if the value exceeds `uint128`'s maximum.
    /// @param value The `uint256` value to downcast.
    /// @return The downcasted `uint128` value.
    function toU128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert NumberTooLarge(value, type(uint128).max);
        }
        unchecked {
            return uint128(value);
        }
    }
}
