// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {U8} from "../../src/Scale/Unsigned/U8.sol";
import {U16} from "../../src/Scale/Unsigned/U16.sol";
import {U32} from "../../src/Scale/Unsigned/U32.sol";
import {U64} from "../../src/Scale/Unsigned/U64.sol";
import {U128} from "../../src/Scale/Unsigned/U128.sol";
import {U256} from "../../src/Scale/Unsigned/U256.sol";

contract U32Wrapper {
    function decode(bytes memory data) external pure returns (uint32) {
        return U32.decode(data);
    }
}

contract U64Wrapper {
    function decode(bytes memory data) external pure returns (uint64) {
        return U64.decode(data);
    }

    function decodeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint64) {
        return U64.decodeAt(data, offset);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return U64.encodedSizeAt(data, offset);
    }
}

contract U128Wrapper {
    function decode(bytes memory data) external pure returns (uint128) {
        return U128.decode(data);
    }

    function decodeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint128) {
        return U128.decodeAt(data, offset);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return U128.encodedSizeAt(data, offset);
    }
}

contract U256Wrapper {
    function decode(bytes memory data) external pure returns (uint256) {
        return U256.decode(data);
    }
}

contract UnsignedTest is Test {
    U32Wrapper u32Wrapper;
    U64Wrapper u64Wrapper;
    U128Wrapper u128Wrapper;
    U256Wrapper u256Wrapper;

    function setUp() public {
        u32Wrapper = new U32Wrapper();
        u64Wrapper = new U64Wrapper();
        u128Wrapper = new U128Wrapper();
        u256Wrapper = new U256Wrapper();
    }

    // ============ U8 FUZZ TESTS ============

    function testFuzz_U8_RoundTrip(uint8 value) public pure {
        bytes memory encoded = U8.encode(value);
        assertEq(encoded.length, 1);
        assertEq(U8.decode(encoded), value);
    }

    function testFuzz_U8_EncodedSize(uint8 value) public pure {
        bytes memory encoded = U8.encode(value);
        uint256 size = U8.encodedSizeAt(encoded, 0);
        assertEq(size, 1);
    }

    // ============ U16 FUZZ TESTS ============

    function testFuzz_U16_RoundTrip(uint16 value) public pure {
        bytes memory encoded = U16.encode(value);
        assertEq(encoded.length, 2);
        assertEq(U16.decode(encoded), value);
    }

    function testFuzz_U16_LittleEndian(uint16 value) public pure {
        bytes memory encoded = U16.encode(value);
        // Verify little-endian: lower byte first, then upper byte
        assertEq(uint8(encoded[0]), uint8(value));
        assertEq(uint8(encoded[1]), uint8(value >> 8));
    }

    function testFuzz_U16_EncodedSize(uint16 value) public pure {
        bytes memory encoded = U16.encode(value);
        uint256 size = U16.encodedSizeAt(encoded, 0);
        assertEq(size, 2);
    }

    // ============ U32 FUZZ TESTS ============

    function testFuzz_U32_RoundTrip(uint32 value) public pure {
        bytes memory encoded = U32.encode(value);
        assertEq(encoded.length, 4);
        assertEq(U32.decode(encoded), value);
    }

    function testFuzz_U32_LittleEndian(uint32 value) public pure {
        bytes memory encoded = U32.encode(value);
        // Verify little-endian encoding
        assertEq(uint8(encoded[0]), uint8(value));
        assertEq(uint8(encoded[1]), uint8(value >> 8));
        assertEq(uint8(encoded[2]), uint8(value >> 16));
        assertEq(uint8(encoded[3]), uint8(value >> 24));
    }

    function testFuzz_U32_EncodedSize(uint32 value) public pure {
        bytes memory encoded = U32.encode(value);
        uint256 size = U32.encodedSizeAt(encoded, 0);
        assertEq(size, 4);
    }

    function testFuzz_U32_MalformedTruncated(uint32 value) public {
        bytes memory truncated = new bytes(2);
        truncated[0] = bytes1(uint8(value));
        truncated[1] = bytes1(uint8(value >> 8));
        vm.expectRevert();
        u32Wrapper.decode(truncated);
    }

    // ============ U64 FUZZ TESTS ============

    function testFuzz_U64_RoundTrip(uint64 value) public pure {
        bytes memory encoded = U64.encode(value);
        assertEq(encoded.length, 8);
        assertEq(U64.decode(encoded), value);
    }

    function testFuzz_U64_LittleEndian(uint64 value) public pure {
        bytes memory encoded = U64.encode(value);
        assertEq(encoded.length, 8);
        // Verify little-endian: each byte is correct position
        for (uint256 i = 0; i < 8; i++) {
            assertEq(uint8(encoded[i]), uint8(value >> (i * 8)));
        }
    }

    function testFuzz_U64_EncodedSize(uint64 value) public view {
        bytes memory encoded = U64.encode(value);
        uint256 size = u64Wrapper.encodedSizeAt(encoded, 0);
        assertEq(size, 8);
    }

    function testFuzz_U64_DecodeAt(uint64 value) public view {
        bytes memory padded = new bytes(16);
        bytes memory encoded = U64.encode(value);
        for (uint256 i = 0; i < 8; i++) {
            padded[i + 4] = encoded[i];
        }
        uint64 decoded = u64Wrapper.decodeAt(padded, 4);
        assertEq(decoded, value);
    }

    function testFuzz_U64_EncodedSizeAt() public view {
        bytes memory padded = new bytes(20);
        uint256 size = u64Wrapper.encodedSizeAt(padded, 4);
        assertEq(size, 8);
    }

    function test_U64_KnownValue_Zero() public pure {
        bytes memory encoded = U64.encode(uint64(0));
        assertEq(encoded, hex"0000000000000000");
        assertEq(U64.decode(encoded), uint64(0));
    }

    function test_U64_KnownValue_One() public pure {
        bytes memory encoded = U64.encode(uint64(1));
        assertEq(encoded, hex"0100000000000000");
        assertEq(U64.decode(encoded), uint64(1));
    }

    function test_U64_KnownValue_MaxValue() public pure {
        uint64 maxVal = type(uint64).max;
        bytes memory encoded = U64.encode(maxVal);
        assertEq(encoded.length, 8);
        assertEq(U64.decode(encoded), maxVal);
    }

    function test_U64_KnownValue_256() public pure {
        bytes memory encoded = U64.encode(uint64(256));
        assertEq(encoded, hex"0001000000000000");
        assertEq(U64.decode(encoded), uint64(256));
    }

    function test_U64_KnownValue_65536() public pure {
        bytes memory encoded = U64.encode(uint64(65536));
        assertEq(encoded, hex"0000010000000000");
        assertEq(U64.decode(encoded), uint64(65536));
    }

    function testMalformed_U64_Truncated() public {
        bytes memory truncated = new bytes(4);
        vm.expectRevert();
        u64Wrapper.decode(truncated);
    }

    function testMalformed_U64_TruncatedAt() public {
        bytes memory data = new bytes(10);
        vm.expectRevert();
        u64Wrapper.decodeAt(data, 4);
    }

    function testMalformed_U64_EncodedSizeAtTooShort() public {
        bytes memory data = new bytes(6);
        vm.expectRevert();
        u64Wrapper.encodedSizeAt(data, 0);
    }

    function testMalformed_U64_Empty() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u64Wrapper.decode(data);
    }

    // ============ U128 FUZZ TESTS ============

    function testFuzz_U128_RoundTrip(uint128 value) public pure {
        bytes memory encoded = U128.encode(value);
        assertEq(encoded.length, 16);
        assertEq(U128.decode(encoded), value);
    }

    function testFuzz_U128_LittleEndian(uint128 value) public pure {
        bytes memory encoded = U128.encode(value);
        assertEq(encoded.length, 16);
        // Verify little-endian: each byte is correct position
        for (uint256 i = 0; i < 16; i++) {
            assertEq(uint8(encoded[i]), uint8(value >> (i * 8)));
        }
    }

    function testFuzz_U128_EncodedSize(uint128 value) public view {
        bytes memory encoded = U128.encode(value);
        uint256 size = u128Wrapper.encodedSizeAt(encoded, 0);
        assertEq(size, 16);
    }

    function testFuzz_U128_DecodeAt(uint128 value) public view {
        bytes memory padded = new bytes(32);
        bytes memory encoded = U128.encode(value);
        for (uint256 i = 0; i < 16; i++) {
            padded[i + 4] = encoded[i];
        }
        uint128 decoded = u128Wrapper.decodeAt(padded, 4);
        assertEq(decoded, value);
    }

    function testFuzz_U128_EncodedSizeAt() public view {
        bytes memory padded = new bytes(40);
        uint256 size = u128Wrapper.encodedSizeAt(padded, 4);
        assertEq(size, 16);
    }

    function test_U128_KnownValue_Zero() public pure {
        bytes memory encoded = U128.encode(uint128(0));
        assertEq(encoded, hex"00000000000000000000000000000000");
        assertEq(U128.decode(encoded), uint128(0));
    }

    function test_U128_KnownValue_One() public pure {
        bytes memory encoded = U128.encode(uint128(1));
        assertEq(encoded, hex"01000000000000000000000000000000");
        assertEq(U128.decode(encoded), uint128(1));
    }

    function test_U128_KnownValue_MaxValue() public pure {
        uint128 maxVal = type(uint128).max;
        bytes memory encoded = U128.encode(maxVal);
        assertEq(encoded.length, 16);
        assertEq(U128.decode(encoded), maxVal);
    }

    function test_U128_KnownValue_256() public pure {
        bytes memory encoded = U128.encode(uint128(256));
        assertEq(encoded, hex"00010000000000000000000000000000");
        assertEq(U128.decode(encoded), uint128(256));
    }

    function test_U128_KnownValue_U64Max() public pure {
        uint128 val = uint128(type(uint64).max);
        bytes memory encoded = U128.encode(val);
        assertEq(U128.decode(encoded), val);
    }

    function testMalformed_U128_Truncated() public {
        bytes memory truncated = new bytes(8);
        vm.expectRevert();
        u128Wrapper.decode(truncated);
    }

    function testMalformed_U128_TruncatedAt() public {
        bytes memory data = new bytes(12);
        vm.expectRevert();
        u128Wrapper.decodeAt(data, 4);
    }

    function testMalformed_U128_EncodedSizeAtTooShort() public {
        bytes memory data = new bytes(10);
        vm.expectRevert();
        u128Wrapper.encodedSizeAt(data, 0);
    }

    function testMalformed_U128_Empty() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u128Wrapper.decode(data);
    }

    // ============ U256 FUZZ TESTS ============

    function testFuzz_U256_RoundTrip(uint256 value) public pure {
        bytes memory encoded = U256.encode(value);
        assertEq(encoded.length, 32);
        assertEq(U256.decode(encoded), value);
    }

    function testFuzz_U256_EncodedSize(uint256 value) public pure {
        bytes memory encoded = U256.encode(value);
        uint256 size = U256.encodedSizeAt(encoded, 0);
        assertEq(size, 32);
    }

    function testFuzz_U256_MalformedTruncated(uint256 value) public {
        vm.assume(value != 0); // Skip zero to ensure we have data
        bytes memory truncated = new bytes(4);
        for (uint256 i = 0; i < 4; i++) {
            truncated[i] = bytes1(uint8(value >> (i * 8)));
        }
        vm.expectRevert();
        u256Wrapper.decode(truncated);
    }

    function testMalformedEmpty_U32() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u32Wrapper.decode(data);
    }

    function testMalformedEmpty_U256() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u256Wrapper.decode(data);
    }
}
