// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {BoolArr} from "../../src/Scale/Array/BoolArr.sol";
import {I8Arr} from "../../src/Scale/Array/I8Arr.sol";
import {I16Arr} from "../../src/Scale/Array/I16Arr.sol";
import {I32Arr} from "../../src/Scale/Array/I32Arr.sol";
import {I64Arr} from "../../src/Scale/Array/I64Arr.sol";
import {I128Arr} from "../../src/Scale/Array/I128Arr.sol";
import {I256Arr} from "../../src/Scale/Array/I256Arr.sol";
import {U8Arr} from "../../src/Scale/Array/U8Arr.sol";
import {U16Arr} from "../../src/Scale/Array/U16Arr.sol";
import {U32Arr} from "../../src/Scale/Array/U32Arr.sol";
import {U64Arr} from "../../src/Scale/Array/U64Arr.sol";
import {U128Arr} from "../../src/Scale/Array/U128Arr.sol";
import {U256Arr} from "../../src/Scale/Array/U256Arr.sol";

contract BoolArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (bool[] memory, uint256) {
        return BoolArr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return BoolArr.encodedSizeAt(data, offset);
    }
}

contract U8ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (uint8[] memory, uint256) {
        return U8Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return U8Arr.encodedSizeAt(data, offset);
    }
}

contract U16ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (uint16[] memory, uint256) {
        return U16Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return U16Arr.encodedSizeAt(data, offset);
    }
}

contract U32ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (uint32[] memory, uint256) {
        return U32Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return U32Arr.encodedSizeAt(data, offset);
    }
}

contract U64ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (uint64[] memory, uint256) {
        return U64Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return U64Arr.encodedSizeAt(data, offset);
    }
}

contract U128ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (uint128[] memory, uint256) {
        return U128Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return U128Arr.encodedSizeAt(data, offset);
    }
}

contract U256ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (uint256[] memory, uint256) {
        return U256Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return U256Arr.encodedSizeAt(data, offset);
    }
}

contract I8ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (int8[] memory, uint256) {
        return I8Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return I8Arr.encodedSizeAt(data, offset);
    }
}

contract I16ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (int16[] memory, uint256) {
        return I16Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return I16Arr.encodedSizeAt(data, offset);
    }
}

contract I32ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (int32[] memory, uint256) {
        return I32Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return I32Arr.encodedSizeAt(data, offset);
    }
}

contract I64ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (int64[] memory, uint256) {
        return I64Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return I64Arr.encodedSizeAt(data, offset);
    }
}

contract I128ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (int128[] memory, uint256) {
        return I128Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return I128Arr.encodedSizeAt(data, offset);
    }
}

contract I256ArrWrapper {
    function decode(
        bytes memory data
    ) external pure returns (int256[] memory, uint256) {
        return I256Arr.decode(data);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return I256Arr.encodedSizeAt(data, offset);
    }
}

contract ArrayTest is Test {
    BoolArrWrapper boolArrWrapper;
    U8ArrWrapper u8ArrWrapper;
    U16ArrWrapper u16ArrWrapper;
    U32ArrWrapper u32ArrWrapper;
    U64ArrWrapper u64ArrWrapper;
    U128ArrWrapper u128ArrWrapper;
    U256ArrWrapper u256ArrWrapper;
    I8ArrWrapper i8ArrWrapper;
    I16ArrWrapper i16ArrWrapper;
    I32ArrWrapper i32ArrWrapper;
    I64ArrWrapper i64ArrWrapper;
    I128ArrWrapper i128ArrWrapper;
    I256ArrWrapper i256ArrWrapper;

    function setUp() public {
        boolArrWrapper = new BoolArrWrapper();
        u8ArrWrapper = new U8ArrWrapper();
        u16ArrWrapper = new U16ArrWrapper();
        u32ArrWrapper = new U32ArrWrapper();
        u64ArrWrapper = new U64ArrWrapper();
        u128ArrWrapper = new U128ArrWrapper();
        u256ArrWrapper = new U256ArrWrapper();
        i8ArrWrapper = new I8ArrWrapper();
        i16ArrWrapper = new I16ArrWrapper();
        i32ArrWrapper = new I32ArrWrapper();
        i64ArrWrapper = new I64ArrWrapper();
        i128ArrWrapper = new I128ArrWrapper();
        i256ArrWrapper = new I256ArrWrapper();
    }

    // ============ BOOL ARRAY FUZZ TESTS ============

    function testFuzz_BoolArray_RoundTrip(bool[] calldata values) public pure {
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

    function testFuzz_BoolArray_EncodedSize(
        bool[] calldata values
    ) public pure {
        bool[] memory memValues = new bool[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = BoolArr.encode(memValues);
        uint256 size = BoolArr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
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

    function testMalformedIncompleteElement_BoolArray() public {
        bytes memory data = hex"";
        vm.expectRevert();
        boolArrWrapper.decode(data);
    }

    function testMalformedEmpty_BoolArray() public {
        bytes memory data = hex"";
        vm.expectRevert();
        boolArrWrapper.decode(data);
    }

    function testMalformedOffset_BoolEncodedSize() public {
        bytes memory data = hex"0102";
        vm.expectRevert(BoolArr.InvalidBoolArrLength.selector);
        boolArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ U8 ARRAY FUZZ TESTS ============

    function testFuzz_U8Array_RoundTrip(uint8[] calldata values) public pure {
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

    function testFuzz_U8Array_EncodedSize(uint8[] calldata values) public pure {
        uint8[] memory memValues = new uint8[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U8Arr.encode(memValues);
        uint256 size = U8Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_U8Array() public pure {
        uint8[] memory value = new uint8[](0);
        bytes memory encoded = U8Arr.encode(value);
        assertEq(encoded, hex"00");
        (uint8[] memory decoded, uint256 bytesRead) = U8Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_U8Array() public {
        bytes memory data = hex"0801";
        vm.expectRevert();
        u8ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_U8Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u8ArrWrapper.decode(data);
    }

    function testMalformedEmpty_U8Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u8ArrWrapper.decode(data);
    }

    function testMalformedOffset_U8EncodedSize() public {
        bytes memory data = hex"0102";
        vm.expectRevert(U8Arr.InvalidU8ArrLength.selector);
        u8ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ U16 ARRAY FUZZ TESTS ============

    function testFuzz_U16Array_RoundTrip(uint16[] calldata values) public pure {
        uint16[] memory memValues = new uint16[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U16Arr.encode(memValues);
        (uint16[] memory decoded, uint256 bytesRead) = U16Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_U16Array_EncodedSize(
        uint16[] calldata values
    ) public pure {
        uint16[] memory memValues = new uint16[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U16Arr.encode(memValues);
        uint256 size = U16Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_U16Array() public pure {
        uint16[] memory value = new uint16[](0);
        bytes memory encoded = U16Arr.encode(value);
        assertEq(encoded, hex"00");
        (uint16[] memory decoded, uint256 bytesRead) = U16Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_U16Array() public {
        bytes memory data = hex"0411";
        vm.expectRevert();
        u16ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_U16Array() public {
        bytes memory data = hex"0411";
        vm.expectRevert();
        u16ArrWrapper.decode(data);
    }

    function testMalformedEmpty_U16Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u16ArrWrapper.decode(data);
    }

    function testMalformedOffset_U16EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(U16Arr.InvalidU16ArrLength.selector);
        u16ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ U32 ARRAY FUZZ TESTS ============

    function testFuzz_U32Array_RoundTrip(uint32[] calldata values) public pure {
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

    function testMalformedOffset_U32EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(U32Arr.InvalidU32ArrLength.selector);
        u32ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ U64 ARRAY FUZZ TESTS ============

    function testFuzz_U64Array_RoundTrip(uint64[] calldata values) public pure {
        uint64[] memory memValues = new uint64[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U64Arr.encode(memValues);
        (uint64[] memory decoded, uint256 bytesRead) = U64Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_U64Array_EncodedSize(
        uint64[] calldata values
    ) public pure {
        uint64[] memory memValues = new uint64[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U64Arr.encode(memValues);
        uint256 size = U64Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_U64Array() public pure {
        uint64[] memory value = new uint64[](0);
        bytes memory encoded = U64Arr.encode(value);
        assertEq(encoded, hex"00");
        (uint64[] memory decoded, uint256 bytesRead) = U64Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_U64Array() public {
        bytes memory data = hex"0411111111111111";
        vm.expectRevert();
        u64ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_U64Array() public {
        bytes memory data = hex"0411111111111111";
        vm.expectRevert();
        u64ArrWrapper.decode(data);
    }

    function testMalformedEmpty_U64Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u64ArrWrapper.decode(data);
    }

    function testMalformedOffset_U64EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(U64Arr.InvalidU64ArrLength.selector);
        u64ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ U128 ARRAY FUZZ TESTS ============

    function testFuzz_U128Array_RoundTrip(
        uint128[] calldata values
    ) public pure {
        uint128[] memory memValues = new uint128[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U128Arr.encode(memValues);
        (uint128[] memory decoded, uint256 bytesRead) = U128Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_U128Array_EncodedSize(
        uint128[] calldata values
    ) public pure {
        uint128[] memory memValues = new uint128[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U128Arr.encode(memValues);
        uint256 size = U128Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_U128Array() public pure {
        uint128[] memory value = new uint128[](0);
        bytes memory encoded = U128Arr.encode(value);
        assertEq(encoded, hex"00");
        (uint128[] memory decoded, uint256 bytesRead) = U128Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_U128Array() public {
        bytes memory data = hex"04111111111111111111111111111111";
        vm.expectRevert();
        u128ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_U128Array() public {
        bytes memory data = hex"04111111111111111111111111111111";
        vm.expectRevert();
        u128ArrWrapper.decode(data);
    }

    function testMalformedEmpty_U128Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u128ArrWrapper.decode(data);
    }

    function testMalformedOffset_U128EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(U128Arr.InvalidU128ArrLength.selector);
        u128ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ U256 ARRAY FUZZ TESTS ============

    function testFuzz_U256Array_RoundTrip(
        uint256[] calldata values
    ) public pure {
        uint256[] memory memValues = new uint256[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U256Arr.encode(memValues);
        (uint256[] memory decoded, uint256 bytesRead) = U256Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_U256Array_EncodedSize(
        uint256[] calldata values
    ) public pure {
        uint256[] memory memValues = new uint256[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = U256Arr.encode(memValues);
        uint256 size = U256Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_U256Array() public pure {
        uint256[] memory value = new uint256[](0);
        bytes memory encoded = U256Arr.encode(value);
        assertEq(encoded, hex"00");
        (uint256[] memory decoded, uint256 bytesRead) = U256Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_U256Array() public {
        bytes
            memory data = hex"0411111111111111111111111111111111111111111111111111111111111111";
        vm.expectRevert();
        u256ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_U256Array() public {
        bytes
            memory data = hex"0411111111111111111111111111111111111111111111111111111111111111";
        vm.expectRevert();
        u256ArrWrapper.decode(data);
    }

    function testMalformedEmpty_U256Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        u256ArrWrapper.decode(data);
    }

    function testMalformedOffset_U256EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(U256Arr.InvalidU256ArrLength.selector);
        u256ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ I8 ARRAY FUZZ TESTS ============

    function testFuzz_I8Array_RoundTrip(int8[] calldata values) public pure {
        int8[] memory memValues = new int8[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I8Arr.encode(memValues);
        (int8[] memory decoded, uint256 bytesRead) = I8Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_I8Array_EncodedSize(int8[] calldata values) public pure {
        int8[] memory memValues = new int8[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I8Arr.encode(memValues);
        uint256 size = I8Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_I8Array() public pure {
        int8[] memory value = new int8[](0);
        bytes memory encoded = I8Arr.encode(value);
        assertEq(encoded, hex"00");
        (int8[] memory decoded, uint256 bytesRead) = I8Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_I8Array() public {
        bytes memory data = hex"0801";
        vm.expectRevert();
        i8ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_I8Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        i8ArrWrapper.decode(data);
    }

    function testMalformedEmpty_I8Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        i8ArrWrapper.decode(data);
    }

    function testMalformedOffset_I8EncodedSize() public {
        bytes memory data = hex"0102";
        vm.expectRevert(I8Arr.InvalidI8ArrLength.selector);
        i8ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ I16 ARRAY FUZZ TESTS ============

    function testFuzz_I16Array_RoundTrip(int16[] calldata values) public pure {
        int16[] memory memValues = new int16[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I16Arr.encode(memValues);
        (int16[] memory decoded, uint256 bytesRead) = I16Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_I16Array_EncodedSize(
        int16[] calldata values
    ) public pure {
        int16[] memory memValues = new int16[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I16Arr.encode(memValues);
        uint256 size = I16Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_I16Array() public pure {
        int16[] memory value = new int16[](0);
        bytes memory encoded = I16Arr.encode(value);
        assertEq(encoded, hex"00");
        (int16[] memory decoded, uint256 bytesRead) = I16Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_I16Array() public {
        bytes memory data = hex"0411";
        vm.expectRevert();
        i16ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_I16Array() public {
        bytes memory data = hex"0411";
        vm.expectRevert();
        i16ArrWrapper.decode(data);
    }

    function testMalformedEmpty_I16Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        i16ArrWrapper.decode(data);
    }

    function testMalformedOffset_I16EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(I16Arr.InvalidI16ArrLength.selector);
        i16ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ I32 ARRAY FUZZ TESTS ============

    function testFuzz_I32Array_RoundTrip(int32[] calldata values) public pure {
        int32[] memory memValues = new int32[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I32Arr.encode(memValues);
        (int32[] memory decoded, uint256 bytesRead) = I32Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_I32Array_EncodedSize(
        int32[] calldata values
    ) public pure {
        int32[] memory memValues = new int32[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I32Arr.encode(memValues);
        uint256 size = I32Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_I32Array() public pure {
        int32[] memory value = new int32[](0);
        bytes memory encoded = I32Arr.encode(value);
        assertEq(encoded, hex"00");
        (int32[] memory decoded, uint256 bytesRead) = I32Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_I32Array() public {
        bytes memory data = hex"04111122";
        vm.expectRevert();
        i32ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_I32Array() public {
        bytes memory data = hex"04111122";
        vm.expectRevert();
        i32ArrWrapper.decode(data);
    }

    function testMalformedEmpty_I32Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        i32ArrWrapper.decode(data);
    }

    function testMalformedOffset_I32EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(I32Arr.InvalidI32ArrLength.selector);
        i32ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ I64 ARRAY FUZZ TESTS ============

    function testFuzz_I64Array_RoundTrip(int64[] calldata values) public pure {
        int64[] memory memValues = new int64[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I64Arr.encode(memValues);
        (int64[] memory decoded, uint256 bytesRead) = I64Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_I64Array_EncodedSize(
        int64[] calldata values
    ) public pure {
        int64[] memory memValues = new int64[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I64Arr.encode(memValues);
        uint256 size = I64Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_I64Array() public pure {
        int64[] memory value = new int64[](0);
        bytes memory encoded = I64Arr.encode(value);
        assertEq(encoded, hex"00");
        (int64[] memory decoded, uint256 bytesRead) = I64Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_I64Array() public {
        bytes memory data = hex"0411111111111111";
        vm.expectRevert();
        i64ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_I64Array() public {
        bytes memory data = hex"0411111111111111";
        vm.expectRevert();
        i64ArrWrapper.decode(data);
    }

    function testMalformedEmpty_I64Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        i64ArrWrapper.decode(data);
    }

    function testMalformedOffset_I64EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(I64Arr.InvalidI64ArrLength.selector);
        i64ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ I128 ARRAY FUZZ TESTS ============

    function testFuzz_I128Array_RoundTrip(
        int128[] calldata values
    ) public pure {
        int128[] memory memValues = new int128[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I128Arr.encode(memValues);
        (int128[] memory decoded, uint256 bytesRead) = I128Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_I128Array_EncodedSize(
        int128[] calldata values
    ) public pure {
        int128[] memory memValues = new int128[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I128Arr.encode(memValues);
        uint256 size = I128Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_I128Array() public pure {
        int128[] memory value = new int128[](0);
        bytes memory encoded = I128Arr.encode(value);
        assertEq(encoded, hex"00");
        (int128[] memory decoded, uint256 bytesRead) = I128Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_I128Array() public {
        bytes memory data = hex"04111111111111111111111111111111";
        vm.expectRevert();
        i128ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_I128Array() public {
        bytes memory data = hex"04111111111111111111111111111111";
        vm.expectRevert();
        i128ArrWrapper.decode(data);
    }

    function testMalformedEmpty_I128Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        i128ArrWrapper.decode(data);
    }

    function testMalformedOffset_I128EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(I128Arr.InvalidI128ArrLength.selector);
        i128ArrWrapper.encodedSizeAt(data, 0);
    }

    // ============ I256 ARRAY FUZZ TESTS ============

    function testFuzz_I256Array_RoundTrip(
        int256[] calldata values
    ) public pure {
        int256[] memory memValues = new int256[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I256Arr.encode(memValues);
        (int256[] memory decoded, uint256 bytesRead) = I256Arr.decode(encoded);
        assertEq(decoded.length, memValues.length);
        for (uint256 i = 0; i < decoded.length; i++) {
            assertEq(decoded[i], memValues[i]);
        }
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_I256Array_EncodedSize(
        int256[] calldata values
    ) public pure {
        int256[] memory memValues = new int256[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            memValues[i] = values[i];
        }
        bytes memory encoded = I256Arr.encode(memValues);
        uint256 size = I256Arr.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testEmpty_I256Array() public pure {
        int256[] memory value = new int256[](0);
        bytes memory encoded = I256Arr.encode(value);
        assertEq(encoded, hex"00");
        (int256[] memory decoded, uint256 bytesRead) = I256Arr.decode(encoded);
        assertEq(decoded.length, 0);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncated_I256Array() public {
        bytes
            memory data = hex"0411111111111111111111111111111111111111111111111111111111111111";
        vm.expectRevert();
        i256ArrWrapper.decode(data);
    }

    function testMalformedIncompleteElement_I256Array() public {
        bytes
            memory data = hex"0411111111111111111111111111111111111111111111111111111111111111";
        vm.expectRevert();
        i256ArrWrapper.decode(data);
    }

    function testMalformedEmpty_I256Array() public {
        bytes memory data = hex"";
        vm.expectRevert();
        i256ArrWrapper.decode(data);
    }

    function testMalformedOffset_I256EncodedSize() public {
        bytes memory data = hex"010203";
        vm.expectRevert(I256Arr.InvalidI256ArrLength.selector);
        i256ArrWrapper.encodedSizeAt(data, 0);
    }
}
