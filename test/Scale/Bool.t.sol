// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Bool} from "../../src/Scale/Bool/Bool.sol";

contract BoolWrapper {
    function decode(bytes memory data) external pure returns (bool) {
        return Bool.decode(data);
    }

    function decodeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (bool) {
        return Bool.decodeAt(data, offset);
    }

    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) external pure returns (uint256) {
        return Bool.encodedSizeAt(data, offset);
    }
}

contract BoolTest is Test {
    BoolWrapper wrapper;

    function setUp() public {
        wrapper = new BoolWrapper();
    }

    function testFuzz_RoundTrip(bool value) public pure {
        bytes memory encoded = Bool.encode(value);
        assertEq(encoded.length, 1);
        assertEq(Bool.decode(encoded), value);
    }

    function testFuzz_EncodedFormat(bool value) public pure {
        bytes memory encoded = Bool.encode(value);
        if (value) {
            assertEq(encoded, hex"01");
        } else {
            assertEq(encoded, hex"00");
        }
    }

    function testFuzz_DecodeAt(bool value) public view {
        bytes memory encoded = Bool.encode(value);
        bytes memory padded = new bytes(10);
        for (uint256 i = 0; i < encoded.length; i++) {
            padded[i + 2] = encoded[i];
        }
        bool decoded = wrapper.decodeAt(padded, 2);
        assertEq(decoded, value);
    }

    function testFuzz_EncodedSizeAt(bool value) public view {
        bytes memory encoded = Bool.encode(value);
        uint256 size = wrapper.encodedSizeAt(encoded, 0);
        assertEq(size, 1);
    }

    function testMalformedEmpty() public {
        bytes memory data = hex"";
        vm.expectRevert();
        wrapper.decode(data);
    }

    function testMalformed_EncodedSizeAtInsufficientData() public {
        vm.expectRevert(Bool.InvalidBoolLength.selector);
        wrapper.encodedSizeAt(hex"", 0);
    }

    function testMalformed_EncodedSizeAtOffsetBeyondBounds() public {
        bytes memory data = hex"01";
        vm.expectRevert(Bool.InvalidBoolLength.selector);
        wrapper.encodedSizeAt(data, 1);
    }

    function testMalformed_DecodeAtInsufficientData() public {
        vm.expectRevert(Bool.InvalidBoolLength.selector);
        wrapper.decodeAt(hex"", 0);
    }

    function testMalformed_DecodeAtOffsetBeyondBounds() public {
        bytes memory data = hex"01";
        vm.expectRevert(Bool.InvalidBoolLength.selector);
        wrapper.decodeAt(data, 1);
    }
}
