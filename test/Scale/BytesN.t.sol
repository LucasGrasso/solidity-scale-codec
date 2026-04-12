// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Bytes2} from "../../src/Scale/Bytes/Bytes2.sol";
import {Bytes4} from "../../src/Scale/Bytes/Bytes4.sol";
import {Bytes8} from "../../src/Scale/Bytes/Bytes8.sol";
import {Bytes16} from "../../src/Scale/Bytes/Bytes16.sol";
import {Bytes32} from "../../src/Scale/Bytes/Bytes32.sol";

contract Bytes2Wrapper {
    function decode(bytes memory data) external pure returns (bytes2) {
        return Bytes2.decode(data);
    }

    function decodeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes2) {
        return Bytes2.decodeAt(data, offset);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes2.encodedSizeAt(data, offset);
    }
}

contract Bytes4Wrapper {
    function decode(bytes memory data) external pure returns (bytes4) {
        return Bytes4.decode(data);
    }

    function decodeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes4) {
        return Bytes4.decodeAt(data, offset);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes4.encodedSizeAt(data, offset);
    }
}

contract Bytes8Wrapper {
    function decode(bytes memory data) external pure returns (bytes8) {
        return Bytes8.decode(data);
    }

    function decodeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes8) {
        return Bytes8.decodeAt(data, offset);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes8.encodedSizeAt(data, offset);
    }
}

contract Bytes16Wrapper {
    function decode(bytes memory data) external pure returns (bytes16) {
        return Bytes16.decode(data);
    }

    function decodeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes16) {
        return Bytes16.decodeAt(data, offset);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes16.encodedSizeAt(data, offset);
    }
}

contract Bytes32Wrapper {
    function decode(bytes memory data) external pure returns (bytes32) {
        return Bytes32.decode(data);
    }

    function decodeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes32) {
        return Bytes32.decodeAt(data, offset);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes32.encodedSizeAt(data, offset);
    }
}

contract BytesNTest is Test {
    Bytes2Wrapper bytes2Wrapper;
    Bytes4Wrapper bytes4Wrapper;
    Bytes8Wrapper bytes8Wrapper;
    Bytes16Wrapper bytes16Wrapper;
    Bytes32Wrapper bytes32Wrapper;

    function setUp() public {
        bytes2Wrapper = new Bytes2Wrapper();
        bytes4Wrapper = new Bytes4Wrapper();
        bytes8Wrapper = new Bytes8Wrapper();
        bytes16Wrapper = new Bytes16Wrapper();
        bytes32Wrapper = new Bytes32Wrapper();
    }

    // ============================================================================
    // Bytes2 Tests
    // ============================================================================

    function testFuzz_Bytes2_RoundTrip(bytes2 value) public pure {
        bytes memory encoded = Bytes2.encode(value);
        bytes2 decoded = Bytes2.decode(encoded);
        assertEq(decoded, value, "Bytes2 round-trip failed");
    }

    function testFuzz_Bytes2_EncodedSize(bytes2 value) public pure {
        bytes memory encoded = Bytes2.encode(value);
        uint256 size = Bytes2.encodedSizeAt(encoded, 0);
        assertEq(size, 2, "Bytes2 encoded size should be 2");
    }

    function testFuzz_Bytes2_OffsetDecoding(
        bytes2 value,
        bytes memory prefix
    ) public pure {
        bytes memory encoded = Bytes2.encode(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes2 decoded = Bytes2.decodeAt(data, prefix.length);
        assertEq(decoded, value, "Bytes2 offset decoding failed");
    }

    function testFuzz_Bytes2_EncodingLength(bytes2 value) public pure {
        bytes memory encoded = Bytes2.encode(value);
        assertEq(encoded.length, 2, "Bytes2 encoded length should be 2");
    }

    function testMalformed_Bytes2_Truncated() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        bytes2Wrapper.decode(hex"01");
    }

    function testMalformed_Bytes2_Empty() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        bytes2Wrapper.decode(hex"");
    }

    function testMalformed_Bytes2_EncodedSizeInsufficientData() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        bytes2Wrapper.encodedSizeAt(hex"01", 0);
    }

    function testMalformed_Bytes2_DecodeAtInsufficientData() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        bytes2Wrapper.decodeAt(hex"01", 0);
    }

    function testMalformed_Bytes2_DecodeAtOffsetBeyondBounds() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        bytes2Wrapper.decodeAt(hex"0102", 1);
    }

    function test_Bytes2_KnownValues() public pure {
        bytes2 value1 = 0x0102;
        bytes memory encoded1 = Bytes2.encode(value1);
        assertEq(encoded1, hex"0102", "Bytes2 encoding mismatch");
        assertEq(Bytes2.decode(encoded1), value1, "Bytes2 decoding mismatch");
    }

    // ============================================================================
    // Bytes4 Tests
    // ============================================================================

    function testFuzz_Bytes4_RoundTrip(bytes4 value) public pure {
        bytes memory encoded = Bytes4.encode(value);
        bytes4 decoded = Bytes4.decode(encoded);
        assertEq(decoded, value, "Bytes4 round-trip failed");
    }

    function testFuzz_Bytes4_EncodedSize(bytes4 value) public pure {
        bytes memory encoded = Bytes4.encode(value);
        uint256 size = Bytes4.encodedSizeAt(encoded, 0);
        assertEq(size, 4, "Bytes4 encoded size should be 4");
    }

    function testFuzz_Bytes4_OffsetDecoding(
        bytes4 value,
        bytes memory prefix
    ) public pure {
        bytes memory encoded = Bytes4.encode(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes4 decoded = Bytes4.decodeAt(data, prefix.length);
        assertEq(decoded, value, "Bytes4 offset decoding failed");
    }

    function testFuzz_Bytes4_EncodingLength(bytes4 value) public pure {
        bytes memory encoded = Bytes4.encode(value);
        assertEq(encoded.length, 4, "Bytes4 encoded length should be 4");
    }

    function testMalformed_Bytes4_Truncated() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        bytes4Wrapper.decode(hex"010203");
    }

    function testMalformed_Bytes4_Empty() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        bytes4Wrapper.decode(hex"");
    }

    function testMalformed_Bytes4_EncodedSizeInsufficientData() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        bytes4Wrapper.encodedSizeAt(hex"010203", 0);
    }

    function testMalformed_Bytes4_DecodeAtInsufficientData() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        bytes4Wrapper.decodeAt(hex"010203", 0);
    }

    function testMalformed_Bytes4_DecodeAtOffsetBeyondBounds() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        bytes4Wrapper.decodeAt(hex"01020304", 1);
    }

    function test_Bytes4_KnownValues() public pure {
        bytes4 value1 = 0x01020304;
        bytes memory encoded1 = Bytes4.encode(value1);
        assertEq(encoded1, hex"01020304", "Bytes4 encoding mismatch");
        assertEq(Bytes4.decode(encoded1), value1, "Bytes4 decoding mismatch");
    }

    // ============================================================================
    // Bytes8 Tests
    // ============================================================================

    function testFuzz_Bytes8_RoundTrip(bytes8 value) public pure {
        bytes memory encoded = Bytes8.encode(value);
        bytes8 decoded = Bytes8.decode(encoded);
        assertEq(decoded, value, "Bytes8 round-trip failed");
    }

    function testFuzz_Bytes8_EncodedSize(bytes8 value) public pure {
        bytes memory encoded = Bytes8.encode(value);
        uint256 size = Bytes8.encodedSizeAt(encoded, 0);
        assertEq(size, 8, "Bytes8 encoded size should be 8");
    }

    function testFuzz_Bytes8_OffsetDecoding(
        bytes8 value,
        bytes memory prefix
    ) public pure {
        bytes memory encoded = Bytes8.encode(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes8 decoded = Bytes8.decodeAt(data, prefix.length);
        assertEq(decoded, value, "Bytes8 offset decoding failed");
    }

    function testFuzz_Bytes8_EncodingLength(bytes8 value) public pure {
        bytes memory encoded = Bytes8.encode(value);
        assertEq(encoded.length, 8, "Bytes8 encoded length should be 8");
    }

    function testMalformed_Bytes8_Truncated() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        bytes8Wrapper.decode(hex"01020304050607");
    }

    function testMalformed_Bytes8_Empty() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        bytes8Wrapper.decode(hex"");
    }

    function testMalformed_Bytes8_EncodedSizeInsufficientData() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        bytes8Wrapper.encodedSizeAt(hex"01020304050607", 0);
    }

    function testMalformed_Bytes8_DecodeAtInsufficientData() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        bytes8Wrapper.decodeAt(hex"01020304050607", 0);
    }

    function testMalformed_Bytes8_DecodeAtOffsetBeyondBounds() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        bytes8Wrapper.decodeAt(hex"0102030405060708", 1);
    }

    function test_Bytes8_KnownValues() public pure {
        bytes8 value1 = 0x0102030405060708;
        bytes memory encoded1 = Bytes8.encode(value1);
        assertEq(encoded1, hex"0102030405060708", "Bytes8 encoding mismatch");
        assertEq(Bytes8.decode(encoded1), value1, "Bytes8 decoding mismatch");
    }

    // ============================================================================
    // Bytes16 Tests
    // ============================================================================

    function testFuzz_Bytes16_RoundTrip(bytes16 value) public pure {
        bytes memory encoded = Bytes16.encode(value);
        bytes16 decoded = Bytes16.decode(encoded);
        assertEq(decoded, value, "Bytes16 round-trip failed");
    }

    function testFuzz_Bytes16_EncodedSize(bytes16 value) public pure {
        bytes memory encoded = Bytes16.encode(value);
        uint256 size = Bytes16.encodedSizeAt(encoded, 0);
        assertEq(size, 16, "Bytes16 encoded size should be 16");
    }

    function testFuzz_Bytes16_OffsetDecoding(
        bytes16 value,
        bytes1 prefix
    ) public pure {
        bytes memory encoded = Bytes16.encode(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes16 decoded = Bytes16.decodeAt(data, 1);
        assertEq(decoded, value, "Bytes16 offset decoding failed");
    }

    function testFuzz_Bytes16_EncodingLength(bytes16 value) public pure {
        bytes memory encoded = Bytes16.encode(value);
        assertEq(encoded.length, 16, "Bytes16 encoded length should be 16");
    }

    function testMalformed_Bytes16_Truncated() public {
        bytes memory truncated = hex"0102030405060708090A0B0C0D0E0F";
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        bytes16Wrapper.decode(truncated);
    }

    function testMalformed_Bytes16_Empty() public {
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        bytes16Wrapper.decode(hex"");
    }

    function testMalformed_Bytes16_EncodedSizeInsufficientData() public {
        bytes memory insufficient = hex"0102030405060708090A0B0C0D0E0F";
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        bytes16Wrapper.encodedSizeAt(insufficient, 0);
    }

    function testMalformed_Bytes16_DecodeAtInsufficientData() public {
        bytes memory insufficient = hex"0102030405060708090A0B0C0D0E0F";
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        bytes16Wrapper.decodeAt(insufficient, 0);
    }

    function testMalformed_Bytes16_DecodeAtOffsetBeyondBounds() public {
        bytes16 value = 0x0102030405060708090A0B0C0D0E0F10;
        bytes memory encoded = Bytes16.encode(value);
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        bytes16Wrapper.decodeAt(encoded, 1);
    }

    function test_Bytes16_KnownValues() public pure {
        bytes16 value1 = 0x0102030405060708090A0B0C0D0E0F10;
        bytes memory encoded1 = Bytes16.encode(value1);
        assertEq(
            encoded1,
            hex"0102030405060708090A0B0C0D0E0F10",
            "Bytes16 encoding mismatch"
        );
        assertEq(Bytes16.decode(encoded1), value1, "Bytes16 decoding mismatch");
    }

    // ============================================================================
    // Bytes32 Tests
    // ============================================================================

    function testFuzz_Bytes32_RoundTrip(bytes32 value) public pure {
        bytes memory encoded = Bytes32.encode(value);
        bytes32 decoded = Bytes32.decode(encoded);
        assertEq(decoded, value, "Bytes32 round-trip failed");
    }

    function testFuzz_Bytes32_EncodedSize(bytes32 value) public pure {
        bytes memory encoded = Bytes32.encode(value);
        uint256 size = Bytes32.encodedSizeAt(encoded, 0);
        assertEq(size, 32, "Bytes32 encoded size should be 32");
    }

    function testFuzz_Bytes32_OffsetDecoding(
        bytes32 value,
        bytes1 prefix
    ) public pure {
        bytes memory encoded = Bytes32.encode(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes32 decoded = Bytes32.decodeAt(data, 1);
        assertEq(decoded, value, "Bytes32 offset decoding failed");
    }

    function testFuzz_Bytes32_EncodingLength(bytes32 value) public pure {
        bytes memory encoded = Bytes32.encode(value);
        assertEq(encoded.length, 32, "Bytes32 encoded length should be 32");
    }

    function testMalformed_Bytes32_Truncated() public {
        bytes
            memory truncated = hex"0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        bytes32Wrapper.decode(truncated);
    }

    function testMalformed_Bytes32_Empty() public {
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        bytes32Wrapper.decode(hex"");
    }

    function testMalformed_Bytes32_EncodedSizeInsufficientData() public {
        bytes
            memory insufficient = hex"0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        bytes32Wrapper.encodedSizeAt(insufficient, 0);
    }

    function testMalformed_Bytes32_DecodeAtInsufficientData() public {
        bytes
            memory insufficient = hex"0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        bytes32Wrapper.decodeAt(insufficient, 0);
    }

    function testMalformed_Bytes32_DecodeAtOffsetBeyondBounds() public {
        bytes32 value = 0x0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20;
        bytes memory encoded = Bytes32.encode(value);
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        bytes32Wrapper.decodeAt(encoded, 1);
    }

    function test_Bytes32_KnownValues() public pure {
        bytes32 value1 = 0x0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20;
        bytes memory encoded1 = Bytes32.encode(value1);
        assertEq(
            encoded1,
            hex"0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20",
            "Bytes32 encoding mismatch"
        );
        assertEq(Bytes32.decode(encoded1), value1, "Bytes32 decoding mismatch");
    }
}
