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

error InvalidJunctionsCount(uint8 count);

/// @notice Creates a `Here` junctions struct.
/// @return A `Junctions` struct representing the `Here` variant.
function here() pure returns (Junctions memory) {
    return Junctions({count: 0, items: new Junction[](0)});
}

/// @notice Creates a `Junctions` struct from a single `Junction`, representing the `X1` variant.
/// @param junction The `Junction` to include in the `Junctions`.
/// @return A `Junctions` struct containing the provided `Junction`.
function fromJunction(
    Junction memory junction
) pure returns (Junctions memory) {
    Junction[] memory js = new Junction[](1);
    js[0] = junction;
    return Junctions({count: 1, items: js});
}

/// @notice Creates a `Junctions` struct with the given junctions.
/// @param junctions An array of `Junction` structs to include in the `Junctions`.
/// @return A `Junctions` struct containing the provided junctions.
function fromJunctionArr(
    Junction[] memory junctions
) pure returns (Junctions memory) {
    if (junctions.length == 0) {
        return here();
    }
    if (junctions.length > 8) {
        revert InvalidJunctionsCount(uint8(junctions.length));
    }
    return Junctions({count: uint8(junctions.length), items: junctions});
}
