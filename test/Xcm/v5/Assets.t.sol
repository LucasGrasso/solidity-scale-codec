// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Assets, fromAssets} from "../../../src/Xcm/v5/Assets/Assets.sol";
import {AssetId} from "../../../src/Xcm/v5/AssetId/AssetId.sol";
import {AssetsCodec as Codec} from "../../../src/Xcm/v5/Assets/AssetsCodec.sol";
import {Asset} from "../../../src/Xcm/v5/Asset/Asset.sol";
import {Test} from "forge-std/Test.sol";
import {parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {fungible, FungibleParams} from "../../../src/Xcm/v5/Fungibility/Fungibility.sol";

contract AssetsWrapper {
    function decode(bytes memory data) external pure returns (Assets memory) {
        (Assets memory result, ) = Codec.decode(data);
        return result;
    }
}

contract AssetsTest is Test {
    AssetsWrapper private wrapper;

    function setUp() public {
        wrapper = new AssetsWrapper();
    }

    function _assertRoundTrip(
        Assets memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        Assets memory decoded = wrapper.decode(expected);
        assertEq(decoded.items.length, value.items.length);
    }

    // Test empty assets array
    function testEncodeDecodeEmpty() public view {
        Asset[] memory items = new Asset[](0);
        _assertRoundTrip(fromAssets(items), hex"00");
    }

    // Test with one asset (from encoder output: 0401000003008c8647)
    // This represents a single asset encoded
    function testEncodeDecodeSingleAsset() public view {
        // Single asset roundtrip test
        Asset[] memory items = new Asset[](1);
        items[0] = Asset({
            id: AssetId({location: parent()}),
            fungibility: fungible(FungibleParams({amount: 1200000000}))
        });
        Assets memory assets = fromAssets(items);
        _assertRoundTrip(assets, hex"0401000003008c8647");
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnTruncatedCount() public {
        // Valid count prefix but no asset data
        vm.expectRevert();
        wrapper.decode(hex"04");
    }

    function testDecodeRevertsOnTruncatedAsset() public {
        // Count of 1 but no asset data
        vm.expectRevert();
        wrapper.decode(hex"01");
    }
}
