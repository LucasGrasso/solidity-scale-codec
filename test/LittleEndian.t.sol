// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LittleEndianU8} from "../src/LittleEndian/LittleEndianU8.sol";
import {LittleEndianU16} from "../src/LittleEndian/LittleEndianU16.sol";
import {LittleEndianU32} from "../src/LittleEndian/LittleEndianU32.sol";
import {LittleEndianU64} from "../src/LittleEndian/LittleEndianU64.sol";
import {LittleEndianU128} from "../src/LittleEndian/LittleEndianU128.sol";
import {LittleEndianU256} from "../src/LittleEndian/LittleEndianU256.sol";
import {Test} from "forge-std/Test.sol";

contract LittleEndianTest is Test {
    // ============ U8 ============

    function test_Convert8_Basic() public pure {
        assertEq(LittleEndianU8.toLittleEndian(0xAB), bytes1(0xAB));
    }

    function test_Convert8_Zero() public pure {
        assertEq(LittleEndianU8.toLittleEndian(0), bytes1(0));
    }

    function test_Convert8_Max() public pure {
        assertEq(LittleEndianU8.toLittleEndian(0xFF), bytes1(0xFF));
    }

    function testFuzz_Convert8(uint8 value) public pure {
        assertEq(uint8(LittleEndianU8.toLittleEndian(value)), value);
    }

    function testFuzz_Roundtrip8(uint8 value) public pure {
        assertEq(uint8(LittleEndianU8.toLittleEndian(value)), value);
    }

    // ============ U16 ============

    function test_Convert16_Basic() public pure {
        assertEq(LittleEndianU16.toLittleEndian(0xABCD), bytes2(0xCDAB));
    }

    function test_Convert16_Zero() public pure {
        assertEq(LittleEndianU16.toLittleEndian(0), bytes2(0));
    }

    function test_Convert16_Max() public pure {
        assertEq(LittleEndianU16.toLittleEndian(0xFFFF), bytes2(0xFFFF));
    }

    function testFuzz_Roundtrip16(uint16 value) public pure {
        bytes2 le = LittleEndianU16.toLittleEndian(value);
        uint16 reconstructed = uint16(uint8(le[0])) |
            (uint16(uint8(le[1])) << 8);
        assertEq(reconstructed, value);
    }

    function testFuzz_FromLE16(uint16 value) public pure {
        bytes2 le = LittleEndianU16.toLittleEndian(value);
        bytes memory buf = new bytes(2);
        buf[0] = le[0];
        buf[1] = le[1];
        assertEq(LittleEndianU16.fromLittleEndian(buf, 0), value);
    }

    function testFuzz_Idempotent16(uint16 value) public pure {
        bytes2 le = LittleEndianU16.toLittleEndian(value);
        bytes2 back = LittleEndianU16.toLittleEndian(uint16(le));
        assertEq(uint16(back), value);
    }

    // ============ U32 ============

    function test_Convert32_Basic() public pure {
        assertEq(
            LittleEndianU32.toLittleEndian(0x12345678),
            bytes4(0x78563412)
        );
    }

    function test_Convert32_Zero() public pure {
        assertEq(LittleEndianU32.toLittleEndian(0), bytes4(0));
    }

    function test_Convert32_Max() public pure {
        assertEq(
            LittleEndianU32.toLittleEndian(0xFFFFFFFF),
            bytes4(0xFFFFFFFF)
        );
    }

    function testFuzz_Roundtrip32(uint32 value) public pure {
        bytes4 le = LittleEndianU32.toLittleEndian(value);
        uint32 reconstructed = uint32(uint8(le[0])) |
            (uint32(uint8(le[1])) << 8) |
            (uint32(uint8(le[2])) << 16) |
            (uint32(uint8(le[3])) << 24);
        assertEq(reconstructed, value);
    }

    function testFuzz_FromLE32(uint32 value) public pure {
        bytes4 le = LittleEndianU32.toLittleEndian(value);
        bytes memory buf = new bytes(4);
        for (uint256 i = 0; i < 4; i++) buf[i] = le[i];
        assertEq(LittleEndianU32.fromLittleEndian(buf, 0), value);
    }

    function testFuzz_Idempotent32(uint32 value) public pure {
        bytes4 le = LittleEndianU32.toLittleEndian(value);
        bytes4 back = LittleEndianU32.toLittleEndian(uint32(le));
        assertEq(uint32(back), value);
    }

    // ============ U64 ============

    function test_Convert64_Basic() public pure {
        assertEq(
            LittleEndianU64.toLittleEndian(0x0102030405060708),
            bytes8(0x0807060504030201)
        );
    }

    function test_Convert64_Zero() public pure {
        assertEq(LittleEndianU64.toLittleEndian(0), bytes8(0));
    }

    function test_Convert64_Max() public pure {
        assertEq(
            LittleEndianU64.toLittleEndian(type(uint64).max),
            bytes8(0xFFFFFFFFFFFFFFFF)
        );
    }

    function testFuzz_Roundtrip64(uint64 value) public pure {
        bytes8 le = LittleEndianU64.toLittleEndian(value);
        uint64 reconstructed;
        for (uint256 i = 0; i < 8; i++) {
            reconstructed |= uint64(uint8(le[i])) << uint64(i * 8);
        }
        assertEq(reconstructed, value);
    }

    function testFuzz_FromLE64(uint64 value) public pure {
        bytes8 le = LittleEndianU64.toLittleEndian(value);
        bytes memory buf = new bytes(8);
        for (uint256 i = 0; i < 8; i++) buf[i] = le[i];
        assertEq(LittleEndianU64.fromLittleEndian(buf, 0), value);
    }

    function testFuzz_Idempotent64(uint64 value) public pure {
        bytes8 le = LittleEndianU64.toLittleEndian(value);
        bytes8 back = LittleEndianU64.toLittleEndian(uint64(le));
        assertEq(uint64(back), value);
    }

    // ============ U128 ============

    function test_Convert128_Basic() public pure {
        assertEq(
            LittleEndianU128.toLittleEndian(0x0102030405060708090a0b0c0d0e0f10),
            bytes16(0x100f0e0d0c0b0a090807060504030201)
        );
    }

    function test_Convert128_Zero() public pure {
        assertEq(LittleEndianU128.toLittleEndian(0), bytes16(0));
    }

    function test_Convert128_Max() public pure {
        assertEq(
            LittleEndianU128.toLittleEndian(type(uint128).max),
            bytes16(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        );
    }

    function testFuzz_Roundtrip128(uint128 value) public pure {
        bytes16 le = LittleEndianU128.toLittleEndian(value);
        uint128 reconstructed;
        for (uint256 i = 0; i < 16; i++) {
            reconstructed |= uint128(uint8(le[i])) << uint128(i * 8);
        }
        assertEq(reconstructed, value);
    }

    function testFuzz_FromLE128(uint128 value) public pure {
        bytes16 le = LittleEndianU128.toLittleEndian(value);
        bytes memory buf = new bytes(16);
        for (uint256 i = 0; i < 16; i++) buf[i] = le[i];
        assertEq(LittleEndianU128.fromLittleEndian(buf, 0), value);
    }

    function testFuzz_Idempotent128(uint128 value) public pure {
        bytes16 le = LittleEndianU128.toLittleEndian(value);
        bytes16 back = LittleEndianU128.toLittleEndian(uint128(le));
        assertEq(uint128(back), value);
    }

    // ============ U256 ============

    function test_Convert256_Basic() public pure {
        uint256 value = 0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20;
        assertEq(
            LittleEndianU256.toLittleEndian(value),
            bytes32(
                0x201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a090807060504030201
            )
        );
    }

    function test_Convert256_Zero() public pure {
        assertEq(LittleEndianU256.toLittleEndian(0), bytes32(0));
    }

    function test_Convert256_Max() public pure {
        assertEq(
            LittleEndianU256.toLittleEndian(type(uint256).max),
            bytes32(type(uint256).max)
        );
    }

    function testFuzz_Roundtrip256(uint256 value) public pure {
        bytes32 le = LittleEndianU256.toLittleEndian(value);
        uint256 reconstructed;
        for (uint256 i = 0; i < 32; i++) {
            reconstructed |= uint256(uint8(le[i])) << (i * 8);
        }
        assertEq(reconstructed, value);
    }

    function testFuzz_FromLE256(uint256 value) public pure {
        bytes32 le = LittleEndianU256.toLittleEndian(value);
        bytes memory buf = new bytes(32);
        for (uint256 i = 0; i < 32; i++) buf[i] = le[i];
        assertEq(LittleEndianU256.fromLittleEndian(buf, 0), value);
    }

    function testFuzz_Idempotent256(uint256 value) public pure {
        bytes32 le = LittleEndianU256.toLittleEndian(value);
        bytes32 back = LittleEndianU256.toLittleEndian(uint256(le));
        assertEq(uint256(back), value);
    }

    // ============ Offset tests (fromLittleEndian con offset > 0) ============

    function testFuzz_FromLE32_WithOffset(uint32 value) public pure {
        bytes4 le = LittleEndianU32.toLittleEndian(value);
        bytes memory buf = new bytes(8); // 4 bytes de padding + 4 de dato
        for (uint256 i = 0; i < 4; i++) buf[4 + i] = le[i];
        assertEq(LittleEndianU32.fromLittleEndian(buf, 4), value);
    }

    function testFuzz_FromLE64_WithOffset(uint64 value) public pure {
        bytes8 le = LittleEndianU64.toLittleEndian(value);
        bytes memory buf = new bytes(16);
        for (uint256 i = 0; i < 8; i++) buf[8 + i] = le[i];
        assertEq(LittleEndianU64.fromLittleEndian(buf, 8), value);
    }
}
