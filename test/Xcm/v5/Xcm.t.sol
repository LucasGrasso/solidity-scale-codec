// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Xcm, newXcm, fromInstructions} from "../../../src/Xcm/v5/Xcm/Xcm.sol";
import {
    Instruction,
    InstructionVariant,
    clearOrigin,
    setFeesMode,
    SetFeesModeParams
} from "../../../src/Xcm/v5/Instruction/Instruction.sol";
import {XcmCodec as Codec} from "../../../src/Xcm/v5/Xcm/XcmCodec.sol";
import {Test} from "forge-std/Test.sol";

contract XcmWrapper {
    function decode(bytes memory data) external pure returns (Xcm memory) {
        (Xcm memory result, ) = Codec.decode(data);
        return result;
    }
}

contract XcmTest is Test {
    XcmWrapper private wrapper;

    function setUp() public {
        wrapper = new XcmWrapper();
    }

    function _assertRoundTrip(
        Xcm memory xcm,
        bytes memory expected
    ) internal view {
        bytes memory encoded = Codec.encode(xcm);
        assertEq(encoded, expected);
        Xcm memory decoded = wrapper.decode(expected);
        assertEq(xcm.instructions.length, decoded.instructions.length);
        for (uint256 i = 0; i < xcm.instructions.length; i++) {
            assertEq(
                keccak256(abi.encode(xcm.instructions[i])),
                keccak256(abi.encode(decoded.instructions[i]))
            );
        }
    }

    // Empty XCM (0 instructions)
    // Encoder: 00
    function testEmptyXcm() public view {
        Xcm memory xcm = newXcm();
        _assertRoundTrip(xcm, hex"00");
    }

    // XCM with 2 instructions
    // Instruction 1: ClearOrigin (0a)
    // Instruction 2: SetFeesMode with jitWithdraw=true (2b01)
    // Encoder: 08 + 0a + 2b01 = 080a2b01
    function testXcmTwoInstructions() public view {
        Instruction[] memory instructions = new Instruction[](2);
        instructions[0] = clearOrigin();
        instructions[1] = setFeesMode(SetFeesModeParams({jitWithdraw: true}));

        Xcm memory xcm = fromInstructions(instructions);
        _assertRoundTrip(xcm, hex"080a2b01");
    }

    // XCM with 1 instruction
    // Instruction 1: ClearOrigin (0a)
    // Encoder: 04 + 0a = 040a
    function testXcmSingleInstruction() public view {
        Instruction[] memory instructions = new Instruction[](1);
        instructions[0] = clearOrigin();

        Xcm memory xcm = fromInstructions(instructions);
        _assertRoundTrip(xcm, hex"040a");
    }
}
