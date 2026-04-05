// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Weight} from "../../../src/Xcm/v5/Weight/Weight.sol";
import {WeightCodec as Codec} from "../../../src/Xcm/v5/Weight/WeightCodec.sol";
import {Test} from "forge-std/Test.sol";

contract WeightWrapper {
    function decode(bytes memory data) external pure returns (Weight memory) {
        (Weight memory result, ) = Codec.decode(data);
        return result;
    }
}

contract WeightTest is Test {
    WeightWrapper private wrapper;

    function setUp() public {
        wrapper = new WeightWrapper();
    }

    function _assertRoundTrip(
        Weight memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        Weight memory decoded = wrapper.decode(expected);
        assertEq(decoded.refTime, value.refTime);
        assertEq(decoded.proofSize, value.proofSize);
    }

    // Test Weight with zero values
    function testEncodeDecodeZero() public view {
        _assertRoundTrip(Weight({refTime: 0, proofSize: 0}), hex"0000");
    }

    // Test Weight with small values (refTime: 12, proofSize: 34)
    function testEncodeDecodeSmall() public view {
        _assertRoundTrip(Weight({refTime: 12, proofSize: 34}), hex"3088");
    }

    // Test Weight with larger values
    function testEncodeDecodeLarge() public view {
        _assertRoundTrip(
            Weight({refTime: 1000000, proofSize: 2000000}),
            hex"02093d0002127a00"
        );
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnTruncatedInput() public {
        vm.expectRevert();
        wrapper.decode(hex"30");
    }
}
