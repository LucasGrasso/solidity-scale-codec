// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Bytes4} from "../../../Scale/Bytes.sol";
import {Compact} from "../../../Scale/Compact.sol";

/// @dev Discriminant for the different types of BodyIds in XCM v5. Each variant corresponds to a specific structure of the payload.
enum BodyIdType {
    /// @custom:variant The only body in its context.
    Unit,
    /// @custom:variant A named body.
    Moniker,
    /// @custom:variant An indexed body.
    Index,
    /// @custom:variant The unambiguous executive body (for Polkadot, this would be the Polkadot council).
    Executive,
    /// @custom:variant The unambiguous technical body (for Polkadot, this would be the Technical Committee).
    Technical,
    /// @custom:variant The unambiguous legislative body (for Polkadot, this could be considered the opinion of a majority of lock-voters).
    Legislative,
    /// @custom:variant The unambiguous judicial body (this doesn’t exist on Polkadot, but if it were to get a “grand oracle”, it may be considered as that).
    Judicial,
    /// @custom:variant The unambiguous defense body (for Polkadot, an opinion on the topic given via a public referendum on the `staking_admin` track).
    Defense,
    /// @custom:variant The unambiguous administration body (for Polkadot, an opinion on the topic given via a public referendum on the `general_admin` track).
    Administration,
    /// @custom:variant The unambiguous treasury body (for Polkadot, an opinion on the topic given via a public referendum on the `treasurer` track).
    Treasury
}

/// @notice An identifier of a pluralistic body.
struct BodyId {
    /// @custom:property The type of BodyId, which determines how to interpret the payload
    BodyIdType bodyIdType;
    /// @custom:property For Moniker and Index types, this will hold the relevant data
    bytes payload;
}

// ============ Factory Functions ============

/// @notice Creates a `BodyId` representing a `Unit` body.
/// @return A `BodyId` with `bodyIdType` set to `Unit` and an empty payload.
function unit() pure returns (BodyId memory) {
    return BodyId({bodyIdType: BodyIdType.Unit, payload: ""});
}

/// @notice Creates a `BodyId` representing a `Moniker` body with the given 4-byte name.
/// @param name The 4-byte name of the moniker body.
/// @return A `BodyId` with `bodyIdType` set to `Moniker` and the provided name encoded in the payload.
function moniker(bytes4 name) pure returns (BodyId memory) {
    return
        BodyId({
            bodyIdType: BodyIdType.Moniker,
            payload: Bytes4.encode(name)
        });
}

/// @notice Creates a `BodyId` representing an `Index` body with the given index.
/// @param idx The index of the body.
/// @return A `BodyId` with `bodyIdType` set to `Index` and the provided index encoded in the payload.
function index(uint32 idx) pure returns (BodyId memory) {
    return BodyId({bodyIdType: BodyIdType.Index, payload: Compact.encode(idx)});
}

/// @notice Creates a `BodyId` representing an `Executive` body.
/// @return A `BodyId` with `bodyIdType` set to `Executive` and an empty payload.
function executive() pure returns (BodyId memory) {
    return BodyId({bodyIdType: BodyIdType.Executive, payload: ""});
}

/// @notice Creates a `BodyId` representing a `Technical` body.
/// @return A `BodyId` with `bodyIdType` set to `Technical` and an empty payload.
function technical() pure returns (BodyId memory) {
    return BodyId({bodyIdType: BodyIdType.Technical, payload: ""});
}

/// @notice Creates a `BodyId` representing a `Legislative` body.
/// @return A `BodyId` with `bodyIdType` set to `Legislative` and an empty payload.
function legislative() pure returns (BodyId memory) {
    return BodyId({bodyIdType: BodyIdType.Legislative, payload: ""});
}

/// @notice Creates a `BodyId` representing a `Judicial` body.
/// @return A `BodyId` with `bodyIdType` set to `Judicial` and an empty payload.
function judicial() pure returns (BodyId memory) {
    return BodyId({bodyIdType: BodyIdType.Judicial, payload: ""});
}

/// @notice Creates a `BodyId` representing a `Defense` body.
/// @return A `BodyId` with `bodyIdType` set to `Defense` and an empty payload.
function defense() pure returns (BodyId memory) {
    return BodyId({bodyIdType: BodyIdType.Defense, payload: ""});
}

/// @notice Creates a `BodyId` representing an `Administration` body.
/// @return A `BodyId` with `bodyIdType` set to `Administration` and an empty payload.
function administration() pure returns (BodyId memory) {
    return BodyId({bodyIdType: BodyIdType.Administration, payload: ""});
}

/// @notice Creates a `BodyId` representing a `Treasury` body.
/// @return A `BodyId` with `bodyIdType` set to `Treasury` and an empty payload.
function treasury() pure returns (BodyId memory) {
    return BodyId({bodyIdType: BodyIdType.Treasury, payload: ""});
}
