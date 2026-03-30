// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Junctions} from "../Junctions.sol";

/// @notice A relative path between state-bearing consensus systems.
struct Location {
    /// @custom:property The number of parent junctions at the beginning of this Location.
    uint8 parents;
    /// @custom:property The interior (i.e. non-parent) junctions that this Location contains. See `Junctions` struct for details.
    Junctions interior;
}
