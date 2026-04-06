// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Address} from "../../src/Scale/Address/Address.sol";

contract AddressWrapper {
    function decode(bytes memory data) external pure returns (address) {
        return Address.decode(data);
    }
}

contract AddressTest is Test {
    AddressWrapper wrapper;

    function setUp() public {
        wrapper = new AddressWrapper();
    }

    function testFuzz_RoundTrip(address value) public pure {
        bytes memory encoded = Address.encode(value);
        assertEq(encoded.length, 20);
        assertEq(Address.decode(encoded), value);
    }

    function testFuzz_EncodingIsPackedData(address value) public pure {
        bytes memory encoded = Address.encode(value);
        // Verify it's packed in big-endian format (standard Solidity address format)
        assertEq(encoded, abi.encodePacked(value));
    }

    function testFuzz_EncodedSize(address value) public pure {
        bytes memory encoded = Address.encode(value);
        uint256 size = Address.encodedSizeAt(encoded, 0);
        assertEq(size, 20);
    }

    function testMalformedTruncated() public {
        bytes memory data = hex"01020304";
        vm.expectRevert();
        wrapper.decode(data);
    }

    function testMalformedEmpty() public {
        bytes memory data = hex"";
        vm.expectRevert();
        wrapper.decode(data);
    }
}
