// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {
    AssetFilter,
    AssetFilterVariant,
    definite,
    wild,
    DefiniteParams,
    WildParams
} from "../../../src/Xcm/v5/AssetFilter/AssetFilter.sol";
import {AssetFilterCodec as Codec} from "../../../src/Xcm/v5/AssetFilter/AssetFilterCodec.sol";
import {Assets} from "../../../src/Xcm/v5/Assets/Assets.sol";
import {Asset} from "../../../src/Xcm/v5/Asset/Asset.sol";
import {AssetId} from "../../../src/Xcm/v5/AssetId/AssetId.sol";
import {
    Fungibility,
    fungible,
    FungibleParams
} from "../../../src/Xcm/v5/Fungibility/Fungibility.sol";
import {
    WildAsset,
    allOf,
    AllOfParams
} from "../../../src/Xcm/v5/WildAsset/WildAsset.sol";
import {WildFungibility} from "../../../src/Xcm/v5/WildFungibility/WildFungibility.sol";
import {Location, parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {Test} from "forge-std/Test.sol";

contract AssetFilterWrapper {
    function decode(
        bytes memory data
    ) external pure returns (AssetFilter memory) {
        (AssetFilter memory result, ) = Codec.decode(data);
        return result;
    }
}

contract AssetFilterTest is Test {
    AssetFilterWrapper private wrapper;

    function setUp() public {
        wrapper = new AssetFilterWrapper();
    }

    function _assertRoundTrip(
        AssetFilter memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        AssetFilter memory decoded = wrapper.decode(expected);
        assertEq(uint8(decoded.variant), uint8(value.variant));
        assertEq(decoded.payload, value.payload);
    }

    // Test Definite variant with one fungible asset
    // Encoder: asset_filter_definite: 000401000003008c8647
    function testEncodeDecodeDefinite() public view {
        Asset[] memory assetArray = new Asset[](1);
        assetArray[0] = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1200000000}))
        });

        Assets memory assetsStruct;
        assetsStruct.items = assetArray;

        _assertRoundTrip(
            definite(DefiniteParams({assets: assetsStruct})),
            hex"000401000003008c8647"
        );
    }

    // Test Wild variant with AllOf(parent, Fungible)
    // Encoder: asset_filter_wild: 0101010000
    function testEncodeDecodeWild() public view {
        _assertRoundTrip(
            wild(
                WildParams({
                    wildAsset: allOf(
                        AllOfParams({
                            id: AssetId(parent()),
                            fun: WildFungibility.Fungible
                        })
                    )
                })
            ),
            hex"0101010000"
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

    function testDecodeRevertsOnTruncatedWild() public {
        vm.expectRevert();
        wrapper.decode(hex"01");
    }
}
