// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {
    WeightLimit,
    unlimited,
    limited,
    LimitedParams
} from "../../../src/Xcm/v5/WeightLimit/WeightLimit.sol";
import {WeightLimitCodec as Codec} from "../../../src/Xcm/v5/WeightLimit/WeightLimitCodec.sol";
import {Weight} from "../../../src/Xcm/v5/Weight/Weight.sol";
import {Test} from "forge-std/Test.sol";

contract WeightLimitWrapper {
    function decode(
        bytes memory data
    ) external pure returns (WeightLimit memory) {
        (WeightLimit memory result, ) = Codec.decode(data);
        return result;
    }
}

contract WeightLimitTest is Test {
    WeightLimitWrapper private wrapper;

    function setUp() public {
        wrapper = new WeightLimitWrapper();
    }

    function _assertRoundTrip(
        WeightLimit memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        WeightLimit memory decoded = wrapper.decode(expected);
        assertEq(uint8(decoded.variant), uint8(value.variant));
        assertEq(decoded.payload, value.payload);
    }

    // Test Unlimited variant
    function testEncodeDecodeUnlimited() public view {
        _assertRoundTrip(unlimited(), hex"00");
    }

    // Test Limited variant with refTime 12, proofSize 34
    function testEncodeDecodeLimitedSmallWeight() public view {
        _assertRoundTrip(
            limited(
                LimitedParams({weight: Weight({refTime: 12, proofSize: 34})})
            ),
            hex"013088"
        );
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnInvalidVariant() public {
        vm.expectRevert();
        wrapper.decode(hex"02");
    }

    function testDecodeRevertsOnTruncatedLimited() public {
        vm.expectRevert();
        wrapper.decode(hex"01");
    }
}
