// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LittleEndianU16} from "../../LittleEndian/LittleEndianU16.sol";
import {LittleEndianU32} from "../../LittleEndian/LittleEndianU32.sol";
import {LittleEndianU256} from "../../LittleEndian/LittleEndianU256.sol";

/// @title Compact
/// @notice SCALE Compact encoding for space-efficient unsigned integer representation
/// @dev Encoding modes based on value range:
///      - 0b00: single-byte mode (0-63), 6 bits of data
///      - 0b01: two-byte mode (64-16383), 14 bits of data
///      - 0b10: four-byte mode (16384-1073741823), 30 bits of data
///      - 0b11: big-integer mode (>1073741823), variable length up to 67 bytes
/// @dev Reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding/#compact-general-integers
library Compact {
    error InvalidCompactEncoding();
    error ValueOutOfRange();
    error NonCanonicalEncoding();
    error OffsetOutOfBounds();

    uint256 internal constant SINGLE_BYTE_BOUND = 64; // 2^6
    uint256 internal constant TWO_BYTE_BOUND = 16384; // 2^14
    uint256 internal constant FOUR_BYTE_BOUND = 1073741824; // 2^30

    uint8 internal constant MODE_SINGLE = 0x00;
    uint8 internal constant MODE_TWO = 0x01;
    uint8 internal constant MODE_FOUR = 0x02;
    uint8 internal constant MODE_BIG = 0x03;

    /// @notice Encodes a uint256 value to SCALE Compact format
    /// @param value The value to encode
    /// @return Compact-encoded bytes in little-endian
    function encode(uint256 value) internal pure returns (bytes memory) {
        if (value < SINGLE_BYTE_BOUND) {
            return _encodeSingleByte(value);
        } else if (value < TWO_BYTE_BOUND) {
            return _encodeTwoByte(value);
        } else if (value < FOUR_BYTE_BOUND) {
            return _encodeFourByte(value);
        } else {
            return _encodeBigInt(value);
        }
    }

    /// @notice Returns the number of bytes that the Compact-encoded value at the given offset occupies
    /// @param data The byte sequence containing the Compact-encoded value
    /// @param offset The byte offset to start reading from
    /// @return size The total number of bytes occupied by the Compact-encoded value, including the header byte
    /// @dev Reverts if the offset is out of bounds or if the header byte indicates an invalid encoding mode
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256 size) {
        if (!(offset < data.length)) revert OffsetOutOfBounds();
        uint8 header;
        assembly {
            header := shr(248, mload(add(add(data, 32), offset)))
        }
        uint8 mode = header & 0x03;
        if (mode == MODE_SINGLE) {
            size = 1;
        } else if (mode == MODE_TWO) {
            size = 2;
        } else if (mode == MODE_FOUR) {
            size = 4;
        } else {
            uint8 m = (header >> 2) + 4;
            size = 1 + m;
        }

        if (data.length < offset + size) revert OffsetOutOfBounds();
    }

    ///@notice Decodes a uint256 value from SCALE Compact format
    /// @dev Reverts if the encoding is invalid or non-canonical, or if the decoded value exceeds uint256 range
    /// @param data The Compact-encoded byte sequence
    /// @return value The decoded uint256 value
    /// @return bytesRead The total number of bytes read during decoding
    function decode(
        bytes memory data
    ) internal pure returns (uint256 value, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a uint256 value from SCALE Compact format
    /// @dev Reverts if the encoding is invalid or non-canonical, or if the decoded value exceeds uint256 range
    /// @param data The Compact-encoded byte sequence
    /// @param offset The byte offset to start decoding from
    /// @return value The decoded uint256 value
    /// @return bytesRead The total number of bytes read during decoding
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256 value, uint256 bytesRead) {
        if (!(offset < data.length)) revert OffsetOutOfBounds();
        uint8 header;
        assembly {
            header := shr(248, mload(add(add(data, 32), offset)))
        }
        uint8 mode = header & 0x03;
        if (mode == MODE_SINGLE) {
            value = uint256(header) >> 2;
            bytesRead = 1;
        } else if (mode == MODE_TWO) {
            if (data.length < offset + 2) revert OffsetOutOfBounds();
            value =
                uint256(LittleEndianU16.fromLittleEndian(data, offset)) >>
                2;
            bytesRead = 2;
        } else if (mode == MODE_FOUR) {
            if (data.length < offset + 4) revert OffsetOutOfBounds();
            value =
                uint256(LittleEndianU32.fromLittleEndian(data, offset)) >>
                2;
            bytesRead = 4;
        } else {
            uint8 m = (header >> 2) + 4;
            if (m > 32) revert ValueOutOfRange();
            if (data.length < offset + 1 + m) revert OffsetOutOfBounds();
            value = LittleEndianU256.fromLittleEndian(data, offset + 1);
            if (m < 32) {
                value &= (uint256(1) << (uint256(m) * 8)) - 1; // zero out bytes beyond m
            }
            // MSB of payload must be non-zero for canonical encoding
            uint8 msb;
            assembly {
                msb := shr(248, mload(add(add(data, 32), add(offset, m))))
            }
            if (msb == 0) revert NonCanonicalEncoding();
            bytesRead = 1 + m;
        }
        _assertCanonicalEncoding(value, mode);
    }

    /// @dev Encodes values in the range [0, 63] using single-byte mode
    function _encodeSingleByte(
        uint256 value
    ) private pure returns (bytes memory) {
        // << 2 already leaves 00 in the low bits.
        return abi.encodePacked(uint8(value << 2));
    }

    /// @dev Encodes values in the range [64, 16383] using double-byte mode
    function _encodeTwoByte(uint256 value) private pure returns (bytes memory) {
        uint16 encoded = uint16((value << 2) | MODE_TWO);
        return abi.encodePacked(uint8(encoded & 0xFF), uint8(encoded >> 8));
    }

    /// @dev Encodes values in the range [16384, 1073741823] using four-byte mode
    function _encodeFourByte(
        uint256 value
    ) private pure returns (bytes memory) {
        uint32 encoded = uint32((value << 2) | MODE_FOUR);
        return
            abi.encodePacked(
                uint8(encoded & 0xFF),
                uint8((encoded >> 8) & 0xFF),
                uint8((encoded >> 16) & 0xFF),
                uint8(encoded >> 24)
            );
    }

    /// @dev Encodes values in the range [1073741824, 2^536−1] using "big-int" mode
    ///      Header: ((bytesNeeded - 4) << 2) | 0b11
    function _encodeBigInt(uint256 value) private pure returns (bytes memory) {
        uint8 bytesNeeded = _bytesNeeded(value);
        uint8 header = ((bytesNeeded - 4) << 2) | MODE_BIG;

        bytes memory result = new bytes(1 + bytesNeeded);
        result[0] = bytes1(header);

        uint256 v = value;
        for (uint8 i = 0; i < bytesNeeded; ++i) {
            result[1 + i] = bytes1(uint8(v & 0xFF));
            v >>= 8;
        }

        return result;
    }

    /// @dev Calculate minimum bytes needed to represent value in big-int mode (excluding header)
    function _bytesNeeded(uint256 value) private pure returns (uint8 n) {
        if (value == 0) return 1;
        uint256 tmp = value;
        while (tmp > 0) {
            tmp >>= 8;
            n++;
        }
    }

    /// @dev Asserts that the decoded value is using the canonical encoding for its mode
    ///      This ensures that values are not encoded in a longer format than necessary
    function _assertCanonicalEncoding(uint256 value, uint8 mode) private pure {
        if (mode == MODE_SINGLE && value >= SINGLE_BYTE_BOUND)
            revert NonCanonicalEncoding();
        if (
            mode == MODE_TWO &&
            (value < SINGLE_BYTE_BOUND || value >= TWO_BYTE_BOUND)
        ) revert NonCanonicalEncoding();
        if (
            mode == MODE_FOUR &&
            (value < TWO_BYTE_BOUND || value >= FOUR_BYTE_BOUND)
        ) revert NonCanonicalEncoding();
        if (mode == MODE_BIG && value < FOUR_BYTE_BOUND)
            revert NonCanonicalEncoding();
    }
}
