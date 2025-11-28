// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Compact} from "./Compact.sol";
import {Test} from "forge-std/Test.sol";

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

    function test_Encode_0() public pure {
        assertEq(Compact.encode(0), hex"00");
    }

    function test_Encode_1() public pure {
        assertEq(Compact.encode(1), hex"04");
    }

    function test_Encode_2() public pure {
        assertEq(Compact.encode(2), hex"08");
    }

    function test_Encode_3() public pure {
        assertEq(Compact.encode(3), hex"0c");
    }

    function test_Encode_63() public pure {
        assertEq(Compact.encode(63), hex"fc");
    }

    // ============ Two-byte mode (64-16383) ============

    function test_Encode_64() public pure {
        assertEq(Compact.encode(64), hex"0101");
    }

    function test_Encode_65() public pure {
        assertEq(Compact.encode(65), hex"0501");
    }

    function test_Encode_16383() public pure {
        assertEq(Compact.encode(16383), hex"fdff");
    }

    // ============ Four-byte mode (16384-1073741823) ============

    function test_Encode_16384() public pure {
        assertEq(Compact.encode(16384), hex"02000100");
    }

    function test_Encode_1073741823() public pure {
        assertEq(Compact.encode(1073741823), hex"feffffff");
    }

    // ============ Big-integer mode (>1073741823) ============

    function test_Encode_1073741824() public pure {
        assertEq(Compact.encode(1073741824), hex"0300000040");
    }

    function test_Encode_MaxUint32() public pure {
        assertEq(Compact.encode(type(uint32).max), hex"03ffffffff");
    }

    function test_Encode_MaxUint64() public pure {
        bytes memory encoded = Compact.encode(type(uint64).max);
        assertEq(encoded[0], bytes1(0x13));
        assertEq(encoded.length, 9);
    }

    function test_Encode_BigInt_100000000000000() public pure {
        assertEq(Compact.encode(100000000000000), hex"0b00407a10f35a");
    }

    // ============ Decode single-byte ============

    function test_Decode_0() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"00");
        assertEq(value, 0);
        assertEq(bytesRead, 1);
    }

    function test_Decode_1() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"04");
        assertEq(value, 1);
        assertEq(bytesRead, 1);
    }

    function test_Decode_63() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"fc");
        assertEq(value, 63);
        assertEq(bytesRead, 1);
    }

    // ============ Decode two-byte ============

    function test_Decode_64() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"0101");
        assertEq(value, 64);
        assertEq(bytesRead, 2);
    }

    function test_Decode_65() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"0501");
        assertEq(value, 65);
        assertEq(bytesRead, 2);
    }

    function test_Decode_16383() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"fdff");
        assertEq(value, 16383);
        assertEq(bytesRead, 2);
    }

    // ============ Decode four-byte ============

    function test_Decode_16384() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"02000100");
        assertEq(value, 16384);
        assertEq(bytesRead, 4);
    }

    function test_Decode_1073741823() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"feffffff");
        assertEq(value, 1073741823);
        assertEq(bytesRead, 4);
    }

    // ============ Decode big-integer ============

    function test_Decode_1073741824() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"0300000040");
        assertEq(value, 1073741824);
        assertEq(bytesRead, 5);
    }

    function test_Decode_MaxUint32() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(hex"03ffffffff");
        assertEq(value, type(uint32).max);
        assertEq(bytesRead, 5);
    }

    function test_Decode_BigInt_100000000000000() public pure {
        (uint256 value, uint256 bytesRead) = Compact.decode(
            hex"0b00407a10f35a"
        );
        assertEq(value, 100000000000000);
        assertEq(bytesRead, 7);
    }

    // ============ DecodeAt with offset ============

    function test_DecodeAt() public pure {
        bytes memory data = hex"04010102000100";

        (uint256 v1, uint256 r1) = Compact.decodeAt(data, 0);
        assertEq(v1, 1);
        assertEq(r1, 1);

        (uint256 v2, uint256 r2) = Compact.decodeAt(data, 1);
        assertEq(v2, 64);
        assertEq(r2, 2);

        (uint256 v3, uint256 r3) = Compact.decodeAt(data, 3);
        assertEq(v3, 16384);
        assertEq(r3, 4);
    }

    // ============ Typed encoding ============

    function test_EncodeU8() public pure {
        assertEq(Compact.encodeU8(42), hex"a8");
        assertEq(Compact.encodeU8(255), hex"fd03");
    }

    function test_EncodeU16() public pure {
        assertEq(Compact.encodeU16(1000), hex"a10f");
        assertEq(Compact.encodeU16(65535), hex"feff0300");
    }

    function test_EncodeU32() public pure {
        assertEq(Compact.encodeU32(1000000), hex"02093d00");
    }

    // ============ Typed decoding ============

    function test_DecodeU8() public pure {
        (uint8 value, uint256 bytesRead) = Compact.decodeU8(hex"a8");
        assertEq(value, 42);
        assertEq(bytesRead, 1);
    }

    function test_DecodeU16() public pure {
        (uint16 value, uint256 bytesRead) = Compact.decodeU16(hex"a10f");
        assertEq(value, 1000);
        assertEq(bytesRead, 2);
    }

    function test_DecodeU32() public pure {
        (uint32 value, uint256 bytesRead) = Compact.decodeU32(hex"02093d00");
        assertEq(value, 1000000);
        assertEq(bytesRead, 4);
    }

    // ============ encodedLength ============

    function test_EncodedLength() public pure {
        assertEq(Compact.encodedLength(0), 1);
        assertEq(Compact.encodedLength(63), 1);
        assertEq(Compact.encodedLength(64), 2);
        assertEq(Compact.encodedLength(16383), 2);
        assertEq(Compact.encodedLength(16384), 4);
        assertEq(Compact.encodedLength(1073741823), 4);
        assertEq(Compact.encodedLength(1073741824), 5);
        assertEq(Compact.encodedLength(type(uint64).max), 9);
    }

    // ============ Mode checks ============

    function test_IsSingleByte() public pure {
        assertTrue(Compact.isSingleByte(0));
        assertTrue(Compact.isSingleByte(63));
        assertFalse(Compact.isSingleByte(64));
    }

    function test_IsTwoByte() public pure {
        assertFalse(Compact.isTwoByte(63));
        assertTrue(Compact.isTwoByte(64));
        assertTrue(Compact.isTwoByte(16383));
        assertFalse(Compact.isTwoByte(16384));
    }

    function test_IsFourByte() public pure {
        assertFalse(Compact.isFourByte(16383));
        assertTrue(Compact.isFourByte(16384));
        assertTrue(Compact.isFourByte(1073741823));
        assertFalse(Compact.isFourByte(1073741824));
    }

    function test_IsBigInt() public pure {
        assertFalse(Compact.isBigInt(1073741823));
        assertTrue(Compact.isBigInt(1073741824));
        assertTrue(Compact.isBigInt(type(uint256).max));
    }

    // ============ Fuzz roundtrip ============

    function testFuzz_Roundtrip(uint256 value) public pure {
        bytes memory encoded = Compact.encode(value);
        (uint256 decoded, ) = Compact.decode(encoded);
        assertEq(decoded, value);
    }

    function testFuzz_RoundtripU8(uint8 value) public pure {
        bytes memory encoded = Compact.encodeU8(value);
        (uint8 decoded, ) = Compact.decodeU8(encoded);
        assertEq(decoded, value);
    }

    function testFuzz_RoundtripU16(uint16 value) public pure {
        bytes memory encoded = Compact.encodeU16(value);
        (uint16 decoded, ) = Compact.decodeU16(encoded);
        assertEq(decoded, value);
    }

    function testFuzz_RoundtripU32(uint32 value) public pure {
        bytes memory encoded = Compact.encodeU32(value);
        (uint32 decoded, ) = Compact.decodeU32(encoded);
        assertEq(decoded, value);
    }

    function testFuzz_RoundtripU64(uint64 value) public pure {
        bytes memory encoded = Compact.encodeU64(value);
        (uint64 decoded, ) = Compact.decodeU64(encoded);
        assertEq(decoded, value);
    }

    function testFuzz_RoundtripU128(uint128 value) public pure {
        bytes memory encoded = Compact.encodeU128(value);
        (uint128 decoded, ) = Compact.decodeU128(encoded);
        assertEq(decoded, value);
    }

    // ============ Error cases (using wrapper for external calls) ============

    function test_RevertOnEmptyData() public {
        vm.expectRevert(Compact.InvalidCompactEncoding.selector);
        wrapper.decode(hex"");
    }

    function test_RevertOnTruncatedTwoByte() public {
        vm.expectRevert(Compact.InvalidCompactEncoding.selector);
        wrapper.decode(hex"01"); // Mode 0b01 but only 1 byte
    }

    function test_RevertOnTruncatedFourByte() public {
        vm.expectRevert(Compact.InvalidCompactEncoding.selector);
        wrapper.decode(hex"020001"); // Mode 0b10 but only 3 bytes
    }

    function test_RevertOnTruncatedBigInt() public {
        vm.expectRevert(Compact.InvalidCompactEncoding.selector);
        wrapper.decode(hex"030000"); // Header says 4 bytes but only 2 provided
    }
}
