// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Compact} from "../Compact/Compact.sol";
import {LittleEndian} from "../LittleEndian/LittleEndian.sol";
import {ScaleCodecArrays} from "./ScaleCodecArrays.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder/decoder for fixed-width integers.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library ScaleCodec {
    error InvalidLength();

    // ============ Booleans ============

    /// @notice Encodes a boolean into SCALE format (1-byte).
    /// @param value The boolean to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeBool(bool value) internal pure returns (bytes memory) {
        return abi.encodePacked(value ? bytes1(0x01) : bytes1(0x00));
    }

    /// @notice Decodes SCALE-encoded bytes into a boolean.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded boolean.
    function decodeBool(bytes memory data) internal pure returns (bool) {
        if (data.length < 1) revert InvalidLength();
        return data[0] != 0x00;
    }

    /// @notice Decodes a boolean at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded boolean.
    function decodeBoolAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (bool value) {
        if (data.length < offset + 1) revert InvalidLength();
        assembly {
            value := iszero(
                iszero(and(mload(add(add(data, 32), offset)), 0xFF))
            )
        }
    }

    // ============ Unsigned Integers ============

    /// @notice Encodes a uint8 into SCALE format (1-byte little-endian).
    /// @param value The unsigned 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU8(uint8 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianU8(value));
    }

    /// @notice Decodes SCALE-encoded bytes into a uint8.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint8.
    function decodeU8(bytes memory data) internal pure returns (uint8) {
        if (data.length < 1) revert InvalidLength();
        return uint8(data[0]);
    }

    /// @notice Decodes a uint8 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded uint8.
    function decodeU8At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint8 value) {
        if (data.length < offset + 1) revert InvalidLength();
        assembly {
            value := and(mload(add(add(data, 32), offset)), 0xFF)
        }
    }

    /// @notice Encodes a uint16 into SCALE format (2-byte little-endian).
    /// @param value The unsigned 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU16(uint16 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianU16(value));
    }

    /// @notice Decodes SCALE-encoded bytes into a uint16.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint16.
    function decodeU16(bytes memory data) internal pure returns (uint16) {
        return decodeU16At(data, 0);
    }

    /// @notice Decodes a uint16 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded uint16.
    function decodeU16At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint16 value) {
        if (data.length < offset + 2) revert InvalidLength();
        assembly {
            let ptr := add(add(data, 32), offset)
            let b0 := and(mload(ptr), 0xFF)
            let b1 := and(mload(add(ptr, 1)), 0xFF)
            value := or(b0, shl(8, b1))
        }
    }

    /// @notice Encodes a uint32 into SCALE format (4-byte little-endian).
    /// @param value The unsigned 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU32(uint32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianU32(value));
    }

    /// @notice Decodes SCALE-encoded bytes into a uint32.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint32.
    function decodeU32(bytes memory data) internal pure returns (uint32) {
        return decodeU32At(data, 0);
    }

    /// @notice Decodes a uint32 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded uint32.
    function decodeU32At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint32 value) {
        if (data.length < offset + 4) revert InvalidLength();
        assembly {
            let ptr := add(add(data, 32), offset)
            let b0 := and(mload(ptr), 0xFF)
            let b1 := and(mload(add(ptr, 1)), 0xFF)
            let b2 := and(mload(add(ptr, 2)), 0xFF)
            let b3 := and(mload(add(ptr, 3)), 0xFF)
            value := or(or(b0, shl(8, b1)), or(shl(16, b2), shl(24, b3)))
        }
    }

    /// @notice Encodes a uint64 into SCALE format (8-byte little-endian).
    /// @param value The unsigned 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU64(uint64 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianU64(value));
    }

    /// @notice Decodes SCALE-encoded bytes into a uint64.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint64.
    function decodeU64(bytes memory data) internal pure returns (uint64) {
        return decodeU64At(data, 0);
    }

    /// @notice Decodes a uint64 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded uint64.
    function decodeU64At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint64 value) {
        if (data.length < offset + 8) revert InvalidLength();
        assembly {
            let ptr := add(add(data, 32), offset)
            value := 0
            for {
                let i := 0
            } lt(i, 8) {
                i := add(i, 1)
            } {
                let b := and(mload(add(ptr, i)), 0xFF)
                value := or(value, shl(mul(i, 8), b))
            }
        }
    }

    /// @notice Encodes a uint128 into SCALE format (16-byte little-endian).
    /// @param value The unsigned 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU128(uint128 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianU128(value));
    }

    /// @notice Decodes SCALE-encoded bytes into a uint128.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint128.
    function decodeU128(bytes memory data) internal pure returns (uint128) {
        return decodeU128At(data, 0);
    }

    /// @notice Decodes a uint128 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded uint128.
    function decodeU128At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint128 value) {
        if (data.length < offset + 16) revert InvalidLength();
        assembly {
            let ptr := add(add(data, 32), offset)
            value := 0
            for {
                let i := 0
            } lt(i, 16) {
                i := add(i, 1)
            } {
                let b := and(mload(add(ptr, i)), 0xFF)
                value := or(value, shl(mul(i, 8), b))
            }
        }
    }

    /// @notice Encodes a uint256 into SCALE format (32-byte little-endian).
    /// @param value The unsigned 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU256(uint256 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianU256(value));
    }

    /// @notice Decodes SCALE-encoded bytes into a uint256.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint256.
    function decodeU256(bytes memory data) internal pure returns (uint256) {
        return decodeU256At(data, 0);
    }

    /// @notice Decodes a uint256 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded uint256.
    function decodeU256At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256 value) {
        if (data.length < offset + 32) revert InvalidLength();
        assembly {
            let ptr := add(add(data, 32), offset)
            value := 0
            for {
                let i := 0
            } lt(i, 32) {
                i := add(i, 1)
            } {
                let b := and(mload(add(ptr, i)), 0xFF)
                value := or(value, shl(mul(i, 8), b))
            }
        }
    }

    // ============ Signed Integers ============

    /// @notice Encodes an int8 into SCALE format (1-byte two's-complement little-endian).
    /// @param value The signed 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI8(int8 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianI8(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an int8.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int8.
    function decodeI8(bytes memory data) internal pure returns (int8) {
        if (data.length < 1) revert InvalidLength();
        return int8(uint8(data[0]));
    }

    /// @notice Decodes an int8 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded int8.
    function decodeI8At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int8 value) {
        if (data.length < offset + 1) revert InvalidLength();
        assembly {
            value := and(mload(add(add(data, 32), offset)), 0xFF)
        }
    }

    /// @notice Encodes an int16 into SCALE format (2-byte two's-complement little-endian).
    /// @param value The signed 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI16(int16 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianI16(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an int16.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int16.
    function decodeI16(bytes memory data) internal pure returns (int16) {
        return int16(decodeU16(data));
    }

    /// @notice Decodes an int16 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded int16.
    function decodeI16At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int16 value) {
        return int16(decodeU16At(data, offset));
    }

    /// @notice Encodes an int32 into SCALE format (4-byte two's-complement little-endian).
    /// @param value The signed 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI32(int32 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianI32(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an int32.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int32.
    function decodeI32(bytes memory data) internal pure returns (int32) {
        return int32(decodeU32(data));
    }

    /// @notice Decodes an int32 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded int32.
    function decodeI32At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int32 value) {
        return int32(decodeU32At(data, offset));
    }

    /// @notice Encodes an int64 into SCALE format (8-byte two's-complement little-endian).
    /// @param value The signed 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI64(int64 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianI64(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an int64.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int64.
    function decodeI64(bytes memory data) internal pure returns (int64) {
        return int64(decodeU64(data));
    }

    /// @notice Decodes an int64 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded int64.
    function decodeI64At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int64 value) {
        return int64(decodeU64At(data, offset));
    }

    /// @notice Encodes an int128 into SCALE format (16-byte two's-complement little-endian).
    /// @param value The signed 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI128(int128 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianI128(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an int128.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int128.
    function decodeI128(bytes memory data) internal pure returns (int128) {
        return int128(decodeU128(data));
    }

    /// @notice Decodes an int128 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded int128.
    function decodeI128At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int128 value) {
        return int128(decodeU128At(data, offset));
    }

    /// @notice Encodes an int256 into SCALE format (32-byte two's-complement little-endian).
    /// @param value The signed 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI256(int256 value) internal pure returns (bytes memory) {
        return abi.encodePacked(LittleEndian.toLittleEndianI256(value));
    }

    /// @notice Decodes SCALE-encoded bytes into an int256.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int256.
    function decodeI256(bytes memory data) internal pure returns (int256) {
        return int256(decodeU256(data));
    }

    /// @notice Decodes an int256 at the specified offset.
    /// @param data The SCALE-encoded byte sequence.
    /// @param offset The byte offset to start decoding from.
    /// @return value The decoded int256.
    function decodeI256At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (int256 value) {
        return int256(decodeU256At(data, offset));
    }
}
