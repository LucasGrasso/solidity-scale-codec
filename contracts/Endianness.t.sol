// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Endianness} from "./Endianness.sol";
import {Test} from "forge-std/Test.sol";

contract EndiannessTest is Test {
    // ============ uint8 / bytes1 ============

    function test_Convert8_Basic() public pure {
        assertEq(Endianness.toLittleEndian8(0xAB), bytes1(0xAB));
    }

    function test_Convert8_Zero() public pure {
        assertEq(Endianness.toLittleEndian8(0), bytes1(0));
    }

    function test_Convert8_Max() public pure {
        assertEq(Endianness.toLittleEndian8(0xFF), bytes1(0xFF));
    }

    function testFuzz_Convert8(uint8 value) public pure {
        assertEq(uint8(Endianness.toLittleEndian8(value)), value);
    }

    // ============ uint16 / bytes2 ============

    function test_Convert16_Basic() public pure {
        assertEq(Endianness.toLittleEndian16(0xABCD), bytes2(0xCDAB));
    }

    function test_Convert16_Zero() public pure {
        assertEq(Endianness.toLittleEndian16(0), bytes2(0));
    }

    function test_Convert16_Max() public pure {
        assertEq(Endianness.toLittleEndian16(0xFFFF), bytes2(0xFFFF));
    }

    function testFuzz_Roundtrip16(uint16 value) public pure {
        bytes2 le = Endianness.toLittleEndian16(value);
        uint16 reconstructed = uint16(uint8(le[0])) |
            (uint16(uint8(le[1])) << 8);
        assertEq(reconstructed, value);
    }

    // ============ uint32 / bytes4 ============

    function test_Convert32_Basic() public pure {
        assertEq(Endianness.toLittleEndian32(0x12345678), bytes4(0x78563412));
    }

    function test_Convert32_Zero() public pure {
        assertEq(Endianness.toLittleEndian32(0), bytes4(0));
    }

    function test_Convert32_Max() public pure {
        assertEq(Endianness.toLittleEndian32(0xFFFFFFFF), bytes4(0xFFFFFFFF));
    }

    function testFuzz_Roundtrip32(uint32 value) public pure {
        bytes4 le = Endianness.toLittleEndian32(value);
        uint32 reconstructed = uint32(uint8(le[0])) |
            (uint32(uint8(le[1])) << 8) |
            (uint32(uint8(le[2])) << 16) |
            (uint32(uint8(le[3])) << 24);
        assertEq(reconstructed, value);
    }

    // ============ uint64 / bytes8 ============

    function test_Convert64_Basic() public pure {
        assertEq(
            Endianness.toLittleEndian64(0x0102030405060708),
            bytes8(0x0807060504030201)
        );
    }

    function test_Convert64_Zero() public pure {
        assertEq(Endianness.toLittleEndian64(0), bytes8(0));
    }

    function test_Convert64_Max() public pure {
        assertEq(
            Endianness.toLittleEndian64(type(uint64).max),
            bytes8(0xFFFFFFFFFFFFFFFF)
        );
    }

    function testFuzz_Roundtrip64(uint64 value) public pure {
        bytes8 le = Endianness.toLittleEndian64(value);
        uint64 reconstructed;
        for (uint256 i = 0; i < 8; i++) {
            reconstructed |= uint64(uint8(le[i])) << (i * 8);
        }
        assertEq(reconstructed, value);
    }

    // ============ uint128 / bytes16 ============

    function test_Convert128_Basic() public pure {
        assertEq(
            Endianness.toLittleEndian128(0x0102030405060708090a0b0c0d0e0f10),
            bytes16(0x100f0e0d0c0b0a090807060504030201)
        );
    }

    function test_Convert128_Zero() public pure {
        assertEq(Endianness.toLittleEndian128(0), bytes16(0));
    }

    function test_Convert128_Max() public pure {
        assertEq(
            Endianness.toLittleEndian128(type(uint128).max),
            bytes16(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        );
    }

    function testFuzz_Roundtrip128(uint128 value) public pure {
        bytes16 le = Endianness.toLittleEndian128(value);
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
            Endianness.toLittleEndian256(value),
            bytes32(
                0x201f1e1d1c1b1a191817161514131211100f0e0d0c0b0a090807060504030201
            )
        );
    }

    function test_Convert256_Zero() public pure {
        assertEq(Endianness.toLittleEndian256(0), bytes32(0));
    }

    function test_Convert256_Max() public pure {
        assertEq(
            Endianness.toLittleEndian256(type(uint256).max),
            bytes32(type(uint256).max)
        );
    }

    function testFuzz_Roundtrip256(uint256 value) public pure {
        bytes32 le = Endianness.toLittleEndian256(value);
        uint256 reconstructed;
        for (uint256 i = 0; i < 32; i++) {
            reconstructed |= uint256(uint8(le[i])) << (i * 8);
        }
        assertEq(reconstructed, value);
    }

    // ============ Idempotency: f(f(x)) == x ============

    function testFuzz_Idempotent16(uint16 value) public pure {
        bytes2 le = Endianness.toLittleEndian16(value);
        bytes2 back = Endianness.toLittleEndian16(uint16(le));
        assertEq(uint16(back), value);
    }

    function testFuzz_Idempotent32(uint32 value) public pure {
        bytes4 le = Endianness.toLittleEndian32(value);
        bytes4 back = Endianness.toLittleEndian32(uint32(le));
        assertEq(uint32(back), value);
    }

    function testFuzz_Idempotent64(uint64 value) public pure {
        bytes8 le = Endianness.toLittleEndian64(value);
        bytes8 back = Endianness.toLittleEndian64(uint64(le));
        assertEq(uint64(back), value);
    }

    function testFuzz_Idempotent128(uint128 value) public pure {
        bytes16 le = Endianness.toLittleEndian128(value);
        bytes16 back = Endianness.toLittleEndian128(uint128(le));
        assertEq(uint128(back), value);
    }

    function testFuzz_Idempotent256(uint256 value) public pure {
        bytes32 le = Endianness.toLittleEndian256(value);
        bytes32 back = Endianness.toLittleEndian256(uint256(le));
        assertEq(uint256(back), value);
    }

    // ============ Signed int8 ============

    function test_ConvertSigned8_Positive() public pure {
        assertEq(Endianness.toLittleEndiani8(int8(1)), bytes1(0x01));
    }

    function test_ConvertSigned8_Negative() public pure {
        assertEq(Endianness.toLittleEndiani8(int8(-1)), bytes1(0xff));
    }

    function test_ConvertSigned8_Min() public pure {
        assertEq(Endianness.toLittleEndiani8(type(int8).min), bytes1(0x80));
    }

    function test_ConvertSigned8_Max() public pure {
        assertEq(Endianness.toLittleEndiani8(type(int8).max), bytes1(0x7f));
    }

    // ============ Signed int16 ============

    function test_ConvertSigned16_Positive() public pure {
        assertEq(Endianness.toLittleEndiani16(int16(1)), bytes2(0x0100));
    }

    function test_ConvertSigned16_Negative() public pure {
        assertEq(Endianness.toLittleEndiani16(int16(-1)), bytes2(0xffff));
    }

    function test_ConvertSigned16_Neg256() public pure {
        assertEq(Endianness.toLittleEndiani16(int16(-256)), bytes2(0x00ff));
    }

    function test_ConvertSigned16_Min() public pure {
        assertEq(Endianness.toLittleEndiani16(type(int16).min), bytes2(0x0080));
    }

    function test_ConvertSigned16_Max() public pure {
        assertEq(Endianness.toLittleEndiani16(type(int16).max), bytes2(0xff7f));
    }

    // ============ Signed int32 ============

    function test_ConvertSigned32_Negative() public pure {
        assertEq(Endianness.toLittleEndiani32(int32(-1)), bytes4(0xffffffff));
    }

    function test_ConvertSigned32_Min() public pure {
        assertEq(
            Endianness.toLittleEndiani32(type(int32).min),
            bytes4(0x00000080)
        );
    }

    function test_ConvertSigned32_Max() public pure {
        assertEq(
            Endianness.toLittleEndiani32(type(int32).max),
            bytes4(0xffffff7f)
        );
    }

    // ============ Signed int64 ============

    function test_ConvertSigned64_Negative() public pure {
        assertEq(
            Endianness.toLittleEndiani64(int64(-1)),
            bytes8(0xffffffffffffffff)
        );
    }

    function test_ConvertSigned64_Min() public pure {
        assertEq(
            Endianness.toLittleEndiani64(type(int64).min),
            bytes8(0x0000000000000080)
        );
    }

    function test_ConvertSigned64_Max() public pure {
        assertEq(
            Endianness.toLittleEndiani64(type(int64).max),
            bytes8(0xffffffffffffff7f)
        );
    }

    // ============ Signed int128 ============

    function test_ConvertSigned128_Negative() public pure {
        assertEq(
            Endianness.toLittleEndiani128(int128(-1)),
            bytes16(0xffffffffffffffffffffffffffffffff)
        );
    }

    function test_ConvertSigned128_Min() public pure {
        assertEq(
            Endianness.toLittleEndiani128(type(int128).min),
            bytes16(0x00000000000000000000000000000080)
        );
    }

    // ============ Signed int256 ============

    function test_ConvertSigned256_Negative() public pure {
        assertEq(
            Endianness.toLittleEndiani256(int256(-1)),
            bytes32(type(uint256).max)
        );
    }

    function test_ConvertSigned256_Min() public pure {
        assertEq(
            Endianness.toLittleEndiani256(type(int256).min),
            bytes32(
                0x0000000000000000000000000000000000000000000000000000000000000080
            )
        );
    }

    // ============ Fuzz signed ============

    function testFuzz_RoundtripSigned16(int16 value) public pure {
        bytes2 le = Endianness.toLittleEndiani16(value);
        int16 reconstructed = int16(
            uint16(uint8(le[0])) | (uint16(uint8(le[1])) << 8)
        );
        assertEq(reconstructed, value);
    }

    function testFuzz_RoundtripSigned32(int32 value) public pure {
        bytes4 le = Endianness.toLittleEndiani32(value);
        int32 reconstructed = int32(
            uint32(uint8(le[0])) |
                (uint32(uint8(le[1])) << 8) |
                (uint32(uint8(le[2])) << 16) |
                (uint32(uint8(le[3])) << 24)
        );
        assertEq(reconstructed, value);
    }
}
