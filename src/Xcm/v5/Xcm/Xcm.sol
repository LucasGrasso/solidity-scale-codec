// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Instruction} from "../Instruction/Instruction.sol";

/// @notice Cross-Consensus Message: an ordered list of XCM v5 instructions.
/// @dev Solidity representation of Rust `Xcm<Call>(Vec<Instruction<Call>>)`. In this package,
/// the `Call` generic is represented as pre-encoded bytes inside `Instruction` payloads.
struct Xcm {
    /// @custom:property Ordered instructions that compose the XCM program.
    Instruction[] instructions;
}

/// @notice Creates an empty `Xcm` instance.
/// @return An `Xcm` value with no instructions.
function newXcm() pure returns (Xcm memory) {
    return Xcm({instructions: new Instruction[](0)});
}

/// @notice Creates an `Xcm` from an instruction array.
/// @param instructions The ordered instruction list.
/// @return An `Xcm` wrapper around `instructions`.
function fromInstructions(
    Instruction[] memory instructions
) pure returns (Xcm memory) {
    return Xcm({instructions: instructions});
}
