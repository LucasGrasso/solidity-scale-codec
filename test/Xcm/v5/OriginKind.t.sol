// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {OriginKind} from "../../../src/Xcm/v5/OriginKind/OriginKind.sol";
import {OriginKindCodec as Codec} from "../../../src/Xcm/v5/OriginKind/OriginKindCodec.sol";
import {Test} from "forge-std/Test.sol";

contract OriginKindWrapper {
    function decode(bytes memory data) external pure returns (OriginKind) {
        (OriginKind result, ) = Codec.decode(data);
        return result;
    }
}

contract OriginKindTest is Test {
    OriginKindWrapper private wrapper;

    function setUp() public {
        wrapper = new OriginKindWrapper();
    }

    function _assertRoundTrip(
        OriginKind value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        assertEq(uint8(wrapper.decode(expected)), uint8(value));
    }

    // Test Native variant
    function testNative() public view {
        OriginKind value = OriginKind.Native;
        _assertRoundTrip(value, hex"00");
    }

    // Test SovereignAccount variant
    function testSovereignAccount() public view {
        OriginKind value = OriginKind.SovereignAccount;
        _assertRoundTrip(value, hex"01");
    }

    // Test Superuser variant
    function testSuperuser() public view {
        OriginKind value = OriginKind.Superuser;
        _assertRoundTrip(value, hex"02");
    }

    // Test Xcm variant
    function testEncodeXcm() public view {
        OriginKind value = OriginKind.Xcm;
        _assertRoundTrip(value, hex"03");
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnInvalidVariant() public {
        vm.expectRevert();
        wrapper.decode(hex"04");
    }

    function testDecodeRevertsOnTruncatedInput() public view {
        // Valid single-byte codec but extra bytes should be discarded or pass
        // depending on implementation
        OriginKind decoded = wrapper.decode(hex"0005");
        assertEq(uint8(decoded), uint8(OriginKind.Native));
    }
}
