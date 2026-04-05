// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {NetworkId, NetworkIdVariant, byGenesis, byFork, polkadot, kusama, ethereum, ByGenesisParams, ByForkParams, EthereumParams} from "../../../src/Xcm/v5/NetworkId/NetworkId.sol";
import {NetworkIdCodec as Codec} from "../../../src/Xcm/v5/NetworkId/NetworkIdCodec.sol";
import {Test} from "forge-std/Test.sol";

contract NetworkIdWrapper {
    function decode(
        bytes memory data
    ) external pure returns (NetworkId memory networkId) {
        (networkId, ) = Codec.decode(data);
    }
}

contract NetworkIdTest is Test {
    NetworkIdWrapper private wrapper;

    function setUp() public {
        wrapper = new NetworkIdWrapper();
    }

    function _assertRoundTrip(
        NetworkId memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        assertEq(
            keccak256(abi.encode(wrapper.decode(expected))),
            keccak256(abi.encode(value))
        );
    }

    function testEncodeDecodeByGenesis() public view {
        _assertRoundTrip(
            byGenesis(
                ByGenesisParams({
                    genesisHash: bytes32(
                        hex"1111111111111111111111111111111111111111111111111111111111111111"
                    )
                })
            ),
            hex"001111111111111111111111111111111111111111111111111111111111111111"
        );
    }

    function testEncodeDecodeByFork() public view {
        _assertRoundTrip(
            byFork(
                ByForkParams({
                    blockNumber: 42,
                    blockHash: bytes32(
                        hex"2222222222222222222222222222222222222222222222222222222222222222"
                    )
                })
            ),
            hex"012a000000000000002222222222222222222222222222222222222222222222222222222222222222"
        );
    }

    function testEncodeDecodePolkadot() public view {
        _assertRoundTrip(polkadot(), hex"02");
    }

    function testEncodeDecodeKusama() public view {
        _assertRoundTrip(kusama(), hex"03");
    }

    function testEncodeDecodeEthereum() public view {
        _assertRoundTrip(ethereum(EthereumParams({chainId: 1})), hex"0704");
    }

    function testEncodeDecodeBitcoinCore() public view {
        _assertRoundTrip(
            NetworkId({variant: NetworkIdVariant.BitcoinCore, payload: ""}),
            hex"08"
        );
    }

    function testEncodeDecodeBitcoinCash() public view {
        _assertRoundTrip(
            NetworkId({variant: NetworkIdVariant.BitcoinCash, payload: ""}),
            hex"09"
        );
    }

    function testEncodeDecodePolkadotBulletin() public view {
        _assertRoundTrip(
            NetworkId({variant: NetworkIdVariant.PolkadotBulletin, payload: ""}),
            hex"0a"
        );
    }
}
