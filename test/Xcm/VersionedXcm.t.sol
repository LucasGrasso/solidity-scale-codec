// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {VersionedXcmCodec} from "../../src/Xcm/VersionedXcm/VersionedXcmCodec.sol";
import {VersionedXcm, v5} from "../../src/Xcm/VersionedXcm/VersionedXcm.sol";
import {XcmCodec} from "../../src/Xcm/v5/Xcm/XcmCodec.sol";
import {Xcm} from "../../src/Xcm/v5/Xcm/Xcm.sol";
import {XcmBuilder} from "../../src/Xcm/v5/Xcm/XcmBuilder.sol";
import {Instruction, WithdrawAssetParams, BuyExecutionParams, DepositAssetParams} from "../../src/Xcm/v5/Instruction/Instruction.sol";
import {InstructionCodec} from "../../src/Xcm/v5/Instruction/InstructionCodec.sol";
import {Asset} from "../../src/Xcm/v5/Asset/Asset.sol";
import {fromAsset} from "../../src/Xcm/v5/Assets/Assets.sol";
import {Location, parent} from "../../src/Xcm/v5/Location/Location.sol";
import {AssetId} from "../../src/Xcm/v5/AssetId/AssetId.sol";
import {fungible, FungibleParams} from "../../src/Xcm/v5/Fungibility/Fungibility.sol";
import {unlimited} from "../../src/Xcm/v5/WeightLimit/WeightLimit.sol";
import {AssetFilter, wild, WildParams} from "../../src/Xcm/v5/AssetFilter/AssetFilter.sol";
import {allOf, AllOfParams} from "../../src/Xcm/v5/WildAsset/WildAsset.sol";
import {WildFungibility} from "../../src/Xcm/v5/WildFungibility/WildFungibility.sol";
import {accountId32, AccountId32Params} from "../../src/Xcm/v5/Junction/Junction.sol";
import {fromJunction} from "../../src/Xcm/v5/Junctions/Junctions.sol";
import {polkadot} from "../../src/Xcm/v5/NetworkId/NetworkId.sol";

import {Test} from "forge-std/Test.sol";

contract VersionedXcmWrapper {
    function decode(
        bytes memory data
    ) external pure returns (VersionedXcm memory xcm) {
        (xcm, ) = VersionedXcmCodec.decode(data);
    }
}

contract VersionedXcmTest is Test {
    VersionedXcmWrapper wrapper;

    using InstructionCodec for Instruction;
    using XcmBuilder for Xcm;

    function setUp() public {
        wrapper = new VersionedXcmWrapper();
    }

    function testDecode() public view {
        // Example encoded instruction (this should be a valid encoded instruction for testing)
        bytes
            memory encoded = hex"050c000401000003008c86471301000003008c8647000d010101000000010100368e8759910dab756d344995f1d3c79374ca8f70066d3a709e48029f6bf0ee7e";
        VersionedXcm memory xcm = wrapper.decode(encoded);

        Xcm memory xcmV5 = VersionedXcmCodec.asV5(xcm);
        uint256 instructionsCount = xcmV5.instructions.length;
        assertEq(instructionsCount, 3);

        // Decode the first instruction and check its type

        WithdrawAssetParams memory params = xcmV5
            .instructions[0]
            .asWithdrawAsset();
        assertEq(params.assets.items.length, 1);

        Asset memory expectedAsset = Asset({
            id: AssetId({location: parent()}),
            fungibility: fungible(FungibleParams({amount: 1200000000}))
        });
        assertEq(
            keccak256(abi.encode(params.assets.items[0])),
            keccak256(abi.encode(expectedAsset))
        );

        BuyExecutionParams memory buyParams = xcmV5
            .instructions[1]
            .asBuyExecution();
        assertEq(
            keccak256(abi.encode(buyParams.fees)),
            keccak256(abi.encode(expectedAsset))
        );
        assertEq(
            keccak256(abi.encode(buyParams.weightLimit)),
            keccak256(abi.encode(unlimited()))
        );

        DepositAssetParams memory depositParams = xcmV5
            .instructions[2]
            .asDepositAsset();

        AssetFilter memory expectedFilter = wild(
            WildParams({
                wildAsset: allOf(
                    AllOfParams({
                        id: AssetId({location: parent()}),
                        fun: WildFungibility.Fungible
                    })
                )
            })
        );
        assertEq(
            keccak256(abi.encode(depositParams.assets)),
            keccak256(abi.encode(expectedFilter))
        );

        Location memory expectedBeneficiary = Location({
            parents: 0,
            interior: fromJunction(
                accountId32(
                    AccountId32Params({
                        hasNetwork: false,
                        id: hex"368e8759910dab756d344995f1d3c79374ca8f70066d3a709e48029f6bf0ee7e",
                        network: polkadot() // just for clarity, since hasNetwork is false, this field is not actually encoded in the junction
                    })
                )
            )
        });

        assertEq(
            keccak256(abi.encode(depositParams.beneficiary)),
            keccak256(abi.encode(expectedBeneficiary))
        );
    }

    function testEncodeWithBuilderMatchesFixtureHex() public pure {
        bytes
            memory expected = hex"050c000401000003008c86471301000003008c8647000d010101000000010100368e8759910dab756d344995f1d3c79374ca8f70066d3a709e48029f6bf0ee7e";

        Asset memory asset = Asset({
            id: AssetId({location: parent()}),
            fungibility: fungible(FungibleParams({amount: 1200000000}))
        });

        AssetFilter memory filter = wild(
            WildParams({
                wildAsset: allOf(
                    AllOfParams({
                        id: AssetId({location: parent()}),
                        fun: WildFungibility.Fungible
                    })
                )
            })
        );

        Location memory beneficiary = Location({
            parents: 0,
            interior: fromJunction(
                accountId32(
                    AccountId32Params({
                        hasNetwork: false,
                        network: polkadot(),
                        id: hex"368e8759910dab756d344995f1d3c79374ca8f70066d3a709e48029f6bf0ee7e"
                    })
                )
            )
        });

        bytes memory encoded = VersionedXcmCodec.encode(
            v5(
                XcmBuilder
                    .create()
                    .withdrawAsset(
                        WithdrawAssetParams({assets: fromAsset(asset)})
                    )
                    .buyExecution(
                        BuyExecutionParams({
                            fees: asset,
                            weightLimit: unlimited()
                        })
                    )
                    .depositAsset(
                        DepositAssetParams({
                            assets: filter,
                            beneficiary: beneficiary
                        })
                    )
            )
        );
        assertEq(encoded, expected);
    }
}