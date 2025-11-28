// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "../LittleEndian/LittleEndian.sol";
import {BytesConverter} from "../BytesConverter/BytesConverter.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder/decoder for fixed-width integers.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
library ScaleCodec {
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
        bytes1 b = BytesConverter.toBytes1(data);
        return b != 0x00;
    }

    // ============ Unsigned Integers ============

    /// @notice Encodes a uint8 into SCALE format (1-byte little-endian).
    /// @param value The unsigned 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU8(uint8 value) internal pure returns (bytes memory) {
        bytes1 b = LittleEndian.toLittleEndianU8(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into a uint8.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint8.
    function decodeU8(bytes memory data) internal pure returns (uint8) {
        bytes1 b = BytesConverter.toBytes1(data);
        return LittleEndian.fromLittleEndianU8(b);
    }

    /// @notice Encodes a uint16 into SCALE format (2-byte little-endian).
    /// @param value The unsigned 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU16(uint16 value) internal pure returns (bytes memory) {
        bytes2 b = LittleEndian.toLittleEndianU16(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into a uint16.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint16.
    function decodeU16(bytes memory data) internal pure returns (uint16) {
        bytes2 b = BytesConverter.toBytes2(data);
        return LittleEndian.fromLittleEndianU16(b);
    }

    /// @notice Encodes a uint32 into SCALE format (4-byte little-endian).
    /// @param value The unsigned 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU32(uint32 value) internal pure returns (bytes memory) {
        bytes4 b = LittleEndian.toLittleEndianU32(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into a uint32.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint32.
    function decodeU32(bytes memory data) internal pure returns (uint32) {
        bytes4 b = BytesConverter.toBytes4(data);
        return LittleEndian.fromLittleEndianU32(b);
    }

    /// @notice Encodes a uint64 into SCALE format (8-byte little-endian).
    /// @param value The unsigned 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU64(uint64 value) internal pure returns (bytes memory) {
        bytes8 b = LittleEndian.toLittleEndianU64(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into a uint64.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint64.
    function decodeU64(bytes memory data) internal pure returns (uint64) {
        bytes8 b = BytesConverter.toBytes8(data);
        return LittleEndian.fromLittleEndianU64(b);
    }

    /// @notice Encodes a uint128 into SCALE format (16-byte little-endian).
    /// @param value The unsigned 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU128(uint128 value) internal pure returns (bytes memory) {
        bytes16 b = LittleEndian.toLittleEndianU128(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into a uint128.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint128.
    function decodeU128(bytes memory data) internal pure returns (uint128) {
        bytes16 b = BytesConverter.toBytes16(data);
        return LittleEndian.fromLittleEndianU128(b);
    }

    /// @notice Encodes a uint256 into SCALE format (32-byte little-endian).
    /// @param value The unsigned 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeU256(uint256 value) internal pure returns (bytes memory) {
        bytes32 b = LittleEndian.toLittleEndianU256(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into a uint256.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded uint256.
    function decodeU256(bytes memory data) internal pure returns (uint256) {
        bytes32 b = BytesConverter.toBytes32(data);
        return LittleEndian.fromLittleEndianU256(b);
    }

    // ============ Signed Integers ============

    /// @notice Encodes an int8 into SCALE format (1-byte two's-complement little-endian).
    /// @param value The signed 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI8(int8 value) internal pure returns (bytes memory) {
        bytes1 b = LittleEndian.toLittleEndianI8(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into an int8.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int8.
    function decodeI8(bytes memory data) internal pure returns (int8) {
        bytes1 b = BytesConverter.toBytes1(data);
        return LittleEndian.fromLittleEndianI8(b);
    }

    /// @notice Encodes an int16 into SCALE format (2-byte two's-complement little-endian).
    /// @param value The signed 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI16(int16 value) internal pure returns (bytes memory) {
        bytes2 b = LittleEndian.toLittleEndianI16(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into an int16.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int16.
    function decodeI16(bytes memory data) internal pure returns (int16) {
        bytes2 b = BytesConverter.toBytes2(data);
        return LittleEndian.fromLittleEndianI16(b);
    }

    /// @notice Encodes an int32 into SCALE format (4-byte two's-complement little-endian).
    /// @param value The signed 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI32(int32 value) internal pure returns (bytes memory) {
        bytes4 b = LittleEndian.toLittleEndianI32(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into an int32.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int32.
    function decodeI32(bytes memory data) internal pure returns (int32) {
        bytes4 b = BytesConverter.toBytes4(data);
        return LittleEndian.fromLittleEndianI32(b);
    }

    /// @notice Encodes an int64 into SCALE format (8-byte two's-complement little-endian).
    /// @param value The signed 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI64(int64 value) internal pure returns (bytes memory) {
        bytes8 b = LittleEndian.toLittleEndianI64(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into an int64.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int64.
    function decodeI64(bytes memory data) internal pure returns (int64) {
        bytes8 b = BytesConverter.toBytes8(data);
        return LittleEndian.fromLittleEndianI64(b);
    }

    /// @notice Encodes an int128 into SCALE format (16-byte two's-complement little-endian).
    /// @param value The signed 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI128(int128 value) internal pure returns (bytes memory) {
        bytes16 b = LittleEndian.toLittleEndianI128(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into an int128.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int128.
    function decodeI128(bytes memory data) internal pure returns (int128) {
        bytes16 b = BytesConverter.toBytes16(data);
        return LittleEndian.fromLittleEndianI128(b);
    }

    /// @notice Encodes an int256 into SCALE format (32-byte two's-complement little-endian).
    /// @param value The signed 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encodeI256(int256 value) internal pure returns (bytes memory) {
        bytes32 b = LittleEndian.toLittleEndianI256(value);
        return abi.encodePacked(b);
    }

    /// @notice Decodes SCALE-encoded bytes into an int256.
    /// @param data The SCALE-encoded byte sequence.
    /// @return The decoded int256.
    function decodeI256(bytes memory data) internal pure returns (int256) {
        bytes32 b = BytesConverter.toBytes32(data);
        return LittleEndian.fromLittleEndianI256(b);
    }
}
