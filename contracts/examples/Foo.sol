// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import {Bool} from "../../src/Scale/Bool.sol";
import {I16} from "../../src/Scale/Signed.sol";
import {U8, U16} from "../../src/Scale/Unsigned.sol";

contract Example {
    using Bool for bool;
    using I16 for int16;
    using U8 for uint8;
    using U16 for uint16;

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

    function decodeFoo(bytes calldata b) external pure returns (Foo memory) {
        return
            Foo({
                a: U8.decodeAt(b, 0),
                b: U16.decodeAt(b, 1),
                c: I16.decodeAt(b, 3),
                d: Bool.decodeAt(b, 5)
            });
    }
}
