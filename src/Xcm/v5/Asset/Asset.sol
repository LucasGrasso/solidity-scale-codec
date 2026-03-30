// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetId} from "../AssetId.sol";
import {Fungibility} from "../Fungibility.sol";

/// @notice Either an amount of a single fungible asset, or a single well-identified non-fungible asset.
struct Asset {
    /// @custom:property The overall asset identity (aka class, in the case of a non-fungible).
    AssetId id;
    /// @custom:property The fungibility of the asset, which contains either the amount (in the case of a fungible asset) or the instance ID, the secondary asset identifier.
    Fungibility fungibility;
}
