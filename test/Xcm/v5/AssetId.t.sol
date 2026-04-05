// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetId} from "../../../src/Xcm/v5/AssetId/AssetId.sol";
import {parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {AssetIdCodec as Codec} from "../../../src/Xcm/v5/AssetId/AssetIdCodec.sol";
import {Test} from "forge-std/Test.sol";

contract AssetIdWrapper {
    function decode(
        bytes memory data
    ) external pure returns (AssetId memory assetId) {
        (assetId, ) = Codec.decode(data);
    }
}

contract AssetIdTest is Test {
    AssetIdWrapper private wrapper;

    function setUp() public {
        wrapper = new AssetIdWrapper();
    }

    function testEncodeDecodeParentLocation() public view {
        AssetId memory value = AssetId(parent());
        bytes memory expected = hex"0100";
        assertEq(Codec.encode(value), expected);
        assertEq(
            keccak256(abi.encode(wrapper.decode(expected))),
            keccak256(abi.encode(value))
        );
    }

    function testDecodeRevertsOnTruncatedPayload() public {
        vm.expectRevert();
        wrapper.decode(hex"01");
    }

    function testDecodeRevertsOnInvalidInteriorCount() public {
        vm.expectRevert();
        wrapper.decode(hex"0009");
    }
}
