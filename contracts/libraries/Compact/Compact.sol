// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

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

    // ============ Constants ============

    uint256 private constant SINGLE_BYTE_MAX = 0x3F; // 63
    uint256 private constant TWO_BYTE_MAX = 0x3FFF; // 16383
    uint256 private constant FOUR_BYTE_MAX = 0x3FFFFFFF; // 1073741823

    uint8 private constant MODE_SINGLE = 0x00;
    uint8 private constant MODE_TWO = 0x01;
    uint8 private constant MODE_FOUR = 0x02;
    uint8 private constant MODE_BIG = 0x03;

    // ============ Encoding (generic) ============

    /// @notice Encodes a uint256 value to SCALE Compact format
    /// @param value The value to encode
    /// @return Compact-encoded bytes in little-endian
    function encode(uint256 value) internal pure returns (bytes memory) {
        if (value <= SINGLE_BYTE_MAX) {
            return _encodeSingleByte(value);
        } else if (value <= TWO_BYTE_MAX) {
            return _encodeTwoByte(value);
        } else if (value <= FOUR_BYTE_MAX) {
            return _encodeFourByte(value);
        } else {
            return _encodeBigInt(value);
        }
    }

    // ============ Encoding (typed) ============

    /// @notice Encodes uint8 to Compact
    function encodeU8(uint8 value) internal pure returns (bytes memory) {
        if (value <= SINGLE_BYTE_MAX) {
            return _encodeSingleByte(value);
        } else {
            return _encodeTwoByte(value);
        }
    }

    /// @notice Encodes uint16 to Compact
    function encodeU16(uint16 value) internal pure returns (bytes memory) {
        if (value <= SINGLE_BYTE_MAX) {
            return _encodeSingleByte(value);
        } else if (value <= TWO_BYTE_MAX) {
            return _encodeTwoByte(value);
        } else {
            return _encodeFourByte(value);
        }
    }

    /// @notice Encodes uint32 to Compact
    function encodeU32(uint32 value) internal pure returns (bytes memory) {
        if (value <= SINGLE_BYTE_MAX) {
            return _encodeSingleByte(value);
        } else if (value <= TWO_BYTE_MAX) {
            return _encodeTwoByte(value);
        } else if (value <= FOUR_BYTE_MAX) {
            return _encodeFourByte(value);
        } else {
            return _encodeBigInt(uint256(value));
        }
    }

    /// @notice Encodes uint64 to Compact
    function encodeU64(uint64 value) internal pure returns (bytes memory) {
        return encode(uint256(value));
    }

    /// @notice Encodes uint128 to Compact
    function encodeU128(uint128 value) internal pure returns (bytes memory) {
        return encode(uint256(value));
    }

    // ============ Internal encoding helpers ============

    /// @dev Single-byte mode: value << 2 | 0b00
    function _encodeSingleByte(
        uint256 value
    ) private pure returns (bytes memory) {
        return abi.encodePacked(uint8(value << 2));
    }

    /// @dev Two-byte mode: value << 2 | 0b01, little-endian
    function _encodeTwoByte(uint256 value) private pure returns (bytes memory) {
        uint16 encoded = uint16((value << 2) | MODE_TWO);
        return abi.encodePacked(uint8(encoded & 0xFF), uint8(encoded >> 8));
    }

    /// @dev Four-byte mode: value << 2 | 0b10, little-endian
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

    /// @dev Big-integer mode: header byte + raw value bytes
    ///      Header: ((bytesNeeded - 4) << 2) | 0b11
    function _encodeBigInt(uint256 value) private pure returns (bytes memory) {
        uint8 bytesNeeded = _bytesNeeded(value);
        uint8 header = ((bytesNeeded - 4) << 2) | MODE_BIG;

        bytes memory result = new bytes(1 + bytesNeeded);
        result[0] = bytes1(header);

        uint256 v = value;
        for (uint8 i = 0; i < bytesNeeded; i++) {
            result[1 + i] = bytes1(uint8(v & 0xFF));
            v >>= 8;
        }

        return result;
    }

    /// @dev Calculate minimum bytes needed to represent value
    function _bytesNeeded(uint256 value) private pure returns (uint8) {
        if (value == 0) return 1;

        uint8 count = 0;
        while (value > 0) {
            value >>= 8;
            count++;
        }
        return count;
    }

    // ============ Decoding ============

    /// @notice Decodes Compact bytes to uint256
    /// @param data The compact-encoded bytes
    /// @return value The decoded value
    /// @return bytesRead Number of bytes consumed
    function decode(
        bytes memory data
    ) internal pure returns (uint256 value, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes Compact bytes starting at offset
    /// @dev Validates canonical encoding (rejects values that could use smaller mode)
    /// @param data The compact-encoded bytes
    /// @param offset Starting position in data
    /// @return value The decoded value
    /// @return bytesRead Number of bytes consumed
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256 value, uint256 bytesRead) {
        if (data.length <= offset) revert InvalidCompactEncoding();

        uint8 firstByte = uint8(data[offset]);
        uint8 mode = firstByte & 0x03;

        if (mode == MODE_SINGLE) {
            // Single-byte mode: valid range 0-63
            value = firstByte >> 2;
            bytesRead = 1;
        } else if (mode == MODE_TWO) {
            // Two-byte mode: valid range 64-16383
            if (data.length < offset + 2) revert InvalidCompactEncoding();
            value =
                (uint256(firstByte) |
                    (uint256(uint8(data[offset + 1])) << 8)) >>
                2;

            // Canonical check: must be > SINGLE_BYTE_MAX
            if (value <= SINGLE_BYTE_MAX) revert NonCanonicalEncoding();

            bytesRead = 2;
        } else if (mode == MODE_FOUR) {
            // Four-byte mode: valid range 16384-1073741823
            if (data.length < offset + 4) revert InvalidCompactEncoding();
            value =
                (uint256(firstByte) |
                    (uint256(uint8(data[offset + 1])) << 8) |
                    (uint256(uint8(data[offset + 2])) << 16) |
                    (uint256(uint8(data[offset + 3])) << 24)) >>
                2;

            // Canonical check: must be > TWO_BYTE_MAX
            if (value <= TWO_BYTE_MAX) revert NonCanonicalEncoding();

            bytesRead = 4;
        } else {
            // Big-integer mode: valid range > 1073741823
            uint8 byteLen = (firstByte >> 2) + 4;
            if (data.length < offset + 1 + byteLen)
                revert InvalidCompactEncoding();

            value = 0;
            for (uint8 i = 0; i < byteLen; i++) {
                value |= uint256(uint8(data[offset + 1 + i])) << (i * 8);
            }

            // Canonical check: must be > FOUR_BYTE_MAX
            if (value <= FOUR_BYTE_MAX) revert NonCanonicalEncoding();

            // Additional canonical check: value must require exactly byteLen bytes
            // (no leading zero bytes allowed)
            uint8 minBytesNeeded = _bytesNeeded(value);
            if (byteLen != minBytesNeeded) revert NonCanonicalEncoding();

            bytesRead = 1 + byteLen;
        }
    }

    // ============ Typed decoding with range validation ============

    /// @notice Decodes to uint8 with range validation
    function decodeU8(
        bytes memory data
    ) internal pure returns (uint8 value, uint256 bytesRead) {
        return decodeU8At(data, 0);
    }

    /// @notice Decodes to uint8 at offset with range validation
    function decodeU8At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint8 value, uint256 bytesRead) {
        if (data.length <= offset) revert InvalidCompactEncoding();

        uint8 firstByte = uint8(data[offset]);
        uint8 mode = firstByte & 0x03;

        // u8 only supports single-byte and two-byte modes
        if (mode == MODE_SINGLE) {
            value = uint8(firstByte >> 2);
            bytesRead = 1;
        } else if (mode == MODE_TWO) {
            if (data.length < offset + 2) revert InvalidCompactEncoding();
            uint256 v = (uint256(firstByte) |
                (uint256(uint8(data[offset + 1])) << 8)) >> 2;

            // Canonical: must be > 63 and <= 255 for u8
            if (v <= SINGLE_BYTE_MAX) revert NonCanonicalEncoding();
            if (v > type(uint8).max) revert ValueOutOfRange();

            value = uint8(v);
            bytesRead = 2;
        } else {
            revert ValueOutOfRange();
        }
    }

    /// @notice Decodes to uint16 with range validation
    function decodeU16(
        bytes memory data
    ) internal pure returns (uint16 value, uint256 bytesRead) {
        return decodeU16At(data, 0);
    }

    /// @notice Decodes to uint16 at offset with range validation
    function decodeU16At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint16 value, uint256 bytesRead) {
        if (data.length <= offset) revert InvalidCompactEncoding();

        uint8 firstByte = uint8(data[offset]);
        uint8 mode = firstByte & 0x03;

        if (mode == MODE_SINGLE) {
            value = uint16(firstByte >> 2);
            bytesRead = 1;
        } else if (mode == MODE_TWO) {
            if (data.length < offset + 2) revert InvalidCompactEncoding();
            uint256 v = (uint256(firstByte) |
                (uint256(uint8(data[offset + 1])) << 8)) >> 2;

            if (v <= SINGLE_BYTE_MAX) revert NonCanonicalEncoding();

            value = uint16(v);
            bytesRead = 2;
        } else if (mode == MODE_FOUR) {
            if (data.length < offset + 4) revert InvalidCompactEncoding();
            uint256 v = (uint256(firstByte) |
                (uint256(uint8(data[offset + 1])) << 8) |
                (uint256(uint8(data[offset + 2])) << 16) |
                (uint256(uint8(data[offset + 3])) << 24)) >> 2;

            if (v <= TWO_BYTE_MAX) revert NonCanonicalEncoding();
            if (v > type(uint16).max) revert ValueOutOfRange();

            value = uint16(v);
            bytesRead = 4;
        } else {
            revert ValueOutOfRange();
        }
    }

    /// @notice Decodes to uint32 with range validation
    function decodeU32(
        bytes memory data
    ) internal pure returns (uint32 value, uint256 bytesRead) {
        return decodeU32At(data, 0);
    }

    /// @notice Decodes to uint32 at offset with range validation
    function decodeU32At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint32 value, uint256 bytesRead) {
        if (data.length <= offset) revert InvalidCompactEncoding();

        uint8 firstByte = uint8(data[offset]);
        uint8 mode = firstByte & 0x03;

        if (mode == MODE_SINGLE) {
            value = uint32(firstByte >> 2);
            bytesRead = 1;
        } else if (mode == MODE_TWO) {
            if (data.length < offset + 2) revert InvalidCompactEncoding();
            uint256 v = (uint256(firstByte) |
                (uint256(uint8(data[offset + 1])) << 8)) >> 2;

            if (v <= SINGLE_BYTE_MAX) revert NonCanonicalEncoding();

            value = uint32(v);
            bytesRead = 2;
        } else if (mode == MODE_FOUR) {
            if (data.length < offset + 4) revert InvalidCompactEncoding();
            uint256 v = (uint256(firstByte) |
                (uint256(uint8(data[offset + 1])) << 8) |
                (uint256(uint8(data[offset + 2])) << 16) |
                (uint256(uint8(data[offset + 3])) << 24)) >> 2;

            if (v <= TWO_BYTE_MAX) revert NonCanonicalEncoding();

            value = uint32(v);
            bytesRead = 4;
        } else {
            // Big-integer mode
            uint8 byteLen = (firstByte >> 2) + 4;

            // For u32, only byteLen == 4 is valid (header 0b11 means 4 extra bytes)
            if (byteLen != 4) revert ValueOutOfRange();

            if (data.length < offset + 5) revert InvalidCompactEncoding();

            uint256 v = 0;
            for (uint8 i = 0; i < 4; i++) {
                v |= uint256(uint8(data[offset + 1 + i])) << (i * 8);
            }

            if (v <= FOUR_BYTE_MAX) revert NonCanonicalEncoding();
            if (v > type(uint32).max) revert ValueOutOfRange();

            value = uint32(v);
            bytesRead = 5;
        }
    }

    /// @notice Decodes to uint64 with range validation
    function decodeU64(
        bytes memory data
    ) internal pure returns (uint64 value, uint256 bytesRead) {
        return decodeU64At(data, 0);
    }

    /// @notice Decodes to uint64 at offset with range validation
    function decodeU64At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint64 value, uint256 bytesRead) {
        if (data.length <= offset) revert InvalidCompactEncoding();

        uint8 firstByte = uint8(data[offset]);
        uint8 mode = firstByte & 0x03;

        if (mode == MODE_SINGLE) {
            value = uint64(firstByte >> 2);
            bytesRead = 1;
        } else if (mode == MODE_TWO) {
            if (data.length < offset + 2) revert InvalidCompactEncoding();
            uint256 v = (uint256(firstByte) |
                (uint256(uint8(data[offset + 1])) << 8)) >> 2;

            if (v <= SINGLE_BYTE_MAX) revert NonCanonicalEncoding();

            value = uint64(v);
            bytesRead = 2;
        } else if (mode == MODE_FOUR) {
            if (data.length < offset + 4) revert InvalidCompactEncoding();
            uint256 v = (uint256(firstByte) |
                (uint256(uint8(data[offset + 1])) << 8) |
                (uint256(uint8(data[offset + 2])) << 16) |
                (uint256(uint8(data[offset + 3])) << 24)) >> 2;

            if (v <= TWO_BYTE_MAX) revert NonCanonicalEncoding();

            value = uint64(v);
            bytesRead = 4;
        } else {
            // Big-integer mode
            uint8 byteLen = (firstByte >> 2) + 4;

            // For u64, max byteLen is 8
            if (byteLen > 8) revert ValueOutOfRange();

            if (data.length < offset + 1 + byteLen)
                revert InvalidCompactEncoding();

            uint256 v = 0;
            for (uint8 i = 0; i < byteLen; i++) {
                v |= uint256(uint8(data[offset + 1 + i])) << (i * 8);
            }

            if (v <= FOUR_BYTE_MAX) revert NonCanonicalEncoding();

            // Canonical check: no leading zero bytes
            uint8 minBytes = _bytesNeeded(v);
            if (byteLen != minBytes) revert NonCanonicalEncoding();

            if (v > type(uint64).max) revert ValueOutOfRange();

            value = uint64(v);
            bytesRead = 1 + byteLen;
        }
    }

    /// @notice Decodes to uint128 with range validation
    function decodeU128(
        bytes memory data
    ) internal pure returns (uint128 value, uint256 bytesRead) {
        return decodeU128At(data, 0);
    }

    /// @notice Decodes to uint128 at offset with range validation
    function decodeU128At(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint128 value, uint256 bytesRead) {
        if (data.length <= offset) revert InvalidCompactEncoding();

        uint8 firstByte = uint8(data[offset]);
        uint8 mode = firstByte & 0x03;

        if (mode == MODE_SINGLE) {
            value = uint128(firstByte >> 2);
            bytesRead = 1;
        } else if (mode == MODE_TWO) {
            if (data.length < offset + 2) revert InvalidCompactEncoding();
            uint256 v = (uint256(firstByte) |
                (uint256(uint8(data[offset + 1])) << 8)) >> 2;

            if (v <= SINGLE_BYTE_MAX) revert NonCanonicalEncoding();

            value = uint128(v);
            bytesRead = 2;
        } else if (mode == MODE_FOUR) {
            if (data.length < offset + 4) revert InvalidCompactEncoding();
            uint256 v = (uint256(firstByte) |
                (uint256(uint8(data[offset + 1])) << 8) |
                (uint256(uint8(data[offset + 2])) << 16) |
                (uint256(uint8(data[offset + 3])) << 24)) >> 2;

            if (v <= TWO_BYTE_MAX) revert NonCanonicalEncoding();

            value = uint128(v);
            bytesRead = 4;
        } else {
            // Big-integer mode
            uint8 byteLen = (firstByte >> 2) + 4;

            // For u128, max byteLen is 16
            if (byteLen > 16) revert ValueOutOfRange();

            if (data.length < offset + 1 + byteLen)
                revert InvalidCompactEncoding();

            uint256 v = 0;
            for (uint8 i = 0; i < byteLen; i++) {
                v |= uint256(uint8(data[offset + 1 + i])) << (i * 8);
            }

            if (v <= FOUR_BYTE_MAX) revert NonCanonicalEncoding();

            // Canonical check: no leading zero bytes
            uint8 minBytes = _bytesNeeded(v);
            if (byteLen != minBytes) revert NonCanonicalEncoding();

            if (v > type(uint128).max) revert ValueOutOfRange();

            value = uint128(v);
            bytesRead = 1 + byteLen;
        }
    }

    // ============ Utilities ============

    /// @notice Returns the encoded length without allocating
    /// @param value The value to check
    /// @return The number of bytes needed for compact encoding
    function encodedLength(uint256 value) internal pure returns (uint256) {
        if (value <= SINGLE_BYTE_MAX) return 1;
        if (value <= TWO_BYTE_MAX) return 2;
        if (value <= FOUR_BYTE_MAX) return 4;
        return 1 + _bytesNeeded(value);
    }

    /// @notice Checks if a value fits in single-byte mode
    function isSingleByte(uint256 value) internal pure returns (bool) {
        return value <= SINGLE_BYTE_MAX;
    }

    /// @notice Checks if a value fits in two-byte mode
    function isTwoByte(uint256 value) internal pure returns (bool) {
        return value > SINGLE_BYTE_MAX && value <= TWO_BYTE_MAX;
    }

    /// @notice Checks if a value fits in four-byte mode
    function isFourByte(uint256 value) internal pure returns (bool) {
        return value > TWO_BYTE_MAX && value <= FOUR_BYTE_MAX;
    }

    /// @notice Checks if a value requires big-integer mode
    function isBigInt(uint256 value) internal pure returns (bool) {
        return value > FOUR_BYTE_MAX;
    }
}
