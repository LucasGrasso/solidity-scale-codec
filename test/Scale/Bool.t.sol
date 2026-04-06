// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Bool} from "../../src/Scale/Bool/Bool.sol";

contract BoolWrapper {
    function decode(bytes memory data) external pure returns (bool) {
        return Bool.decode(data);
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

    function testMalformedEmpty() public {
        bytes memory data = hex"";
        vm.expectRevert();
        wrapper.decode(data);
    }
}
