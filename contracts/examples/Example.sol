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

    function decodeFoo(bytes calldata b) external pure returns (Foo memory) {
        return
            Foo({
                a: ScaleCodec.decodeU8At(b, 0),
                b: ScaleCodec.decodeU16At(b, 1),
                c: ScaleCodec.decodeI16At(b, 3),
                d: ScaleCodec.decodeBoolAt(b, 5)
            });
    }
}
