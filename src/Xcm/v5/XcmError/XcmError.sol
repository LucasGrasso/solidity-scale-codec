// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LittleEndianU64} from "../../../LittleEndian/LittleEndianU64.sol";

/// @notice Error codes used in XCM.
enum XcmErrorVariant {
    /// @custom:variant An arithmetic overflow happened.
    Overflow,
    /// @custom:variant The instruction is intentionally unsupported.
    Unimplemented,
    /// @custom:variant Origin Register does not contain a valid value for a reserve transfer notification.
    UntrustedReserveLocation,
    /// @custom:variant Origin Register does not contain a valid value for a teleport notification.
    UntrustedTeleportLocation,
    /// @custom:variant `MultiLocation` value too large to descend further.
    LocationFull,
    /// @custom:variant `MultiLocation` value ascends more parents than known ancestors of local location.
    LocationNotInvertible,
    /// @custom:variant The Origin Register does not contain a valid value for the instruction.
    BadOrigin,
    /// @custom:variant The location parameter is not a valid value for the instruction.
    InvalidLocation,
    /// @custom:variant The given asset is not handled.
    AssetNotFound,
    /// @custom:variant An asset transaction failed, typically due to type conversions. NOTE: The string field is #[codec(skip)] and not serialized.
    FailedToTransactAsset,
    /// @custom:variant An asset cannot be withdrawn, potentially due to lack of ownership, availability or rights.
    NotWithdrawable,
    /// @custom:variant An asset cannot be deposited under the ownership of a particular location.
    LocationCannotHold,
    /// @custom:variant Attempt to send a message greater than the maximum supported by the transport protocol.
    ExceedsMaxMessageSize,
    /// @custom:variant The given message cannot be translated into a format supported by the destination.
    DestinationUnsupported,
    /// @custom:variant Destination is routable, but there is some issue with the transport mechanism. NOTE: The string field is #[codec(skip)] and not serialized.
    Transport,
    /// @custom:variant Destination is known to be unroutable.
    Unroutable,
    /// @custom:variant Used by `ClaimAsset` when the given claim could not be recognized/found.
    UnknownClaim,
    /// @custom:variant Used by `Transact` when the functor cannot be decoded.
    FailedToDecode,
    /// @custom:variant Used by `Transact` to indicate that the given weight limit could be breached by the functor.
    MaxWeightInvalid,
    /// @custom:variant Used by `BuyExecution` when the Holding Register does not contain payable fees.
    NotHoldingFees,
    /// @custom:variant Used by `BuyExecution` when the fees declared to purchase weight are insufficient.
    TooExpensive,
    /// @custom:variant Used by the `Trap` instruction to force an error intentionally.
    Trap,
    /// @custom:variant Used by `ExpectAsset`, `ExpectError` and `ExpectOrigin` when the expectation was not true.
    ExpectationFalse,
    /// @custom:variant The provided pallet index was not found.
    PalletNotFound,
    /// @custom:variant The given pallet's name is different to that expected.
    NameMismatch,
    /// @custom:variant The given pallet's version has an incompatible version to that expected.
    VersionIncompatible,
    /// @custom:variant The given operation would lead to an overflow of the Holding Register.
    HoldingWouldOverflow,
    /// @custom:variant The message was unable to be exported.
    ExportError,
    /// @custom:variant `MultiLocation` value failed to be reanchored.
    ReanchorFailed,
    /// @custom:variant No deal is possible under the given constraints.
    NoDeal,
    /// @custom:variant Fees were required which the origin could not pay.
    FeesNotMet,
    /// @custom:variant Some other error with locking.
    LockError,
    /// @custom:variant The state was not in a condition where the operation was valid to make.
    NoPermission,
    /// @custom:variant The universal location of the local consensus is improper.
    Unanchored,
    /// @custom:variant An asset cannot be deposited, probably because too much of it already exists.
    NotDepositable,
    /// @custom:variant Too many assets matched the given asset filter.
    TooManyAssets
}

/// @notice XCM v5 error, containing the error type and an optional payload for `Trap`.
struct XcmError {
    /// @custom:property The type of the error. See `XcmErrorVariant` enum for possible values.
    XcmErrorVariant variant;
    /// @custom:property The trap code. Only meaningful when `variant` is `Trap`.
    bytes payload;
}

/// @notice Parameters for unit (payload-less) XCM errors.
struct UnitParams {
    /// @custom:property The non-trap error discriminant.
    XcmErrorVariant variant;
}

/// @notice Parameters for the `Trap` error variant.
struct TrapParams {
    /// @custom:property Trap code.
    uint64 code;
}

using LittleEndianU64 for uint64;

// ============ Factory Functions ============

/// @notice Creates a unit `XcmError` with no payload.
/// @param params Parameters for the unit error.
/// @return The `XcmError` struct.
function unit(UnitParams memory params) pure returns (XcmError memory) {
    return XcmError({variant: params.variant, payload: ""});
}

/// @notice Creates a `Trap` error with the given u64 code.
/// @param params Parameters for the trap error.
/// @return The `XcmError` struct representing the trap.
function trap(TrapParams memory params) pure returns (XcmError memory) {
    return
        XcmError({
            variant: XcmErrorVariant.Trap,
            payload: abi.encodePacked(params.code.toLittleEndian())
        });
}
