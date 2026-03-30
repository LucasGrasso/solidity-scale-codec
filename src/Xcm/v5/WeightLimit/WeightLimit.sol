// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Weight} from "../Weight/Weight.sol";
import {WeightCodec} from "../Weight/WeightCodec.sol";

/// @notice Discriminant for the `WeightLimit` enum.
enum WeightLimitType {
    /// @custom:variant No limit on weight.
    Unlimited,
    /// @custom:variant A specific weight limit.
    Limited
}

/// @notice An optional weight limit.
struct WeightLimit {
    /// @custom:property The type of the weight limit. See `WeightLimitType` enum for possible values.
    WeightLimitType wlType;
    /// @custom:property The SCALE-encoded `Weight`. Only meaningful when `wlType` is `Limited`.
    bytes payload;
}

/// @notice Parameters for the `Limited` variant.
struct LimitedParams {
    /// @custom:property Weight limit value.
    Weight weight;
}

// ============ Factory Functions ============

/// @notice Creates an `Unlimited` weight limit.
/// @return A `WeightLimit` struct representing no limit.
function unlimited() pure returns (WeightLimit memory) {
    return WeightLimit({wlType: WeightLimitType.Unlimited, payload: ""});
}

/// @notice Creates a `Limited` weight limit with the given `Weight`.
/// @param params Parameters for the limited variant.
/// @return A `WeightLimit` struct representing the given limit.
function limited(
    LimitedParams memory params
) pure returns (WeightLimit memory) {
    return
        WeightLimit({
            wlType: WeightLimitType.Limited,
            payload: WeightCodec.encode(params.weight)
        });
}
