// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {BodyPart, voice, members, fraction, atLeastProportion, moreThanProportion, MembersParams, FractionParams, AtLeastProportionParams, MoreThanProportionParams} from "../../../src/Xcm/v5/BodyPart/BodyPart.sol";
import {BodyPartCodec as Codec} from "../../../src/Xcm/v5/BodyPart/BodyPartCodec.sol";
import {Test} from "forge-std/Test.sol";

contract BodyPartWrapper {
    function decode(
        bytes memory data
    ) external pure returns (BodyPart memory bodyPart) {
        (bodyPart, ) = Codec.decode(data);
    }
}

contract BodyPartTest is Test {
    BodyPartWrapper private wrapper;

    function setUp() public {
        wrapper = new BodyPartWrapper();
    }

    function _assertRoundTrip(
        BodyPart memory value,
        bytes memory expected
    ) internal view {
        assertEq(Codec.encode(value), expected);
        assertEq(
            keccak256(abi.encode(wrapper.decode(expected))),
            keccak256(abi.encode(value))
        );
    }

    function testEncodeDecodeVoice() public view {
        _assertRoundTrip(voice(), hex"00");
    }

    function testEncodeDecodeMembers() public view {
        _assertRoundTrip(members(MembersParams({count: 7})), hex"011c");
    }

    function testEncodeDecodeFraction() public view {
        _assertRoundTrip(
            fraction(FractionParams({nominator: 2, denominator: 3})),
            hex"02080c"
        );
    }

    function testEncodeDecodeAtLeastProportion() public view {
        _assertRoundTrip(
            atLeastProportion(
                AtLeastProportionParams({nominator: 1, denominator: 2})
            ),
            hex"030408"
        );
    }

    function testEncodeDecodeMoreThanProportion() public view {
        _assertRoundTrip(
            moreThanProportion(
                MoreThanProportionParams({nominator: 2, denominator: 3})
            ),
            hex"04080c"
        );
    }
}
