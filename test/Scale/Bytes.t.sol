// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Bytes} from "../../src/Scale/Bytes/Bytes.sol";
import {Compact} from "../../src/Scale/Compact.sol";

contract BytesWrapper {
    function decode(
        bytes memory data
    ) external pure returns (bytes memory, uint256) {
        return Bytes.decodeAt(data, 0);
    }
}

contract BytesTest is Test {
    BytesWrapper wrapper;

    function setUp() public {
        wrapper = new BytesWrapper();
    }

    function testFuzz_RoundTrip(bytes memory value) public pure {
        vm.assume(value.length < 1000); // Performance limit
        bytes memory encoded = Bytes.encode(value);
        (bytes memory decoded, uint256 bytesRead) = Bytes.decode(encoded);
        assertEq(decoded, value);
        assertEq(bytesRead, encoded.length);
    }

    function testFuzz_EncodedSize(bytes memory value) public pure {
        vm.assume(value.length < 1000); // Performance limit
        bytes memory encoded = Bytes.encode(value);
        uint256 size = Bytes.encodedSizeAt(encoded, 0);
        assertEq(size, encoded.length);
    }

    function testFuzz_CompactPrefixSize(bytes memory value) public pure {
        vm.assume(value.length < 10000);
        bytes memory encoded = Bytes.encode(value);
        // At least 1 byte for compact, plus the data
        assertGe(encoded.length, value.length);
        assertLe(encoded.length, value.length + 4); // Compact is max 4 bytes
    }

    function testEmpty() public pure {
        bytes memory value = hex"";
        bytes memory encoded = Bytes.encode(value);
        assertEq(encoded, hex"00");
        (bytes memory decoded, uint256 bytesRead) = Bytes.decode(encoded);
        assertEq(decoded, value);
        assertEq(bytesRead, 1);
    }

    function testMalformedTruncatedLength() public {
        bytes memory data = hex"280102030405";
        vm.expectRevert();
        wrapper.decode(data);
    }

    function testMalformedEmpty() public {
        bytes memory data = hex"";
        vm.expectRevert();
        wrapper.decode(data);
    }

    function testOffsetDecoding() public pure {
        bytes memory data = hex"aabbcc04ff";
        (bytes memory decoded, uint256 bytesRead) = Bytes.decodeAt(data, 3);
        assertEq(decoded, hex"ff");
        assertEq(bytesRead, 2);
    }
}
