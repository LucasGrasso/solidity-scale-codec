// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Asset} from "../../../src/Xcm/v5/Asset/Asset.sol";
import {AssetId} from "../../../src/Xcm/v5/AssetId/AssetId.sol";
import {array32, Array32Params} from "../../../src/Xcm/v5/AssetInstance/AssetInstance.sol";
import {parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {AssetCodec as Codec} from "../../../src/Xcm/v5/Asset/AssetCodec.sol";
import {Fungibility, fungible, FungibleParams, nonFungible, NonFungibleParams} from "../../../src/Xcm/v5/Fungibility/Fungibility.sol";
import {Test} from "forge-std/Test.sol";

contract AssetWrapper {
    function decode(
        bytes memory data
    ) external pure returns (Asset memory asset) {
        (asset, ) = Codec.decode(data);
    }
}

contract AssetTest is Test {
    AssetWrapper private wrapper;

    function setUp() public {
        wrapper = new AssetWrapper();
    }

    function _assertRoundTrip(
        Asset memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        assertEq(
            keccak256(abi.encode(wrapper.decode(expected))),
            keccak256(abi.encode(value))
        );
    }

    function testEncodeDecodeFungible() public view {
        _assertRoundTrip(
            Asset({
                id: AssetId(parent()),
                fungibility: fungible(FungibleParams({amount: 1_200_000_000}))
            }),
            hex"01000003008c8647"
        );
    }

    function testEncodeDecodeNonFungible() public view {
        _assertRoundTrip(
            Asset({
                id: AssetId(parent()),
                fungibility: nonFungible(
                    NonFungibleParams({
                        instance: array32(
                            Array32Params({
                                data: bytes32(
                                    hex"4444444444444444444444444444444444444444444444444444444444444444"
                                )
                            })
                        )
                    })
                )
            }),
            hex"010001054444444444444444444444444444444444444444444444444444444444444444"
        );
    }

    function testDecodeRevertsOnMissingFungibility() public {
        vm.expectRevert();
        wrapper.decode(hex"0100");
    }

    function testDecodeRevertsOnInvalidFungibilityVariant() public {
        vm.expectRevert();
        wrapper.decode(hex"0100ff");
    }
}
