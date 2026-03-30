// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {AssetFilter} from "../AssetFilter/AssetFilter.sol";
import {AssetFilterCodec} from "../AssetFilter/AssetFilterCodec.sol";

/// @notice Discriminant for the `AssetTransferFilter` enum.
enum AssetTransferFilterType {
    /// @custom:variant Teleport assets matching `AssetFilter` to a specific destination.
    Teleport,
    /// @custom:variant Reserve-transfer assets matching `AssetFilter` to a specific destination, using the local chain as reserve.
    ReserveDeposit,
    /// @custom:variant Reserve-transfer assets matching `AssetFilter` to a specific destination, using the destination as reserve.
    ReserveWithdraw
}

/// @notice Matches assets based on inner `AssetFilter` and tags them for a specific type of asset transfer.
struct AssetTransferFilter {
    /// @custom:property The type of asset transfer. See `AssetTransferFilterType` enum for possible values.
    AssetTransferFilterType atfType;
    /// @custom:property The SCALE-encoded `AssetFilter` payload.
    bytes payload;
}

/// @notice Parameters for the `Teleport` variant.
struct TeleportParams {
    /// @custom:property Asset filter used for teleport transfer.
    AssetFilter filter;
}

/// @notice Parameters for the `ReserveDeposit` variant.
struct ReserveDepositParams {
    /// @custom:property Asset filter used for reserve-deposit transfer.
    AssetFilter filter;
}

/// @notice Parameters for the `ReserveWithdraw` variant.
struct ReserveWithdrawParams {
    /// @custom:property Asset filter used for reserve-withdraw transfer.
    AssetFilter filter;
}

// ============ Factory Functions ============

/// @notice Creates a `Teleport` asset transfer filter.
/// @param params Parameters for the teleport variant.
/// @return An `AssetTransferFilter` struct representing the teleport filter.
function teleport(
    TeleportParams memory params
) pure returns (AssetTransferFilter memory) {
    return
        AssetTransferFilter({
            atfType: AssetTransferFilterType.Teleport,
            payload: AssetFilterCodec.encode(params.filter)
        });
}

/// @notice Creates a `ReserveDeposit` asset transfer filter.
/// @param params Parameters for the reserve-deposit variant.
/// @return An `AssetTransferFilter` struct representing the reserve deposit filter.
function reserveDeposit(
    ReserveDepositParams memory params
) pure returns (AssetTransferFilter memory) {
    return
        AssetTransferFilter({
            atfType: AssetTransferFilterType.ReserveDeposit,
            payload: AssetFilterCodec.encode(params.filter)
        });
}

/// @notice Creates a `ReserveWithdraw` asset transfer filter.
/// @param params Parameters for the reserve-withdraw variant.
/// @return An `AssetTransferFilter` struct representing the reserve withdraw filter.
function reserveWithdraw(
    ReserveWithdrawParams memory params
) pure returns (AssetTransferFilter memory) {
    return
        AssetTransferFilter({
            atfType: AssetTransferFilterType.ReserveWithdraw,
            payload: AssetFilterCodec.encode(params.filter)
        });
}
