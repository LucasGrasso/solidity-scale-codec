// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Endianness} from "./Endianness.sol";
import {Test} from "forge-std/Test.sol";

contract EndiannessTest is Test {
    // ============ uint8 / bytes1 ============

    function test_Convert8_Basic() public pure {
        assertEq(Endianness.toLittleEndianU8(0xAB), bytes1(0xAB));
    }

    function test_Convert8_Zero() public pure {
        assertEq(Endianness.toLittleEndianU8(0), bytes1(0));
    }

    function test_Convert8_Max() public pure {
        assertEq(Endianness.toLittleEndianU8(0xFF), bytes1(0xFF));
    }

    function testFuzz_Convert8(uint8 value) public pure {
        assertEq(uint8(Endianness.toLittleEndianU8(value)), value);
    }

    // ============ uint16 / bytes2 ============

    function test_Convert16_Basic() public pure {
        assertEq(Endianness.toLittleEndianU16(0xABCD), bytes2(0xCDAB));
    }

    function test_Convert16_Zero() public pure {
        assertEq(Endianness.toLittleEndianU16(0), bytes2(0));
    }

    function test_Convert16_Max() public pure {
        assertEq(Endianness.toLittleEndianU16(0xFFFF), bytes2(0xFFFF));
    }

    function testFuzz_Roundtrip16(uint16 value) public pure {
        bytes2 le = Endianness.toLittleEndianU16(value);
        uint16 reconstructed = uint16(uint8(le[0])) |
            (uint16(uint8(le[1])) << 8);
        assertEq(reconstructed, value);
    }

    // ============ uint32 / bytes4 ============

    function test_Convert32_Basic() public pure {
        assertEq(Endianness.toLittleEndianU32(0x12345678), bytes4(0x78563412));
    }

    function test_Convert32_Zero() public pure {
        assertEq(Endianness.toLittleEndianU32(0), bytes4(0));
    }

    function test_Convert32_Max() public pure {
        assertEq(Endianness.toLittleEndianU32(0xFFFFFFFF), bytes4(0xFFFFFFFF));
    }

    function testFuzz_Roundtrip32(uint32 value) public pure {
        bytes4 le = Endianness.toLittleEndianU32(value);
        uint32 reconstructed = uint32(uint8(le[0])) |
            (uint32(uint8(le[1])) << 8) |
            (uint32(uint8(le[2])) << 16) |
            (uint32(uint8(le[3])) << 24);
        assertEq(reconstructed, value);
    }

    // ============ uint64 / bytes8 ============

    function test_Convert64_Basic() public pure {
        assertEq(
            Endianness.toLittleEndianU64(0x0102030405060708),
            bytes8(0x0807060504030201)
        );
    }

    function test_Convert64_Zero() public pure {
        assertEq(Endianness.toLittleEndianU64(0), bytes8(0));
    }

    function test_Convert64_Max() public pure {
        assertEq(
            Endianness.toLittleEndianU64(type(uint64).max),
            bytes8(0xFFFFFFFFFFFFFFFF)
        );
    }

    function testFuzz_Roundtrip64(uint64 value) public pure {
        bytes8 le = Endianness.toLittleEndianU64(value);
        uint64 reconstructed;
        for (uint256 i = 0; i < 8; i++) {
            reconstructed |= uint64(uint8(le[i])) << (i * 8);
        }
        assertEq(reconstructed, value);
    }

    // ============ uint128 / bytes16 ============

    function test_Convert128_Basic() public pure {
        assertEq(
            Endianness.toLittleEndianU128(0x0102030405060708090a0b0c0d0e0f10),
            bytes16(0x100f0e0d0c0b0a090807060504030201)
        );
    }

    function test_Convert128_Zero() public pure {
        assertEq(Endianness.toLittleEndianU128(0), bytes16(0));
    }

    function test_Convert128_Max() public pure {
        assertEq(
            Endianness.toLittleEndianU128(type(uint128).max),
            bytes16(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        );
    }

    function testFuzz_Roundtrip128(uint128 value) public pure {
        bytes16 le = Endianness.toLittleEndianU128(value);
        uint128 reconstructed;
        for (uint256 i = 0; i < 16; i++) {
            reconstructed |= uint128(uint8(le[i])) << (i * 8);
        }
        assertEq(reconstructed, value);
    }

    // ============ uint256 / bytes32 ============

    function test_Convert256_Basic() public pure {
        uint256 value = 0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20;
        assertEq(
            Endianness.toLittleEndianU256(value),
            bytes32(
                0x201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a090807060504030201
            )
        );
    }

    function test_Convert256_Zero() public pure {
        assertEq(Endianness.toLittleEndianU256(0), bytes32(0));
    }

    function test_Convert256_Max() public pure {
        assertEq(
            Endianness.toLittleEndianU256(type(uint256).max),
            bytes32(type(uint256).max)
        );
    }

    function testFuzz_Roundtrip256(uint256 value) public pure {
        bytes32 le = Endianness.toLittleEndianU256(value);
        uint256 reconstructed;
        for (uint256 i = 0; i < 32; i++) {
            reconstructed |= uint256(uint8(le[i])) << (i * 8);
        }
        assertEq(reconstructed, value);
    }

    // ============ Idempotency: f(f(x)) == x ============

    function testFuzz_Idempotent16(uint16 value) public pure {
        bytes2 le = Endianness.toLittleEndianU16(value);
        bytes2 back = Endianness.toLittleEndianU16(uint16(le));
        assertEq(uint16(back), value);
    }

    function testFuzz_Idempotent32(uint32 value) public pure {
        bytes4 le = Endianness.toLittleEndianU32(value);
        bytes4 back = Endianness.toLittleEndianU32(uint32(le));
        assertEq(uint32(back), value);
    }

    function testFuzz_Idempotent64(uint64 value) public pure {
        bytes8 le = Endianness.toLittleEndianU64(value);
        bytes8 back = Endianness.toLittleEndianU64(uint64(le));
        assertEq(uint64(back), value);
    }

    function testFuzz_Idempotent128(uint128 value) public pure {
        bytes16 le = Endianness.toLittleEndianU128(value);
        bytes16 back = Endianness.toLittleEndianU128(uint128(le));
        assertEq(uint128(back), value);
    }

    function testFuzz_Idempotent256(uint256 value) public pure {
        bytes32 le = Endianness.toLittleEndianU256(value);
        bytes32 back = Endianness.toLittleEndianU256(uint256(le));
        assertEq(uint256(back), value);
    }

    // ============ Signed int8 ============

    function test_ConvertSigned8_Positive() public pure {
        assertEq(Endianness.toLittleEndianI8(int8(1)), bytes1(0x01));
    }

    function test_ConvertSigned8_Negative() public pure {
        assertEq(Endianness.toLittleEndianI8(int8(-1)), bytes1(0xff));
    }

    function test_ConvertSigned8_Min() public pure {
        assertEq(Endianness.toLittleEndianI8(type(int8).min), bytes1(0x80));
    }

    function test_ConvertSigned8_Max() public pure {
        assertEq(Endianness.toLittleEndianI8(type(int8).max), bytes1(0x7f));
    }

    // ============ Signed int16 ============

    function test_ConvertSigned16_Positive() public pure {
        assertEq(Endianness.toLittleEndianI16(int16(1)), bytes2(0x0100));
    }

    function test_ConvertSigned16_Negative() public pure {
        assertEq(Endianness.toLittleEndianI16(int16(-1)), bytes2(0xffff));
    }

    function test_ConvertSigned16_Neg256() public pure {
        assertEq(Endianness.toLittleEndianI16(int16(-256)), bytes2(0x00ff));
    }

    function test_ConvertSigned16_Min() public pure {
        assertEq(Endianness.toLittleEndianI16(type(int16).min), bytes2(0x0080));
    }

    function test_ConvertSigned16_Max() public pure {
        assertEq(Endianness.toLittleEndianI16(type(int16).max), bytes2(0xff7f));
    }

    // ============ Signed int32 ============

    function test_ConvertSigned32_Negative() public pure {
        assertEq(Endianness.toLittleEndianI32(int32(-1)), bytes4(0xffffffff));
    }

    function test_ConvertSigned32_Min() public pure {
        assertEq(
            Endianness.toLittleEndianI32(type(int32).min),
            bytes4(0x00000080)
        );
    }

    function test_ConvertSigned32_Max() public pure {
        assertEq(
            Endianness.toLittleEndianI32(type(int32).max),
            bytes4(0xffffff7f)
        );
    }

    // ============ Signed int64 ============

    function test_ConvertSigned64_Negative() public pure {
        assertEq(
            Endianness.toLittleEndianI64(int64(-1)),
            bytes8(0xffffffffffffffff)
        );
    }

    function test_ConvertSigned64_Min() public pure {
        assertEq(
            Endianness.toLittleEndianI64(type(int64).min),
            bytes8(0x0000000000000080)
        );
    }

    function test_ConvertSigned64_Max() public pure {
        assertEq(
            Endianness.toLittleEndianI64(type(int64).max),
            bytes8(0xffffffffffffff7f)
        );
    }

    // ============ Signed int128 ============

    function test_ConvertSigned128_Negative() public pure {
        assertEq(
            Endianness.toLittleEndianI128(int128(-1)),
            bytes16(0xffffffffffffffffffffffffffffffff)
        );
    }

    function test_ConvertSigned128_Min() public pure {
        assertEq(
            Endianness.toLittleEndianI128(type(int128).min),
            bytes16(0x00000000000000000000000000000080)
        );
    }

    // ============ Signed int256 ============

    function test_ConvertSigned256_Negative() public pure {
        assertEq(
            Endianness.toLittleEndianI256(int256(-1)),
            bytes32(type(uint256).max)
        );
    }

    function test_ConvertSigned256_Min() public pure {
        assertEq(
            Endianness.toLittleEndianI256(type(int256).min),
            bytes32(
                0x0000000000000000000000000000000000000000000000000000000000000080
            )
        );
    }

    // ============ Fuzz signed ============

    function testFuzz_RoundtripSigned16(int16 value) public pure {
        bytes2 le = Endianness.toLittleEndianI16(value);
        int16 reconstructed = int16(
            uint16(uint8(le[0])) | (uint16(uint8(le[1])) << 8)
        );
        assertEq(reconstructed, value);
    }

    function testFuzz_RoundtripSigned32(int32 value) public pure {
        bytes4 le = Endianness.toLittleEndianI32(value);
        int32 reconstructed = int32(
            uint32(uint8(le[0])) |
                (uint32(uint8(le[1])) << 8) |
                (uint32(uint8(le[2])) << 16) |
                (uint32(uint8(le[3])) << 24)
        );
        assertEq(reconstructed, value);
    }

    // ============ fromLittleEndian unsigned ============

    function test_FromLE8_Basic() public pure {
        assertEq(Endianness.fromLittleEndianU8(bytes1(0xAB)), 0xAB);
    }

    function test_FromLE16_Basic() public pure {
        // 0xCDAB (LE) → 0xABCD
        assertEq(Endianness.fromLittleEndianU16(bytes2(0xCDAB)), 0xABCD);
    }

    function test_FromLE32_Basic() public pure {
        // 0x78563412 (LE) → 0x12345678
        assertEq(
            Endianness.fromLittleEndianU32(bytes4(0x78563412)),
            0x12345678
        );
    }

    function test_FromLE64_Basic() public pure {
        // 0x0807060504030201 (LE) → 0x0102030405060708
        assertEq(
            Endianness.fromLittleEndianU64(bytes8(0x0807060504030201)),
            0x0102030405060708
        );
    }

    function test_FromLE128_Basic() public pure {
        assertEq(
            Endianness.fromLittleEndianU128(
                bytes16(0x100f0e0d0c0b0a090807060504030201)
            ),
            0x0102030405060708090a0b0c0d0e0f10
        );
    }

    function test_FromLE256_Basic() public pure {
        assertEq(
            Endianness.fromLittleEndianU256(
                bytes32(
                    0x201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a090807060504030201
                )
            ),
            0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20
        );
    }

    // ============ fromLittleEndian signed ============

    function test_FromLEi8_Negative() public pure {
        assertEq(Endianness.fromLittleEndianI8(bytes1(0xff)), int8(-1));
    }

    function test_FromLEi16_Negative() public pure {
        assertEq(Endianness.fromLittleEndianI16(bytes2(0xffff)), int16(-1));
    }

    function test_FromLEi16_Neg256() public pure {
        // 0x00ff (LE) → 0xff00 (BE) → -256
        assertEq(Endianness.fromLittleEndianI16(bytes2(0x00ff)), int16(-256));
    }

    function test_FromLEi32_Negative() public pure {
        assertEq(Endianness.fromLittleEndianI32(bytes4(0xffffffff)), int32(-1));
    }

    function test_FromLEi32_Min() public pure {
        // 0x00000080 (LE) → 0x80000000 (BE) → int32.min
        assertEq(
            Endianness.fromLittleEndianI32(bytes4(0x00000080)),
            type(int32).min
        );
    }

    function test_FromLEi64_Negative() public pure {
        assertEq(
            Endianness.fromLittleEndianI64(bytes8(0xffffffffffffffff)),
            int64(-1)
        );
    }

    function test_FromLEi128_Negative() public pure {
        assertEq(
            Endianness.fromLittleEndianI128(
                bytes16(0xffffffffffffffffffffffffffffffff)
            ),
            int128(-1)
        );
    }

    function test_FromLEi256_Negative() public pure {
        assertEq(
            Endianness.fromLittleEndianI256(bytes32(type(uint256).max)),
            int256(-1)
        );
    }

    // ============ Fuzz roundtrip: toLE → fromLE ============

    function testFuzz_RoundtripFromLE8(uint8 value) public pure {
        assertEq(
            Endianness.fromLittleEndianU8(Endianness.toLittleEndianU8(value)),
            value
        );
    }

    function testFuzz_RoundtripFromLE16(uint16 value) public pure {
        assertEq(
            Endianness.fromLittleEndianU16(Endianness.toLittleEndianU16(value)),
            value
        );
    }

    function testFuzz_RoundtripFromLE32(uint32 value) public pure {
        assertEq(
            Endianness.fromLittleEndianU32(Endianness.toLittleEndianU32(value)),
            value
        );
    }

    function testFuzz_RoundtripFromLE64(uint64 value) public pure {
        assertEq(
            Endianness.fromLittleEndianU64(Endianness.toLittleEndianU64(value)),
            value
        );
    }

    function testFuzz_RoundtripFromLE128(uint128 value) public pure {
        assertEq(
            Endianness.fromLittleEndianU128(
                Endianness.toLittleEndianU128(value)
            ),
            value
        );
    }

    function testFuzz_RoundtripFromLE256(uint256 value) public pure {
        assertEq(
            Endianness.fromLittleEndianU256(
                Endianness.toLittleEndianU256(value)
            ),
            value
        );
    }

    function testFuzz_RoundtripFromLEi16(int16 value) public pure {
        assertEq(
            Endianness.fromLittleEndianI16(Endianness.toLittleEndianI16(value)),
            value
        );
    }

    function testFuzz_RoundtripFromLEi32(int32 value) public pure {
        assertEq(
            Endianness.fromLittleEndianI32(Endianness.toLittleEndianI32(value)),
            value
        );
    }

    function testFuzz_RoundtripFromLEi64(int64 value) public pure {
        assertEq(
            Endianness.fromLittleEndianI64(Endianness.toLittleEndianI64(value)),
            value
        );
    }

    function testFuzz_RoundtripFromLEi128(int128 value) public pure {
        assertEq(
            Endianness.fromLittleEndianI128(
                Endianness.toLittleEndianI128(value)
            ),
            value
        );
    }

    function testFuzz_RoundtripFromLEi256(int256 value) public pure {
        assertEq(
            Endianness.fromLittleEndianI256(
                Endianness.toLittleEndianI256(value)
            ),
            value
        );
    }
}
