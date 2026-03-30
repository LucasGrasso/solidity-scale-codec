// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {AssetInstance} from "../AssetInstance/AssetInstance.sol";
import {AssetInstanceCodec} from "../AssetInstance/AssetInstanceCodec.sol";

/// @dev Discriminant for the different types of Fungibility in XCM v5.
enum FungibilityType {
    /// @custom:variant A fungible asset; we record a number of units, as a `uint128` in the inner item.
    Fungible,
    /// @custom:variant A non-fungible asset. We record the instance identifier in the inner item. Only one asset of each instance identifier may ever be in existence at once.
    NonFungible
}

/// @notice Classification of whether an asset is fungible or not, along with a mandatory amount or instance.
struct Fungibility {
    /// @custom:property The type of fungibility, determining how to interpret the payload. See `FungibilityType` enum for possible values.
    FungibilityType fType;
    /// @custom:property The encoded payload containing the fungibility data, whose structure depends on the `fType`.
    bytes payload;
}

// ============ Factory Functions ============

/// @notice Creates a `Fungibility` struct representing a fungible asset with the given amount.
/// @param amount The number of units of the fungible asset.
function fungible(uint128 amount) pure returns (Fungibility memory) {
    return
        Fungibility({
            fType: FungibilityType.Fungible,
            payload: Compact.encode(amount)
        });
}

/// @notice Creates a `Fungibility` struct representing a non-fungible asset with the given instance identifier.
/// @param instance The `AssetInstance` struct identifying the specific instance of the non-fungible asset.
function nonFungible(
    AssetInstance memory instance
) pure returns (Fungibility memory) {
    return
        Fungibility({
            fType: FungibilityType.NonFungible,
            payload: AssetInstanceCodec.encode(instance)
        });
}
