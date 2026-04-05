// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Junction, parachain, onlyChild, generalIndex, ParachainParams, GeneralIndexParams} from "../../../src/Xcm/v5/Junction/Junction.sol";
import {Junctions, here, fromJunction, fromJunctionArr} from "../../../src/Xcm/v5/Junctions/Junctions.sol";
import {JunctionsCodec as Codec} from "../../../src/Xcm/v5/Junctions/JunctionsCodec.sol";
import {Test} from "forge-std/Test.sol";

contract JunctionsWrapper {
    function decode(
        bytes memory data
    ) external pure returns (Junctions memory junctions) {
        (junctions, ) = Codec.decode(data);
    }
}

contract JunctionsTest is Test {
    JunctionsWrapper private wrapper;

    function setUp() public {
        wrapper = new JunctionsWrapper();
    }

    function _assertRoundTrip(
        Junctions memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        assertEq(
            keccak256(abi.encode(wrapper.decode(expected))),
            keccak256(abi.encode(value))
        );
    }

    function testEncodeDecodeHere() public view {
        _assertRoundTrip(here(), hex"00");
    }

    function testEncodeDecodeX1() public view {
        _assertRoundTrip(
            fromJunction(parachain(ParachainParams({parachainId: 1000}))),
            hex"0100a10f"
        );
    }

    function testEncodeDecodeX2() public view {
        Junction[] memory junctions = new Junction[](2);
        junctions[0] = parachain(ParachainParams({parachainId: 1000}));
        junctions[1] = onlyChild();
        _assertRoundTrip(fromJunctionArr(junctions), hex"0200a10f07");
    }

    function testEncodeDecodeX3() public view {
        Junction[] memory junctions = new Junction[](3);
        junctions[0] = parachain(ParachainParams({parachainId: 1000}));
        junctions[1] = onlyChild();
        junctions[2] = generalIndex(GeneralIndexParams({index: 7}));
        _assertRoundTrip(fromJunctionArr(junctions), hex"0300a10f07051c");
    }
}
