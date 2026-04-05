// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {
    Hint,
    HintVariant,
    assetClaimer,
    AssetClaimerParams
} from "../../../src/Xcm/v5/Hint/Hint.sol";
import {HintCodec as Codec} from "../../../src/Xcm/v5/Hint/HintCodec.sol";
import {Location, parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {Junctions, here} from "../../../src/Xcm/v5/Junctions/Junctions.sol";
import {Test} from "forge-std/Test.sol";

contract HintWrapper {
    function decode(bytes memory data) external pure returns (Hint memory) {
        (Hint memory result, ) = Codec.decode(data);
        return result;
    }
}

contract HintTest is Test {
    HintWrapper private wrapper;

    function setUp() public {
        wrapper = new HintWrapper();
    }

    function _assertRoundTrip(
        Hint memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        Hint memory decoded = wrapper.decode(expected);
        assertEq(uint8(decoded.variant), uint8(value.variant));
        assertEq(decoded.payload, value.payload);
    }

    // Test AssetClaimer variant with here location
    function testEncodeDecodeAssetClaimerHere() public view {
        _assertRoundTrip(
            assetClaimer(AssetClaimerParams({location: parent()})),
            hex"000100"
        );
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnInvalidVariant() public {
        vm.expectRevert();
        wrapper.decode(hex"01");
    }

    function testDecodeRevertsOnTruncatedLocation() public {
        vm.expectRevert();
        wrapper.decode(hex"00");
    }
}
