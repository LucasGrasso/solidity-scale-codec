// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Location} from "../Location/Location.sol";
import {Weight} from "../Weight/Weight.sol";
import {QueryId} from "../Types/QueryId.sol";

/// @notice Information regarding the composition of a query response.
struct QueryResponseInfo {
    /// @custom:property The destination to which the query response message should be sent.
    Location destination;
    /// @custom:property The `query_id` field of the `QueryResponse` message.
    QueryId queryId;
    /// @custom:property The `max_weight` field of the `QueryResponse` message.
    Weight maxWeight;
}
