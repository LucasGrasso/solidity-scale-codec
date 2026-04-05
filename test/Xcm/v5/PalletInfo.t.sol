// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {PalletInfo} from "../../../src/Xcm/v5/PalletInfo/PalletInfo.sol";
import {PalletInfoCodec as Codec} from "../../../src/Xcm/v5/PalletInfo/PalletInfoCodec.sol";
import {Test} from "forge-std/Test.sol";

contract PalletInfoWrapper {
    function decode(
        bytes memory data
    ) external pure returns (PalletInfo memory) {
        (PalletInfo memory result, ) = Codec.decode(data);
        return result;
    }
}

contract PalletInfoTest is Test {
    PalletInfoWrapper private wrapper;

    function setUp() public {
        wrapper = new PalletInfoWrapper();
    }

    function _assertRoundTrip(
        PalletInfo memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        PalletInfo memory decoded = wrapper.decode(expected);
        assertEq(decoded.index, value.index);
        assertEq(decoded.name, value.name);
        assertEq(decoded.moduleName, value.moduleName);
        assertEq(decoded.major, value.major);
        assertEq(decoded.minor, value.minor);
        assertEq(decoded.patch, value.patch);
    }

    // Test with empty names
    function testEncodeDecodeEmptyNames() public view {
        PalletInfo memory info = PalletInfo({
            index: 0,
            name: "",
            moduleName: "",
            major: 0,
            minor: 0,
            patch: 0
        });
        _assertRoundTrip(info, hex"000000000000");
    }

    // Test with short names
    function testEncodeDecodeWithNames() public view {
        PalletInfo memory info = PalletInfo({
            index: 10,
            name: "balances",
            moduleName: "pallet_balances",
            major: 1,
            minor: 2,
            patch: 3
        });
        _assertRoundTrip(
            info,
            hex"282062616c616e6365733c70616c6c65745f62616c616e63657304080c"
        );
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnTruncatedIndex() public {
        vm.expectRevert();
        wrapper.decode(hex"0500");
    }

    function testDecodeRevertsOnTruncatedName() public {
        vm.expectRevert();
        wrapper.decode(hex"050000000105");
    }
}
