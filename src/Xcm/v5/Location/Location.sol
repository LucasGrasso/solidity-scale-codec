// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Junctions} from "../Junctions/Junctions.sol";

import {here} from "../Junctions/Junctions.sol";

/// @notice A relative path between state-bearing consensus systems.
struct Location {
    /// @custom:property The number of parent junctions at the beginning of this Location.
    uint8 parents;
    /// @custom:property The interior (i.e. non-parent) junctions that this Location contains. See `Junctions` struct for details.
    Junctions interior;
}

/// @notice Creates a `Location` struct representing the parent location (i.e., one level up in the hierarchy).
/// @return A `Location` struct with `parents` set to 1 and an empty `interior`.
function parent() pure returns (Location memory) {
    return Location({parents: 1, interior: here()});
}
