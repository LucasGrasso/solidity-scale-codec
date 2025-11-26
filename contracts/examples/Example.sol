// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {ScaleCodecU8, ScaleCodecU16, ScaleCodecI16, ScaleCodecBool} from "../libraries/ScaleCodec/ScaleCodec.sol";

contract Example {
    using ScaleCodecBool for bool;
    using ScaleCodecU8 for uint8;
    using ScaleCodecU16 for uint16;
    using ScaleCodecI16 for int16;

    struct Foo {
        uint8 a;
        uint16 b;
        int16 c;
        bool d;
    }

    function encodeFoo(Foo calldata f) external pure returns (bytes memory) {
        return
            abi.encodePacked(
                f.a.encode(),
                f.b.encode(),
                f.c.encode(),
                f.d.encode()
            );
    }
}
