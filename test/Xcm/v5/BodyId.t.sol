// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {
    BodyId,
    unit,
    moniker,
    index,
    executive,
    technical,
    legislative,
    judicial,
    defense,
    administration,
    treasury,
    MonikerParams,
    IndexParams
} from "../../../src/Xcm/v5/BodyId/BodyId.sol";
import {BodyIdCodec as Codec} from "../../../src/Xcm/v5/BodyId/BodyIdCodec.sol";
import {Test} from "forge-std/Test.sol";

contract BodyIdWrapper {
    function decode(
        bytes memory data
    ) external pure returns (BodyId memory bodyId) {
        (bodyId, ) = Codec.decode(data);
    }
}

contract BodyIdTest is Test {
    BodyIdWrapper private wrapper;

    function setUp() public {
        wrapper = new BodyIdWrapper();
    }

    function _assertRoundTrip(
        BodyId memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        assertEq(
            keccak256(abi.encode(wrapper.decode(expected))),
            keccak256(abi.encode(value))
        );
    }

    function testEncodeDecodeUnit() public view {
        _assertRoundTrip(unit(), hex"00");
    }

    function testEncodeDecodeMoniker() public view {
        _assertRoundTrip(
            moniker(MonikerParams({name: bytes4("DOT!")})),
            hex"01444f5421"
        );
    }

    function testEncodeDecodeIndex() public view {
        _assertRoundTrip(index(IndexParams({index: 42})), hex"02a8");
    }

    function testEncodeDecodeExecutive() public view {
        _assertRoundTrip(executive(), hex"03");
    }

    function testEncodeDecodeTechnical() public view {
        _assertRoundTrip(technical(), hex"04");
    }

    function testEncodeDecodeLegislative() public view {
        _assertRoundTrip(legislative(), hex"05");
    }

    function testEncodeDecodeJudicial() public view {
        _assertRoundTrip(judicial(), hex"06");
    }

    function testEncodeDecodeDefense() public view {
        _assertRoundTrip(defense(), hex"07");
    }

    function testEncodeDecodeAdministration() public view {
        _assertRoundTrip(administration(), hex"08");
    }

    function testEncodeDecodeTreasury() public view {
        _assertRoundTrip(treasury(), hex"09");
    }

    function testDecodeRevertsOnInvalidVariant() public {
        vm.expectRevert();
        wrapper.decode(hex"ff");
    }

    function testDecodeRevertsOnTruncatedMonikerPayload() public {
        vm.expectRevert(Codec.InvalidBodyIdLength.selector);
        wrapper.decode(hex"01414243");
    }
}
