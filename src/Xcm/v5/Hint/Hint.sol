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

/// @notice Parameters for the `AssetClaimer` variant.
struct AssetClaimerParams {
    /// @custom:property The claimer location.
    Location location;
}

// ============ Factory Functions ============

/// @notice Creates an `AssetClaimer` hint.
/// @param params Parameters for the asset-claimer variant.
/// @return A `Hint` struct representing the `AssetClaimer` hint.
function assetClaimer(
    AssetClaimerParams memory params
) pure returns (Hint memory) {
    return
        Hint({
            hType: HintType.AssetClaimer,
            payload: LocationCodec.encode(params.location)
        });
}
