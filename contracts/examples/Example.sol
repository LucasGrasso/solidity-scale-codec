// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {ScaleCodec} from "../libraries/ScaleCodec/ScaleCodec.sol";

contract Example {
    struct Foo {
        uint8 a;
        uint16 b;
        int16 c;
        bool d;
    }

    function encodeFoo(Foo calldata f) external pure returns (bytes memory) {
        return
            abi.encodePacked(
                ScaleCodec.encodeU8(f.a),
                ScaleCodec.encodeU16(f.b),
                ScaleCodec.encodeI16(f.c),
                ScaleCodec.encodeBool(f.d)
            );
    }
}
