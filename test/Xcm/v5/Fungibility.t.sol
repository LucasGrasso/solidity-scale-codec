// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetInstance, array4, Array4Params} from "../../../src/Xcm/v5/AssetInstance/AssetInstance.sol";
import {Fungibility, fungible, nonFungible, FungibleParams, NonFungibleParams} from "../../../src/Xcm/v5/Fungibility/Fungibility.sol";
import {FungibilityCodec as Codec} from "../../../src/Xcm/v5/Fungibility/FungibilityCodec.sol";
import {Test} from "forge-std/Test.sol";

contract FungibilityWrapper {
    function decode(
        bytes memory data
    ) external pure returns (Fungibility memory fungibility) {
        (fungibility, ) = Codec.decode(data);
    }
}

contract FungibilityTest is Test {
    FungibilityWrapper private wrapper;

    function setUp() public {
        wrapper = new FungibilityWrapper();
    }

    function _assertRoundTrip(
        Fungibility memory value,
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
            fungible(FungibleParams({amount: 1_200_000_000})),
            hex"0003008c8647"
        );
    }

    function testEncodeDecodeNonFungible() public view {
        _assertRoundTrip(
            nonFungible(
                NonFungibleParams({
                    instance: array4(
                        Array4Params({data: bytes4(hex"09080706")})
                    )
                })
            ),
            hex"010209080706"
        );
    }

    function testDecodeRevertsOnInvalidVariant() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Codec.InvalidFungibilityVariant.selector,
                uint8(0xff)
            )
        );
        wrapper.decode(hex"ff");
    }

    function testDecodeRevertsOnTruncatedNonFungiblePayload() public {
        vm.expectRevert();
        wrapper.decode(hex"01");
    }
}
