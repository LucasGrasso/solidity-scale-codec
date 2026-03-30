// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../src/Scale/Compact.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

import {LittleEndianU16} from "../src/LittleEndian/LittleEndianU16.sol";
import {LittleEndianU32} from "../src/LittleEndian/LittleEndianU32.sol";
import {LittleEndianU256} from "../src/LittleEndian/LittleEndianU256.sol";

/// @dev Wrapper contract to test reverts (vm.expectRevert needs external calls)
contract CompactWrapper {
    function decode(
        bytes memory data
    ) external pure returns (uint256, uint256) {
        return Compact.decode(data);
    }

    function decodeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256, uint256) {
        return Compact.decodeAt(data, offset);
    }
}

contract CompactTest is Test {
    CompactWrapper wrapper;

    function setUp() public {
        wrapper = new CompactWrapper();
    }

    // ============ Single-byte mode (0-63) ============

    function testFuzz_singleByte(uint256 value) public pure {
        vm.assume(value < 64);
        bytes memory encoded = Compact.encode(value);
        assertEq(encoded.length, 1);
        //assert that the encoded byte is the value shifted left by 2 (to make room for mode bits) and with mode bits 0b00
        uint8 mode = uint8(encoded[0]) & 0x03; // Extract mode bits
        assertEq(mode, Compact.MODE_SINGLE); // Mode should be 0b00 for single-byte
        assertEq(uint8(encoded[0]) >> 2, value); // The value should be in the upper 6 bits
        (uint256 decoded, uint256 bytesRead) = Compact.decode(encoded);
        assertEq(decoded, value);
        assertEq(bytesRead, 1);
    }

    // ============ Two-byte mode (64-16383) ============

    function testFuzz_twoByte(uint256 value) public pure {
        vm.assume(value >= 64 && value < 16384);
        bytes memory encoded = Compact.encode(value);
        assertEq(encoded.length, 2);
        uint8 mode = uint8(encoded[0]) & 0x03; // Extract mode bits
        assertEq(mode, Compact.MODE_TWO); // Mode should be 0b01 for two-byte
        uint16 expectedValue = (uint16(value) << 2) | uint16(Compact.MODE_TWO);
        bytes memory expected = abi.encodePacked(
            LittleEndianU16.toLittleEndian(expectedValue)
        );
        assertEq0(encoded, expected);
        (uint256 decoded, uint256 bytesRead) = Compact.decode(encoded);
        assertEq(decoded, value);
        assertEq(bytesRead, 2);
    }

    // ============ Four-byte mode (16384-1073741823) ============

    function testFuzz_fourByte(uint256 value) public pure {
        vm.assume(value >= 16384 && value < 1073741824);
        bytes memory encoded = Compact.encode(value);
        assertEq(encoded.length, 4);
        uint8 mode = uint8(encoded[0]) & 0x03; // Extract mode bits
        assertEq(mode, Compact.MODE_FOUR);

        uint32 expectedValue = (uint32(value) << 2) | uint32(Compact.MODE_FOUR);
        bytes memory expected = abi.encodePacked(
            LittleEndianU32.toLittleEndian(expectedValue)
        );
        assertEq0(encoded, expected);

        (uint256 decoded, uint256 bytesRead) = Compact.decode(encoded);
        assertEq(decoded, value);
        assertEq(bytesRead, 4);
    }

    // ============ Big-Int mode (1073741824-2^256-1) ============

    function testFuzz_bigInt(uint256 value) public pure {
        vm.assume(value >= 1073741824);
        bytes memory encoded = Compact.encode(value);
        uint8 mode = uint8(encoded[0]) & 0x03; // Extract mode bits
        assertEq(mode, Compact.MODE_BIG); // Mode should be 0b11 for big-int

        uint256 m = 0;
        uint256 temp = value;
        while (temp > 0) {
            temp >>= 8;
            m++;
        }
        // SCALE spec: for mode 11, m must be at least 4
        if (m < 4) m = 4;

        // Construct the header byte
        // (m - 4) shifted left by 2 bits, then set the last two bits to 11 (0x03)
        uint8 header = uint8(((m - 4) << 2) | 0x03);

        bytes32 fullLE = LittleEndianU256.toLittleEndian(value);

        // Extract only the 'm' significant bytes
        bytes memory valueBytes = new bytes(m);
        for (uint256 i = 0; i < m; i++) {
            valueBytes[i] = fullLE[i];
        }

        // Build the expected result: [Header] + [LE Bytes]
        bytes memory expected = abi.encodePacked(header, valueBytes);
        assertEq0(encoded, expected);

        (uint256 decoded, uint256 bytesRead) = Compact.decode(encoded);
        assertEq(decoded, value);
        assertEq(encoded.length, m + 1);
        assertEq(bytesRead, 1 + ((encoded.length - 1))); // 1 byte for header + payload length
    }

    // --- Non-Canonical Encoding Tests ---

    /// Test that using Mode_TWO for a value that fits in Mode_SINGLE reverts
    function test_RevertIf_NonCanonical_SingleInTwo() public {
        // Manually encode 63 as Mode_TWO: (63 << 2) | 0x01 = 0xFD 0x00
        bytes memory nonCanonical = abi.encodePacked(uint8(0xFD), uint8(0x00));

        vm.expectRevert(Compact.NonCanonicalEncoding.selector);
        wrapper.decode(nonCanonical);
    }

    /// Test that using Mode_FOUR for a value that fits in Mode_TWO reverts
    function test_RevertIf_NonCanonical_TwoInFour() public {
        uint256 value = 16383;
        // Manually encode as Mode_FOUR: (16383 << 2) | 0x02
        uint32 encoded = uint32((value << 2) | Compact.MODE_FOUR);
        bytes memory nonCanonical = abi.encodePacked(
            uint8(encoded & 0xFF),
            uint8((encoded >> 8) & 0xFF),
            uint8((encoded >> 16) & 0xFF),
            uint8(encoded >> 24)
        );

        vm.expectRevert(Compact.NonCanonicalEncoding.selector);
        wrapper.decode(nonCanonical);
    }

    /// Test that Big-Int mode with a zero MSB (most significant byte) reverts
    /// SCALE requires the shortest representation; trailing zeros in LE are non-canonical.
    function test_RevertIf_NonCanonical_BigIntTrailingZero() public {
        // Mode_BIG: header (m-4 << 2 | 3). For 4 bytes of data, header is 0x03.
        // We append an extra zero byte at the end to make it 5 bytes of data.
        bytes memory nonCanonical = abi.encodePacked(
            uint8(((5 - 4) << 2) | 0x03), // Header says 5 bytes follow
            uint32(1073741824), // 4 bytes of data (LE)
            uint8(0) // 5th byte is 0 (Non-canonical!)
        );

        vm.expectRevert(Compact.NonCanonicalEncoding.selector);
        wrapper.decode(nonCanonical);
    }

    // --- Range and Validity Tests ---

    /// Test that a header indicating more than 32 bytes (uint256 limit) reverts
    function test_RevertIf_ValueOutOfRange_TooManyBytes() public {
        // (m - 4) << 2 | 0x03. Let's try m = 33.
        // (33 - 4) << 2 | 0x03 = 29 << 2 | 3 = 116 | 3 = 119 (0x77)
        bytes memory tooLong = abi.encodePacked(uint8(0x77));

        vm.expectRevert(Compact.ValueOutOfRange.selector);
        wrapper.decode(tooLong);
    }

    /// Test decodeAt with an offset that exceeds the data length
    function test_RevertIf_OffsetOutOfBounds() public {
        bytes memory data = hex"01"; // Valid single byte

        vm.expectRevert(Compact.OffsetOutOfBounds.selector);
        wrapper.decodeAt(data, 10);
    }
}
