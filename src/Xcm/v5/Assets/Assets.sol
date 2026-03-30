// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Asset} from "../Asset/Asset.sol";

/// @notice An array of Assets.
/// @dev There are a number of invariants which the construction and mutation functions must ensure are maintained:
/// \t - It may contain no items of duplicate asset class;
///\t     - All items must be ordered;
////     - The number of items should grow no larger than `MAX_ITEMS_IN_ASSETS`.
struct Assets {
    /// @custom:property The items of the array.
    Asset[] items;
}
