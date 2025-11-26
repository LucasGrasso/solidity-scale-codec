// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {LittleEndian} from "./LittleEndian.sol";

/// @title Scale Codec
/// @notice SCALE-compliant encoder.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/parachain-basics/data-encoding
library ScaleCodec {
    // -------- Booleans --------

    /// @notice Encodes a boolean into SCALE format (1-byte little-endian).
    /// @param self The boolean to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(bool self) internal pure returns (bytes memory) {
        uint8 x = self ? uint8(1) : uint8(0);
        bytes1 b = LittleEndian.toLittleEndianU8(x);
        return abi.encodePacked(b);
    }

    // -------- Unsigned Integers --------

    /// @notice Encodes a uint8 into SCALE format (1-byte little-endian).
    /// @param self The unsigned 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint8 self) internal pure returns (bytes memory) {
        bytes1 b = LittleEndian.toLittleEndianU8(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes a uint16 into SCALE format (2-byte little-endian).
    /// @param self The unsigned 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint16 self) internal pure returns (bytes memory) {
        bytes2 b = LittleEndian.toLittleEndianU16(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes a uint32 into SCALE format (4-byte little-endian).
    /// @param self The unsigned 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint32 self) internal pure returns (bytes memory) {
        bytes4 b = LittleEndian.toLittleEndianU32(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes a uint64 into SCALE format (8-byte little-endian).
    /// @param self The unsigned 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint64 self) internal pure returns (bytes memory) {
        bytes8 b = LittleEndian.toLittleEndianU64(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes a uint128 into SCALE format (16-byte little-endian).
    /// @param self The unsigned 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint128 self) internal pure returns (bytes memory) {
        bytes16 b = LittleEndian.toLittleEndianU128(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes a uint256 into SCALE format (32-byte little-endian).
    /// @param self The unsigned 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(uint256 self) internal pure returns (bytes memory) {
        bytes32 b = LittleEndian.toLittleEndianU256(self);
        return abi.encodePacked(b);
    }

    // -------- Signed Integers --------

    /// @notice Encodes an int8 into SCALE format (1-byte two's-complement little-endian).
    /// @param self The signed 8-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int8 self) internal pure returns (bytes memory) {
        bytes1 b = LittleEndian.toLittleEndianI8(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes an int16 into SCALE format (2-byte two's-complement little-endian).
    /// @param self The signed 16-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int16 self) internal pure returns (bytes memory) {
        bytes2 b = LittleEndian.toLittleEndianI16(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes an int32 into SCALE format (4-byte two's-complement little-endian).
    /// @param self The signed 32-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int32 self) internal pure returns (bytes memory) {
        bytes4 b = LittleEndian.toLittleEndianI32(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes an int64 into SCALE format (8-byte two's-complement little-endian).
    /// @param self The signed 64-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int64 self) internal pure returns (bytes memory) {
        bytes8 b = LittleEndian.toLittleEndianI64(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes an int128 into SCALE format (16-byte two's-complement little-endian).
    /// @param self The signed 128-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int128 self) internal pure returns (bytes memory) {
        bytes16 b = LittleEndian.toLittleEndianI128(self);
        return abi.encodePacked(b);
    }

    /// @notice Encodes an int256 into SCALE format (32-byte two's-complement little-endian).
    /// @param self The signed 256-bit integer to encode.
    /// @return SCALE-encoded byte sequence.
    function encode(int256 self) internal pure returns (bytes memory) {
        bytes32 b = LittleEndian.toLittleEndianI256(self);
        return abi.encodePacked(b);
    }
}
