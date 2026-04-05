// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {
    WildAsset,
    all,
    allOf,
    allCounted,
    allOfCounted,
    AllOfParams,
    AllCountedParams,
    AllOfCountedParams
} from "../../../src/Xcm/v5/WildAsset/WildAsset.sol";
import {WildAssetCodec as Codec} from "../../../src/Xcm/v5/WildAsset/WildAssetCodec.sol";
import {AssetId} from "../../../src/Xcm/v5/AssetId/AssetId.sol";
import {parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {WildFungibility} from "../../../src/Xcm/v5/WildFungibility/WildFungibility.sol";
import {Test} from "forge-std/Test.sol";

contract WildAssetWrapper {
    function decode(
        bytes memory data
    ) external pure returns (WildAsset memory) {
        (WildAsset memory result, ) = Codec.decode(data);
        return result;
    }
}

contract WildAssetTest is Test {
    WildAssetWrapper private wrapper;

    AssetId private TEST_ASSET_ID = AssetId(parent());

    function setUp() public {
        wrapper = new WildAssetWrapper();
    }

    function _assertRoundTrip(
        WildAsset memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        WildAsset memory decoded = wrapper.decode(expected);
        assertEq(uint8(decoded.variant), uint8(value.variant));
        assertEq(decoded.payload, value.payload);
    }

    // Test All variant
    function testEncodeDecodeAll() public view {
        _assertRoundTrip(all(), hex"00");
    }

    // Test AllOf variant
    function testEncodeDecodeAllOf() public view {
        _assertRoundTrip(
            allOf(
                AllOfParams({id: TEST_ASSET_ID, fun: WildFungibility.Fungible})
            ),
            hex"01010000"
        );
    }

    // Test AllCounted variant
    function testEncodeDecodeAllCounted() public view {
        _assertRoundTrip(allCounted(AllCountedParams({count: 2})), hex"0208");
    }

    // Test AllOfCounted variant
    function testEncodeDecodeAllOfCounted() public view {
        _assertRoundTrip(
            allOfCounted(
                AllOfCountedParams({
                    id: AssetId(parent()),
                    fun: WildFungibility.NonFungible,
                    count: 3
                })
            ),
            hex"030100010c"
        );
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

    function testDecodeRevertsOnTruncatedAllOfPayload() public {
        vm.expectRevert();
        wrapper.decode(hex"01");
    }
}
