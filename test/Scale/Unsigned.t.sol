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

contract U256Wrapper {
    function decode(bytes memory data) external pure returns (uint256) {
        return U256.decode(data);
    }
}

contract UnsignedTest is Test {
    U32Wrapper u32Wrapper;
    U256Wrapper u256Wrapper;

    function setUp() public {
        u32Wrapper = new U32Wrapper();
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
        // Verify first byte is lower byte of value
        assertEq(uint8(encoded[0]), uint8(value));
    }

    // ============ U128 FUZZ TESTS ============

    function testFuzz_U128_RoundTrip(uint128 value) public pure {
        bytes memory encoded = U128.encode(value);
        assertEq(encoded.length, 16);
        assertEq(U128.decode(encoded), value);
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
