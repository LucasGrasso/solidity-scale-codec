// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Location, parent} from "../../../src/Xcm/v5/Location/Location.sol";
import {Junction, accountId32, parachain, AccountId32Params, ParachainParams} from "../../../src/Xcm/v5/Junction/Junction.sol";
import {Junctions, here, fromJunctionArr} from "../../../src/Xcm/v5/Junctions/Junctions.sol";
import {LocationCodec as Codec} from "../../../src/Xcm/v5/Location/LocationCodec.sol";
import {NetworkId, polkadot} from "../../../src/Xcm/v5/NetworkId/NetworkId.sol";
import {Test} from "forge-std/Test.sol";

contract LocationWrapper {
    function decode(
        bytes memory data
    ) external pure returns (Location memory location) {
        (location, ) = Codec.decode(data);
    }
}

contract LocationTest is Test {
    LocationWrapper private wrapper;

    function setUp() public {
        wrapper = new LocationWrapper();
    }

    function _assertRoundTrip(
        Location memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        assertEq(
            keccak256(abi.encode(wrapper.decode(expected))),
            keccak256(abi.encode(value))
        );
    }

    function testEncodeDecodeHere() public view {
        _assertRoundTrip(Location({parents: 0, interior: here()}), hex"0000");
    }

    function testEncodeDecodeParent() public view {
        _assertRoundTrip(parent(), hex"0100");
    }

    function testEncodeDecodeNested() public view {
        Junction[] memory junctions = new Junction[](2);
        junctions[0] = parachain(ParachainParams({parachainId: 1000}));
        junctions[1] = accountId32(
            AccountId32Params({
                hasNetwork: true,
                network: polkadot(),
                id: bytes32(
                    hex"3333333333333333333333333333333333333333333333333333333333333333"
                )
            })
        );

        _assertRoundTrip(
            Location({parents: 2, interior: fromJunctionArr(junctions)}),
            hex"020200a10f0101023333333333333333333333333333333333333333333333333333333333333333"
        );
    }
}
