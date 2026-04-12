// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../../src/Utils/UnsignedUtils.sol";

contract UnsignedUtilsWrapper {
    function toU8(uint256 value) external pure returns (uint8) {
        return UnsignedUtils.toU8(value);
    }

    function toU16(uint256 value) external pure returns (uint16) {
        return UnsignedUtils.toU16(value);
    }

    function toU32(uint256 value) external pure returns (uint32) {
        return UnsignedUtils.toU32(value);
    }

    function toU64(uint256 value) external pure returns (uint64) {
        return UnsignedUtils.toU64(value);
    }

    function toU128(uint256 value) external pure returns (uint128) {
        return UnsignedUtils.toU128(value);
    }
}

contract UnsignedUtilsTest is Test {
    UnsignedUtilsWrapper wrapper;

    function setUp() public {
        wrapper = new UnsignedUtilsWrapper();
    }

    // ─── toU8 ────────────────────────────────────────────────────────────────

    function test_toU8_zero() public pure {
        assertEq(UnsignedUtils.toU8(0), 0);
    }

    function test_toU8_max() public pure {
        assertEq(UnsignedUtils.toU8(type(uint8).max), type(uint8).max);
    }

    function test_toU8_revert() public {
        uint256 over = uint256(type(uint8).max) + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                over,
                uint256(type(uint8).max)
            )
        );
        wrapper.toU8(over);
    }

    function testFuzz_toU8_valid(uint8 v) public pure {
        assertEq(UnsignedUtils.toU8(uint256(v)), v);
    }

    function testFuzz_toU8_invalid(uint256 v) public {
        vm.assume(v > type(uint8).max);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                v,
                uint256(type(uint8).max)
            )
        );
        wrapper.toU8(v);
    }

    // ─── toU16 ───────────────────────────────────────────────────────────────

    function test_toU16_zero() public pure {
        assertEq(UnsignedUtils.toU16(0), 0);
    }

    function test_toU16_max() public pure {
        assertEq(UnsignedUtils.toU16(type(uint16).max), type(uint16).max);
    }

    function test_toU16_revert() public {
        uint256 over = uint256(type(uint16).max) + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                over,
                uint256(type(uint16).max)
            )
        );
        wrapper.toU16(over);
    }

    function testFuzz_toU16_valid(uint16 v) public pure {
        assertEq(UnsignedUtils.toU16(uint256(v)), v);
    }

    function testFuzz_toU16_invalid(uint256 v) public {
        vm.assume(v > type(uint16).max);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                v,
                uint256(type(uint16).max)
            )
        );
        wrapper.toU16(v);
    }

    // ─── toU32 ───────────────────────────────────────────────────────────────

    function test_toU32_zero() public pure {
        assertEq(UnsignedUtils.toU32(0), 0);
    }

    function test_toU32_max() public pure {
        assertEq(UnsignedUtils.toU32(type(uint32).max), type(uint32).max);
    }

    function test_toU32_revert() public {
        uint256 over = uint256(type(uint32).max) + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                over,
                uint256(type(uint32).max)
            )
        );
        wrapper.toU32(over);
    }

    function testFuzz_toU32_valid(uint32 v) public pure {
        assertEq(UnsignedUtils.toU32(uint256(v)), v);
    }

    function testFuzz_toU32_invalid(uint256 v) public {
        vm.assume(v > type(uint32).max);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                v,
                uint256(type(uint32).max)
            )
        );
        wrapper.toU32(v);
    }

    // ─── toU64 ───────────────────────────────────────────────────────────────

    function test_toU64_zero() public pure {
        assertEq(UnsignedUtils.toU64(0), 0);
    }

    function test_toU64_max() public pure {
        assertEq(UnsignedUtils.toU64(type(uint64).max), type(uint64).max);
    }

    function test_toU64_revert() public {
        uint256 over = uint256(type(uint64).max) + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                over,
                uint256(type(uint64).max)
            )
        );
        wrapper.toU64(over);
    }

    function testFuzz_toU64_valid(uint64 v) public pure {
        assertEq(UnsignedUtils.toU64(uint256(v)), v);
    }

    function testFuzz_toU64_invalid(uint256 v) public {
        vm.assume(v > type(uint64).max);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                v,
                uint256(type(uint64).max)
            )
        );
        wrapper.toU64(v);
    }

    // ─── toU128 ──────────────────────────────────────────────────────────────

    function test_toU128_zero() public pure {
        assertEq(UnsignedUtils.toU128(0), 0);
    }

    function test_toU128_max() public pure {
        assertEq(UnsignedUtils.toU128(type(uint128).max), type(uint128).max);
    }

    function test_toU128_revert() public {
        uint256 over = uint256(type(uint128).max) + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                over,
                uint256(type(uint128).max)
            )
        );
        wrapper.toU128(over);
    }

    function testFuzz_toU128_valid(uint128 v) public pure {
        assertEq(UnsignedUtils.toU128(uint256(v)), v);
    }

    function testFuzz_toU128_invalid(uint256 v) public {
        vm.assume(v > type(uint128).max);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnsignedUtils.NumberTooLarge.selector,
                v,
                uint256(type(uint128).max)
            )
        );
        wrapper.toU128(v);
    }
}
