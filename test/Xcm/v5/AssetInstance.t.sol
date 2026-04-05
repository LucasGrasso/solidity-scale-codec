// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetInstance, undefined, index, array4, array8, array16, array32, IndexParams, Array4Params, Array8Params, Array16Params, Array32Params} from "../../../src/Xcm/v5/AssetInstance/AssetInstance.sol";
import {AssetInstanceCodec as Codec} from "../../../src/Xcm/v5/AssetInstance/AssetInstanceCodec.sol";
import {Test} from "forge-std/Test.sol";

contract AssetInstanceWrapper {
    function decode(
        bytes memory data
    ) external pure returns (AssetInstance memory assetInstance) {
        (assetInstance, ) = Codec.decode(data);
    }
}

contract AssetInstanceTest is Test {
    AssetInstanceWrapper private wrapper;

    function setUp() public {
        wrapper = new AssetInstanceWrapper();
    }

    function _assertRoundTrip(
        AssetInstance memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        assertEq(
            keccak256(abi.encode(wrapper.decode(expected))),
            keccak256(abi.encode(value))
        );
    }

    function testEncodeDecodeUndefined() public view {
        _assertRoundTrip(undefined(), hex"00");
    }

    function testEncodeDecodeIndex() public view {
        _assertRoundTrip(index(IndexParams({index: 7})), hex"011c");
    }

    function testEncodeDecodeArray4() public view {
        _assertRoundTrip(
            array4(Array4Params({data: bytes4(hex"01020304")})),
            hex"0201020304"
        );
    }

    function testEncodeDecodeArray8() public view {
        _assertRoundTrip(
            array8(Array8Params({data: bytes8(hex"0101010101010101")})),
            hex"030101010101010101"
        );
    }

    function testEncodeDecodeArray16() public view {
        _assertRoundTrip(
            array16(
                Array16Params({
                    data: bytes16(hex"02020202020202020202020202020202")
                })
            ),
            hex"0402020202020202020202020202020202"
        );
    }

    function testEncodeDecodeArray32() public view {
        _assertRoundTrip(
            array32(
                Array32Params({
                    data: bytes32(
                        hex"0303030303030303030303030303030303030303030303030303030303030303"
                    )
                })
            ),
            hex"050303030303030303030303030303030303030303030303030303030303030303"
        );
    }
}
