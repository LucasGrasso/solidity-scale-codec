// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

/// @notice Weight v2 used for measurement for an XCM execution
struct Weight {
    /// @custom:property The computational time used to execute some logic based on reference hardware.
    uint64 refTime;
    /// @custom:property The size of the proof needed to execute some logic.
    uint64 proofSize;
}
