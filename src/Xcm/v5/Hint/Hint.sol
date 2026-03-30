// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Location} from "../Location/Location.sol";
import {LocationCodec} from "../Location/LocationCodec.sol";

/// @notice Discriminant for the `Hint` enum.
enum HintType {
    /// @custom:variant Set asset claimer for all the trapped assets during the execution.
    AssetClaimer
}

/// @notice A hint for XCM execution, changing the behaviour of the XCM program.
struct Hint {
    /// @custom:property The type of the hint. See `HintType` enum for possible values.
    HintType hType;
    /// @custom:property The SCALE-encoded payload of the hint. Structure depends on `hType`.
    bytes payload;
}

// ============ Factory Functions ============

/// @notice Creates an `AssetClaimer` hint.
/// @param location The claimer of any assets potentially trapped during the execution of the current XCM. It can be an arbitrary location, not necessarily the caller or origin.
/// @return A `Hint` struct representing the `AssetClaimer` hint.
function assetClaimer(Location memory location) pure returns (Hint memory) {
    return
        Hint({
            hType: HintType.AssetClaimer,
            payload: LocationCodec.encode(location)
        });
}
