// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Bytes2} from "../../src/Scale/Bytes/Bytes2.sol";
import {Bytes4} from "../../src/Scale/Bytes/Bytes4.sol";
import {Bytes8} from "../../src/Scale/Bytes/Bytes8.sol";
import {Bytes16} from "../../src/Scale/Bytes/Bytes16.sol";
import {Bytes32} from "../../src/Scale/Bytes/Bytes32.sol";

contract BytesNWrapper {
    // Bytes2
    function encode2(bytes2 value) external pure returns (bytes memory) {
        return Bytes2.encode(value);
    }

    function decode2(bytes memory data) external pure returns (bytes2) {
        return Bytes2.decode(data);
    }

    function decodeAt2(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes2) {
        return Bytes2.decodeAt(data, offset);
    }

    function encodedSizeAt2(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes2.encodedSizeAt(data, offset);
    }

    // Bytes4
    function encode4(bytes4 value) external pure returns (bytes memory) {
        return Bytes4.encode(value);
    }

    function decode4(bytes memory data) external pure returns (bytes4) {
        return Bytes4.decode(data);
    }

    function decodeAt4(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes4) {
        return Bytes4.decodeAt(data, offset);
    }

    function encodedSizeAt4(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes4.encodedSizeAt(data, offset);
    }

    // Bytes8
    function encode8(bytes8 value) external pure returns (bytes memory) {
        return Bytes8.encode(value);
    }

    function decode8(bytes memory data) external pure returns (bytes8) {
        return Bytes8.decode(data);
    }

    function decodeAt8(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes8) {
        return Bytes8.decodeAt(data, offset);
    }

    function encodedSizeAt8(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes8.encodedSizeAt(data, offset);
    }

    // Bytes16
    function encode16(bytes16 value) external pure returns (bytes memory) {
        return Bytes16.encode(value);
    }

    function decode16(bytes memory data) external pure returns (bytes16) {
        return Bytes16.decode(data);
    }

    function decodeAt16(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes16) {
        return Bytes16.decodeAt(data, offset);
    }

    function encodedSizeAt16(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes16.encodedSizeAt(data, offset);
    }

    // Bytes32
    function encode32(bytes32 value) external pure returns (bytes memory) {
        return Bytes32.encode(value);
    }

    function decode32(bytes memory data) external pure returns (bytes32) {
        return Bytes32.decode(data);
    }

    function decodeAt32(
        bytes memory data,
        uint256 offset
    ) external pure returns (bytes32) {
        return Bytes32.decodeAt(data, offset);
    }

    function encodedSizeAt32(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bytes32.encodedSizeAt(data, offset);
    }
}

contract BytesNTest is Test {
    BytesNWrapper wrapper;

    function setUp() public {
        wrapper = new BytesNWrapper();
    }

    // ============================================================================
    // Bytes2 Tests
    // ============================================================================

    function testFuzz_Bytes2_RoundTrip(bytes2 value) public view {
        bytes memory encoded = wrapper.encode2(value);
        bytes2 decoded = wrapper.decode2(encoded);
        assertEq(decoded, value, "Bytes2 round-trip failed");
    }

    function testFuzz_Bytes2_EncodedSize(bytes2 value) public view {
        bytes memory encoded = wrapper.encode2(value);
        uint256 size = wrapper.encodedSizeAt2(encoded, 0);
        assertEq(size, 2, "Bytes2 encoded size should be 2");
    }

    function testFuzz_Bytes2_OffsetDecoding(
        bytes2 value,
        bytes memory prefix
    ) public view {
        vm.assume(prefix.length < 100);
        bytes memory encoded = wrapper.encode2(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes2 decoded = wrapper.decodeAt2(data, prefix.length);
        assertEq(decoded, value, "Bytes2 offset decoding failed");
    }

    function testFuzz_Bytes2_EncodingLength(bytes2 value) public view {
        bytes memory encoded = wrapper.encode2(value);
        assertEq(encoded.length, 2, "Bytes2 encoded length should be 2");
    }

    function testMalformed_Bytes2_Truncated() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        wrapper.decode2(hex"01");
    }

    function testMalformed_Bytes2_Empty() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        wrapper.decode2(hex"");
    }

    function testMalformed_Bytes2_EncodedSizeInsufficientData() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        wrapper.encodedSizeAt2(hex"01", 0);
    }

    function testMalformed_Bytes2_DecodeAtInsufficientData() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        wrapper.decodeAt2(hex"01", 0);
    }

    function testMalformed_Bytes2_DecodeAtOffsetBeyondBounds() public {
        vm.expectRevert(Bytes2.InvalidBytes2Length.selector);
        wrapper.decodeAt2(hex"0102", 1);
    }

    function test_Bytes2_KnownValues() public view {
        bytes2 value1 = 0x0102;
        bytes memory encoded1 = wrapper.encode2(value1);
        assertEq(encoded1, hex"0102", "Bytes2 encoding mismatch");
        assertEq(wrapper.decode2(encoded1), value1, "Bytes2 decoding mismatch");
    }

    // ============================================================================
    // Bytes4 Tests
    // ============================================================================

    function testFuzz_Bytes4_RoundTrip(bytes4 value) public view {
        bytes memory encoded = wrapper.encode4(value);
        bytes4 decoded = wrapper.decode4(encoded);
        assertEq(decoded, value, "Bytes4 round-trip failed");
    }

    function testFuzz_Bytes4_EncodedSize(bytes4 value) public view {
        bytes memory encoded = wrapper.encode4(value);
        uint256 size = wrapper.encodedSizeAt4(encoded, 0);
        assertEq(size, 4, "Bytes4 encoded size should be 4");
    }

    function testFuzz_Bytes4_OffsetDecoding(
        bytes4 value,
        bytes memory prefix
    ) public view {
        vm.assume(prefix.length < 100);
        bytes memory encoded = wrapper.encode4(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes4 decoded = wrapper.decodeAt4(data, prefix.length);
        assertEq(decoded, value, "Bytes4 offset decoding failed");
    }

    function testFuzz_Bytes4_EncodingLength(bytes4 value) public view {
        bytes memory encoded = wrapper.encode4(value);
        assertEq(encoded.length, 4, "Bytes4 encoded length should be 4");
    }

    function testMalformed_Bytes4_Truncated() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        wrapper.decode4(hex"010203");
    }

    function testMalformed_Bytes4_Empty() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        wrapper.decode4(hex"");
    }

    function testMalformed_Bytes4_EncodedSizeInsufficientData() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        wrapper.encodedSizeAt4(hex"010203", 0);
    }

    function testMalformed_Bytes4_DecodeAtInsufficientData() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        wrapper.decodeAt4(hex"010203", 0);
    }

    function testMalformed_Bytes4_DecodeAtOffsetBeyondBounds() public {
        vm.expectRevert(Bytes4.InvalidBytes4Length.selector);
        wrapper.decodeAt4(hex"01020304", 1);
    }

    function test_Bytes4_KnownValues() public view {
        bytes4 value1 = 0x01020304;
        bytes memory encoded1 = wrapper.encode4(value1);
        assertEq(encoded1, hex"01020304", "Bytes4 encoding mismatch");
        assertEq(wrapper.decode4(encoded1), value1, "Bytes4 decoding mismatch");
    }

    // ============================================================================
    // Bytes8 Tests
    // ============================================================================

    function testFuzz_Bytes8_RoundTrip(bytes8 value) public view {
        bytes memory encoded = wrapper.encode8(value);
        bytes8 decoded = wrapper.decode8(encoded);
        assertEq(decoded, value, "Bytes8 round-trip failed");
    }

    function testFuzz_Bytes8_EncodedSize(bytes8 value) public view {
        bytes memory encoded = wrapper.encode8(value);
        uint256 size = wrapper.encodedSizeAt8(encoded, 0);
        assertEq(size, 8, "Bytes8 encoded size should be 8");
    }

    function testFuzz_Bytes8_OffsetDecoding(
        bytes8 value,
        bytes memory prefix
    ) public view {
        vm.assume(prefix.length < 100);
        bytes memory encoded = wrapper.encode8(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes8 decoded = wrapper.decodeAt8(data, prefix.length);
        assertEq(decoded, value, "Bytes8 offset decoding failed");
    }

    function testFuzz_Bytes8_EncodingLength(bytes8 value) public view {
        bytes memory encoded = wrapper.encode8(value);
        assertEq(encoded.length, 8, "Bytes8 encoded length should be 8");
    }

    function testMalformed_Bytes8_Truncated() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        wrapper.decode8(hex"01020304050607");
    }

    function testMalformed_Bytes8_Empty() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        wrapper.decode8(hex"");
    }

    function testMalformed_Bytes8_EncodedSizeInsufficientData() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        wrapper.encodedSizeAt8(hex"01020304050607", 0);
    }

    function testMalformed_Bytes8_DecodeAtInsufficientData() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        wrapper.decodeAt8(hex"01020304050607", 0);
    }

    function testMalformed_Bytes8_DecodeAtOffsetBeyondBounds() public {
        vm.expectRevert(Bytes8.InvalidBytes8Length.selector);
        wrapper.decodeAt8(hex"0102030405060708", 1);
    }

    function test_Bytes8_KnownValues() public view {
        bytes8 value1 = 0x0102030405060708;
        bytes memory encoded1 = wrapper.encode8(value1);
        assertEq(encoded1, hex"0102030405060708", "Bytes8 encoding mismatch");
        assertEq(wrapper.decode8(encoded1), value1, "Bytes8 decoding mismatch");
    }

    // ============================================================================
    // Bytes16 Tests
    // ============================================================================

    function testFuzz_Bytes16_RoundTrip(bytes16 value) public view {
        bytes memory encoded = wrapper.encode16(value);
        bytes16 decoded = wrapper.decode16(encoded);
        assertEq(decoded, value, "Bytes16 round-trip failed");
    }

    function testFuzz_Bytes16_EncodedSize(bytes16 value) public view {
        bytes memory encoded = wrapper.encode16(value);
        uint256 size = wrapper.encodedSizeAt16(encoded, 0);
        assertEq(size, 16, "Bytes16 encoded size should be 16");
    }

    function testFuzz_Bytes16_OffsetDecoding(
        bytes16 value,
        bytes1 prefix
    ) public view {
        bytes memory encoded = wrapper.encode16(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes16 decoded = wrapper.decodeAt16(data, 1);
        assertEq(decoded, value, "Bytes16 offset decoding failed");
    }

    function testFuzz_Bytes16_EncodingLength(bytes16 value) public view {
        bytes memory encoded = wrapper.encode16(value);
        assertEq(encoded.length, 16, "Bytes16 encoded length should be 16");
    }

    function testMalformed_Bytes16_Truncated() public {
        bytes memory truncated = hex"0102030405060708090A0B0C0D0E0F";
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        wrapper.decode16(truncated);
    }

    function testMalformed_Bytes16_Empty() public {
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        wrapper.decode16(hex"");
    }

    function testMalformed_Bytes16_EncodedSizeInsufficientData() public {
        bytes memory insufficient = hex"0102030405060708090A0B0C0D0E0F";
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        wrapper.encodedSizeAt16(insufficient, 0);
    }

    function testMalformed_Bytes16_DecodeAtInsufficientData() public {
        bytes memory insufficient = hex"0102030405060708090A0B0C0D0E0F";
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        wrapper.decodeAt16(insufficient, 0);
    }

    function testMalformed_Bytes16_DecodeAtOffsetBeyondBounds() public {
        bytes16 value = 0x0102030405060708090A0B0C0D0E0F10;
        bytes memory encoded = wrapper.encode16(value);
        vm.expectRevert(Bytes16.InvalidBytes16Length.selector);
        wrapper.decodeAt16(encoded, 1);
    }

    function test_Bytes16_KnownValues() public view {
        bytes16 value1 = 0x0102030405060708090A0B0C0D0E0F10;
        bytes memory encoded1 = wrapper.encode16(value1);
        assertEq(
            encoded1,
            hex"0102030405060708090A0B0C0D0E0F10",
            "Bytes16 encoding mismatch"
        );
        assertEq(
            wrapper.decode16(encoded1),
            value1,
            "Bytes16 decoding mismatch"
        );
    }

    // ============================================================================
    // Bytes32 Tests
    // ============================================================================

    function testFuzz_Bytes32_RoundTrip(bytes32 value) public view {
        bytes memory encoded = wrapper.encode32(value);
        bytes32 decoded = wrapper.decode32(encoded);
        assertEq(decoded, value, "Bytes32 round-trip failed");
    }

    function testFuzz_Bytes32_EncodedSize(bytes32 value) public view {
        bytes memory encoded = wrapper.encode32(value);
        uint256 size = wrapper.encodedSizeAt32(encoded, 0);
        assertEq(size, 32, "Bytes32 encoded size should be 32");
    }

    function testFuzz_Bytes32_OffsetDecoding(
        bytes32 value,
        bytes1 prefix
    ) public view {
        bytes memory encoded = wrapper.encode32(value);
        bytes memory data = abi.encodePacked(prefix, encoded);
        bytes32 decoded = wrapper.decodeAt32(data, 1);
        assertEq(decoded, value, "Bytes32 offset decoding failed");
    }

    function testFuzz_Bytes32_EncodingLength(bytes32 value) public view {
        bytes memory encoded = wrapper.encode32(value);
        assertEq(encoded.length, 32, "Bytes32 encoded length should be 32");
    }

    function testMalformed_Bytes32_Truncated() public {
        bytes
            memory truncated = hex"0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        wrapper.decode32(truncated);
    }

    function testMalformed_Bytes32_Empty() public {
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        wrapper.decode32(hex"");
    }

    function testMalformed_Bytes32_EncodedSizeInsufficientData() public {
        bytes
            memory insufficient = hex"0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        wrapper.encodedSizeAt32(insufficient, 0);
    }

    function testMalformed_Bytes32_DecodeAtInsufficientData() public {
        bytes
            memory insufficient = hex"0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        wrapper.decodeAt32(insufficient, 0);
    }

    function testMalformed_Bytes32_DecodeAtOffsetBeyondBounds() public {
        bytes32 value = 0x0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20;
        bytes memory encoded = wrapper.encode32(value);
        vm.expectRevert(Bytes32.InvalidBytes32Length.selector);
        wrapper.decodeAt32(encoded, 1);
    }

    function test_Bytes32_KnownValues() public view {
        bytes32 value1 = 0x0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20;
        bytes memory encoded1 = wrapper.encode32(value1);
        assertEq(
            encoded1,
            hex"0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20",
            "Bytes32 encoding mismatch"
        );
        assertEq(
            wrapper.decode32(encoded1),
            value1,
            "Bytes32 decoding mismatch"
        );
    }
}
