// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Junction} from "../Junction/Junction.sol";

/// @dev The `Junctions` struct represents a sequence of up to 8 `Junction` items, prefixed by a count.
struct Junctions {
    /// @custom:property Represents the enum discriminant, 0 = Here, 1 = X1, ..., 8 = X8
    uint8 count;
    /// @custom:property The actual junction data
    Junction[] items;
}
