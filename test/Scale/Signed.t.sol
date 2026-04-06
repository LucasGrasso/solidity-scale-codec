// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {I8} from "../../src/Scale/Signed/I8.sol";
import {I16} from "../../src/Scale/Signed/I16.sol";
import {I32} from "../../src/Scale/Signed/I32.sol";
import {I64} from "../../src/Scale/Signed/I64.sol";
import {I128} from "../../src/Scale/Signed/I128.sol";
import {I256} from "../../src/Scale/Signed/I256.sol";

contract I32Wrapper {
    function decode(bytes memory data) external pure returns (int32) {
        return I32.decode(data);
    }
}

contract SignedTest is Test {
    I32Wrapper i32Wrapper;

    function setUp() public {
        i32Wrapper = new I32Wrapper();
    }

    // ============ I8 FUZZ TESTS ============

    function testFuzz_I8_RoundTrip(int8 value) public pure {
        bytes memory encoded = I8.encode(value);
        assertEq(encoded.length, 1);
        assertEq(I8.decode(encoded), value);
    }

    // ============ I16 FUZZ TESTS ============

    function testFuzz_I16_RoundTrip(int16 value) public pure {
        bytes memory encoded = I16.encode(value);
        assertEq(encoded.length, 2);
        assertEq(I16.decode(encoded), value);
    }

    function testFuzz_I16_LittleEndian(int16 value) public pure {
        bytes memory encoded = I16.encode(value);
        uint16 asUint = uint16(value);
        assertEq(uint8(encoded[0]), uint8(asUint));
        assertEq(uint8(encoded[1]), uint8(asUint >> 8));
    }

    // ============ I32 FUZZ TESTS ============

    function testFuzz_I32_RoundTrip(int32 value) public pure {
        bytes memory encoded = I32.encode(value);
        assertEq(encoded.length, 4);
        assertEq(I32.decode(encoded), value);
    }

    function testFuzz_I32_LittleEndian(int32 value) public pure {
        bytes memory encoded = I32.encode(value);
        uint32 asUint = uint32(value);
        // Verify little-endian encoding
        assertEq(uint8(encoded[0]), uint8(asUint));
        assertEq(uint8(encoded[1]), uint8(asUint >> 8));
        assertEq(uint8(encoded[2]), uint8(asUint >> 16));
        assertEq(uint8(encoded[3]), uint8(asUint >> 24));
    }

    function testFuzz_I32_EncodedSize(int32 value) public pure {
        bytes memory encoded = I32.encode(value);
        uint256 size = I32.encodedSizeAt(encoded, 0);
        assertEq(size, 4);
    }

    function testMalformedEmpty_I32() public {
        bytes memory data = hex"";
        vm.expectRevert();
        i32Wrapper.decode(data);
    }

    function testMalformedTruncated_I32() public {
        bytes memory data = hex"010203";
        vm.expectRevert();
        i32Wrapper.decode(data);
    }

    // ============ I64 FUZZ TESTS ============

    function testFuzz_I64_RoundTrip(int64 value) public pure {
        bytes memory encoded = I64.encode(value);
        assertEq(encoded.length, 8);
        assertEq(I64.decode(encoded), value);
    }

    // ============ I128 FUZZ TESTS ============

    function testFuzz_I128_RoundTrip(int128 value) public pure {
        bytes memory encoded = I128.encode(value);
        assertEq(encoded.length, 16);
        assertEq(I128.decode(encoded), value);
    }

    // ============ I256 FUZZ TESTS ============

    function testFuzz_I256_RoundTrip(int256 value) public pure {
        bytes memory encoded = I256.encode(value);
        assertEq(encoded.length, 32);
        assertEq(I256.decode(encoded), value);
    }

    function testFuzz_I256_EncodedSize(int256 value) public pure {
        bytes memory encoded = I256.encode(value);
        uint256 size = I256.encodedSizeAt(encoded, 0);
        assertEq(size, 32);
    }
}
