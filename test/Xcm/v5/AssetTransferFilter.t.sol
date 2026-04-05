// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {
    AssetTransferFilter,
    teleport,
    reserveDeposit,
    reserveWithdraw,
    TeleportParams,
    ReserveDepositParams,
    ReserveWithdrawParams
} from "../../../src/Xcm/v5/AssetTransferFilter/AssetTransferFilter.sol";
import {AssetTransferFilterCodec as Codec} from "../../../src/Xcm/v5/AssetTransferFilter/AssetTransferFilterCodec.sol";
import {
    AssetFilter,
    definite,
    wild,
    DefiniteParams,
    WildParams
} from "../../../src/Xcm/v5/AssetFilter/AssetFilter.sol";
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
    allCounted,
    AllCountedParams
} from "../../../src/Xcm/v5/WildAsset/WildAsset.sol";
import {Location, parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {Test} from "forge-std/Test.sol";

contract AssetTransferFilterWrapper {
    function decode(
        bytes memory data
    ) external pure returns (AssetTransferFilter memory) {
        (AssetTransferFilter memory result, ) = Codec.decode(data);
        return result;
    }
}

contract AssetTransferFilterTest is Test {
    AssetTransferFilterWrapper private wrapper;

    function setUp() public {
        wrapper = new AssetTransferFilterWrapper();
    }

    function _assertRoundTrip(
        AssetTransferFilter memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        AssetTransferFilter memory decoded = wrapper.decode(expected);
        assertEq(uint8(decoded.variant), uint8(value.variant));
        assertEq(decoded.payload, value.payload);
    }

    // Test Teleport variant with Definite filter
    // Encoder: teleport: 00000401000003008c8647
    function testEncodeDecodeTeleport() public view {
        Asset[] memory assetArray = new Asset[](1);
        assetArray[0] = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1200000000}))
        });

        Assets memory assetsStruct;
        assetsStruct.items = assetArray;

        _assertRoundTrip(
            teleport(
                TeleportParams({
                    assetFilter: definite(
                        DefiniteParams({assets: assetsStruct})
                    )
                })
            ),
            hex"00000401000003008c8647"
        );
    }

    // Test ReserveDeposit variant with Wild filter (AllCounted)
    // Encoder: reserve_deposit: 01010208
    function testEncodeDecodeReserveDeposit() public view {
        _assertRoundTrip(
            reserveDeposit(
                ReserveDepositParams({
                    assetFilter: wild(
                        WildParams({
                            wildAsset: allCounted(AllCountedParams({count: 2}))
                        })
                    )
                })
            ),
            hex"01010208"
        );
    }

    // Test ReserveWithdraw variant with Definite filter
    // Encoder: reserve_withdraw: 02000401000003008c8647
    function testEncodeDecodeReserveWithdraw() public view {
        Asset[] memory assetArray = new Asset[](1);
        assetArray[0] = Asset({
            id: AssetId(parent()),
            fungibility: fungible(FungibleParams({amount: 1200000000}))
        });

        Assets memory assetsStruct;
        assetsStruct.items = assetArray;

        _assertRoundTrip(
            reserveWithdraw(
                ReserveWithdrawParams({
                    assetFilter: definite(
                        DefiniteParams({assets: assetsStruct})
                    )
                })
            ),
            hex"02000401000003008c8647"
        );
    }

    // Negative tests
    function testDecodeRevertsOnEmptyInput() public {
        vm.expectRevert();
        wrapper.decode(hex"");
    }

    function testDecodeRevertsOnInvalidVariant() public {
        vm.expectRevert();
        wrapper.decode(hex"03");
    }

    function testDecodeRevertsOnTruncatedVariant() public {
        vm.expectRevert();
        wrapper.decode(hex"00");
    }
}
