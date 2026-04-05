// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {WildFungibility} from "../../../src/Xcm/v5/WildFungibility/WildFungibility.sol";
import {WildFungibilityCodec as Codec} from "../../../src/Xcm/v5/WildFungibility/WildFungibilityCodec.sol";
import {Test} from "forge-std/Test.sol";

contract WildFungibilityWrapper {
    function decode(bytes memory data) external pure returns (WildFungibility) {
        (WildFungibility result, ) = Codec.decode(data);
        return result;
    }
}

contract WildFungibilityTest is Test {
    WildFungibilityWrapper private wrapper;

    function setUp() public {
        wrapper = new WildFungibilityWrapper();
    }

    function _assertRoundTrip(
        WildFungibility value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        WildFungibility decoded = wrapper.decode(expected);
        assertEq(uint8(decoded), uint8(value));
    }

    // Test Fungible variant
    function testFungible() public view {
        WildFungibility value = WildFungibility.Fungible;
        _assertRoundTrip(value, hex"00");
    }

    // Test NonFungible variant
    function testNonFungible() public view {
        WildFungibility value = WildFungibility.NonFungible;
        _assertRoundTrip(value, hex"01");
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
}
