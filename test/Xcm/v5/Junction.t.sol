// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {BodyId, executive} from "../../../src/Xcm/v5/BodyId/BodyId.sol";
import {BodyPart, voice} from "../../../src/Xcm/v5/BodyPart/BodyPart.sol";
import {Junction, parachain, accountId32, accountIndex64, accountKey20, palletInstance, generalIndex, generalKey, onlyChild, plurality, globalConsensus, ParachainParams, AccountId32Params, AccountIndex64Params, AccountKey20Params, PalletInstanceParams, GeneralIndexParams, GeneralKeyParams, PluralityParams, GlobalConsensusParams} from "../../../src/Xcm/v5/Junction/Junction.sol";
import {JunctionCodec as Codec} from "../../../src/Xcm/v5/Junction/JunctionCodec.sol";
import {NetworkId, polkadot, kusama} from "../../../src/Xcm/v5/NetworkId/NetworkId.sol";
import {Test} from "forge-std/Test.sol";

contract JunctionWrapper {
    function decode(
        bytes memory data
    ) external pure returns (Junction memory junction) {
        (junction, ) = Codec.decode(data);
    }
}

contract JunctionTest is Test {
    JunctionWrapper private wrapper;

    function setUp() public {
        wrapper = new JunctionWrapper();
    }

    function _assertRoundTrip(
        Junction memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        assertEq(
            keccak256(abi.encode(wrapper.decode(expected))),
            keccak256(abi.encode(value))
        );
    }

    function testEncodeDecodeParachain() public view {
        _assertRoundTrip(
            parachain(ParachainParams({parachainId: 1000})),
            hex"00a10f"
        );
    }

    function testEncodeDecodeAccountId32() public view {
        _assertRoundTrip(
            accountId32(
                AccountId32Params({
                    hasNetwork: true,
                    network: polkadot(),
                    id: bytes32(
                        hex"3333333333333333333333333333333333333333333333333333333333333333"
                    )
                })
            ),
            hex"0101023333333333333333333333333333333333333333333333333333333333333333"
        );
    }

    function testEncodeDecodeAccountIndex64() public view {
        _assertRoundTrip(
            accountIndex64(
                AccountIndex64Params({
                    hasNetwork: true,
                    network: kusama(),
                    index: 123456
                })
            ),
            hex"02010302890700"
        );
    }

    function testEncodeDecodeAccountKey20() public view {
        _assertRoundTrip(
            accountKey20(
                AccountKey20Params({
                    hasNetwork: false,
                    network: polkadot(),
                    key: address(0x4444444444444444444444444444444444444444)
                })
            ),
            hex"03004444444444444444444444444444444444444444"
        );
    }

    function testEncodeDecodePalletInstance() public view {
        _assertRoundTrip(
            palletInstance(PalletInstanceParams({instance: 7})),
            hex"0407"
        );
    }

    function testEncodeDecodeGeneralIndex() public view {
        _assertRoundTrip(
            generalIndex(GeneralIndexParams({index: 123456789})),
            hex"0556346f1d"
        );
    }

    function testEncodeDecodeGeneralKey() public view {
        _assertRoundTrip(
            generalKey(
                GeneralKeyParams({
                    length: 4,
                    key: hex"01020304aabbccdd1122334455667788"
                })
            ),
            hex"060401020304aabbccdd112233445566778800000000000000000000000000000000"
        );
    }

    function testEncodeDecodeOnlyChild() public view {
        _assertRoundTrip(onlyChild(), hex"07");
    }

    function testEncodeDecodePlurality() public view {
        _assertRoundTrip(
            plurality(PluralityParams({id: executive(), part: voice()})),
            hex"080300"
        );
    }

    function testEncodeDecodeGlobalConsensus() public view {
        _assertRoundTrip(
            globalConsensus(GlobalConsensusParams({network: polkadot()})),
            hex"0902"
        );
    }
}
