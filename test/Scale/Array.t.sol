// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {U32Arr} from "../../src/Scale/Array/U32Arr.sol";
import {BoolArr} from "../../src/Scale/Array/BoolArr.sol";
import {U8Arr} from "../../src/Scale/Array/U8Arr.sol";

contract U32ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (uint32[] memory, uint256) {
        return U32Arr.decodeAt(data, 0);
    }
}

contract BoolArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (bool[] memory, uint256) {
        return BoolArr.decodeAt(data, 0);
    }
}

contract ArrayTest is Test {
    U32ArrWrapper u32ArrWrapper;
    BoolArrWrapper boolArrWrapper;

    function setUp() public {
        u32ArrWrapper = new U32ArrWrapper();
        boolArrWrapper = new BoolArrWrapper();
    }

    // ============ U32 ARRAY FUZZ TESTS ============

    function testFuzz_U32Array_RoundTrip(uint32[] calldata values) public pure {
        vm.assume(values.length < 256); // Reasonable limit
        uint32[] memory memValues = new uint32[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U32Arr.encode(memValues);
        (uint32[] memory decoded, uint256 bytesRead) = U32Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_U32Array_EncodedSize(
        uint32[] calldata values
    ) public pure {
        vm.assume(values.length < 256);
        uint32[] memory memValues = new uint32[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U32Arr.encode(memValues);
        uint256 size = U32Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_U32Array() public pure {
        uint32[] memory value = new uint32[](0);
        bytes memory encoded = U32Arr.encode(value);
        assertEq(encoded, hex"00");
        (uint32[] memory decoded, uint256 bytesRead) = U32Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_U32Array() public {
        bytes memory data = hex"0811111111";
        vm.expectRevert();
        u32ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_U32Array() public {
        // compact(1) = 0x04, expects 1 u32 (4 bytes), but only 3 bytes provided
        bytes memory data = hex"04111122";
        vm.expectRevert();
        u32ArrWrapper.decode(data);
    }

    function testMalformedEmpty_U32Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u32ArrWrapper.decode(data);
    }

    // ============ BOOL ARRAY FUZZ TESTS ============

    function testFuzz_BoolArray_RoundTrip(bool[] calldata values) public pure {
        vm.assume(values.length < 256);
        bool[] memory memValues = new bool[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = BoolArr.encode(memValues);
        (bool[] memory decoded, uint256 bytesRead) = BoolArr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_BoolArray_CompactSize(
        bool[] calldata values
    ) public pure {
        vm.assume(values.length < 256);
        bool[] memory memValues = new bool[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = BoolArr.encode(memValues);
        // Compact size + values in bytes
        uint256 compactSize = (values.length < 64) ? 1 : 2;
        assertEq(encoded.length, compactSize + values.length);
    }

    function testEmpty_BoolArray() public pure {
        bool[] memory value = new bool[](0);
        bytes memory encoded = BoolArr.encode(value);
        assertEq(encoded, hex"00");
        (bool[] memory decoded, uint256 bytesRead) = BoolArr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_BoolArray() public {
        bytes memory data = hex"0801";
        vm.expectRevert();
        boolArrWrapper.decode(data);
    }

    // ============ U8 ARRAY FUZZ TESTS ============

    function testFuzz_U8Array_RoundTrip(uint8[] calldata values) public pure {
        vm.assume(values.length < 256);
        uint8[] memory memValues = new uint8[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U8Arr.encode(memValues);
        (uint8[] memory decoded, uint256 bytesRead) = U8Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_U8Array_Size(uint8[] calldata values) public pure {
        vm.assume(values.length < 256);
        uint8[] memory memValues = new uint8[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U8Arr.encode(memValues);
        // Compact size + array length
        uint256 compactSize = (values.length < 64) ? 1 : 2;
        assertEq(encoded.length, compactSize + values.length);
    }
}
