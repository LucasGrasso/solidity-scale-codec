// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {VersionedXcmCodec} from "../src/Xcm/VersionedXcm/VersionedXcmCodec.sol";
import {VersionedXcm} from "../src/Xcm/VersionedXcm/VersionedXcm.sol";

import {XcmCodec} from "../src/Xcm/v5/Xcm/XcmCodec.sol";
import {Xcm} from "../src/Xcm/v5/Xcm/Xcm.sol";

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

contract VersionedXcmWrapper {
    function decode(
        bytes memory data
    ) external pure returns (VersionedXcm memory xcm) {
        (xcm, ) = VersionedXcmCodec.decode(data);
    }
}

contract VersionedXcmTest is Test {
    VersionedXcmWrapper wrapper;

    function setUp() public {
        wrapper = new VersionedXcmWrapper();
    }

    function testDecode() public view {
        // Example encoded instruction (this should be a valid encoded instruction for testing)
        bytes
            memory encoded = hex"050c000401000003008c86471301000003008c8647000d010101000000010100368e8759910dab756d344995f1d3c79374ca8f70066d3a709e48029f6bf0ee7e";
        VersionedXcm memory xcm = wrapper.decode(encoded);
        console.log("Decoded versioned XCM:");
        console.log(" - Type: ", uint256(xcm.version));

        Xcm memory xcmV5 = VersionedXcmCodec.asV5(xcm);
        console.log("Decoded XCM V5:");
        uint256 instructionsCount = xcmV5.instructions.length;
        for (uint256 i = 0; i < instructionsCount; i++) {
            console.log(
                "   - Instruction ",
                i,
                ": ",
                uint256(xcmV5.instructions[i].variant)
            );
            // Decode each instruction
        }
    }
}
