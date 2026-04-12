// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../../src/Utils/BytesUtils.sol";

contract BytesUtilsWrapper {
    function copy(
        bytes memory src,
        uint256 from,
        uint256 count
    ) external pure returns (bytes memory) {
        return BytesUtils.copy(src, from, count);
    }
}

contract BytesUtilsTest is Test {
    using BytesUtils for bytes;
    BytesUtilsWrapper wrapper;

    function setUp() public {
        wrapper = new BytesUtilsWrapper();
    }

    // ─── copy: happy paths ───────────────────────────────────────────────────

    function test_copy_fullArray() public pure {
        bytes memory src = hex"010203040506";
        bytes memory result = BytesUtils.copy(src, 0, 6);
        assertEq(result, src);
    }

    function test_copy_middleSegment() public pure {
        bytes memory src = hex"010203040506";
        bytes memory result = BytesUtils.copy(src, 2, 3);
        assertEq(result, hex"030405");
    }

    function test_copy_firstByte() public pure {
        bytes memory src = hex"aabbcc";
        bytes memory result = BytesUtils.copy(src, 0, 1);
        assertEq(result, hex"aa");
    }

    function test_copy_lastByte() public pure {
        bytes memory src = hex"aabbcc";
        bytes memory result = BytesUtils.copy(src, 2, 1);
        assertEq(result, hex"cc");
    }

    function test_copy_zeroCount() public pure {
        bytes memory src = hex"aabbcc";
        bytes memory result = BytesUtils.copy(src, 1, 0);
        assertEq(result.length, 0);
    }

    function test_copy_emptySourceZeroCount() public pure {
        bytes memory src = hex"";
        bytes memory result = BytesUtils.copy(src, 0, 0);
        assertEq(result.length, 0);
    }

    function test_copy_exactBoundary() public pure {
        // from + count == src.length (tight upper bound, must not revert)
        bytes memory src = hex"010203";
        bytes memory result = BytesUtils.copy(src, 1, 2); // 1+2 == 3 == src.length
        assertEq(result, hex"0203");
    }

    // ─── copy: revert paths ──────────────────────────────────────────────────

    function test_copy_revert_countExceedsLength() public {
        bytes memory src = hex"0102";
        vm.expectRevert(BytesUtils.InvalidBounds.selector);
        wrapper.copy(src, 0, 3);
    }

    function test_copy_revert_fromExceedsLength() public {
        bytes memory src = hex"0102";
        vm.expectRevert(BytesUtils.InvalidBounds.selector);
        wrapper.copy(src, 3, 0);
    }

    function test_copy_revert_fromPlusCountExceedsLength() public {
        bytes memory src = hex"010203";
        vm.expectRevert(BytesUtils.InvalidBounds.selector);
        wrapper.copy(src, 2, 2); // 2+2=4 > 3
    }

    function test_copy_revert_emptySourceNonZeroCount() public {
        bytes memory src = hex"";
        vm.expectRevert(BytesUtils.InvalidBounds.selector);
        wrapper.copy(src, 0, 1);
    }

    function test_copy_revert_overflow_fromPlusCount() public {
        // from + count overflows uint256 → Solidity 0.8 panics before our check,
        // but we verify the call reverts either way.
        bytes memory src = hex"01";
        vm.expectRevert();
        wrapper.copy(src, type(uint256).max, 1);
    }

    // ─── fuzz ────────────────────────────────────────────────────────────────

    function testFuzz_copy_validRange(
        bytes memory src,
        uint256 from,
        uint256 count
    ) public pure {
        vm.assume(src.length > 0);
        from = bound(from, 0, src.length - 1);
        count = bound(count, 0, src.length - from);

        bytes memory result = BytesUtils.copy(src, from, count);

        assertEq(result.length, count);
        for (uint256 i = 0; i < count; i++) {
            assertEq(result[i], src[from + i]);
        }
    }

    function testFuzz_copy_invalidRange_reverts(
        bytes memory src,
        uint256 from,
        uint256 count
    ) public {
        // Ensure from + count > src.length without wrapping
        vm.assume(from < type(uint256).max);
        vm.assume(count < type(uint256).max - from);
        vm.assume(from + count > src.length);

        vm.expectRevert(BytesUtils.InvalidBounds.selector);
        wrapper.copy(src, from, count);
    }
}
