// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {Bytes4} from "../../../Scale/Bytes/Bytes4.sol";
import {Bytes8} from "../../../Scale/Bytes/Bytes8.sol";
import {Bytes16} from "../../../Scale/Bytes/Bytes16.sol";
import {Bytes32} from "../../../Scale/Bytes/Bytes32.sol";

using Bytes4 for bytes4;
using Bytes8 for bytes8;
using Bytes16 for bytes16;
using Bytes32 for bytes32;

/// @dev Discriminant for the different types of AssetInstances in XCM v5.
enum AssetInstanceType {
    /// @custom:variant Used if the non-fungible asset class has only one instance.
    Undefined,
    /// @custom:variant A compact index up to 2^128 - 1.
    Index,
    /// @custom:variant A 4-byte fixed-length datum.
    Array4,
    /// @custom:variant An 8-byte fixed-length datum.
    Array8,
    /// @custom:variant A 16-byte fixed-length datum.
    Array16,
    /// @custom:variant A 32-byte fixed-length datum.
    Array32
}

/// @notice A general identifier for an instance of a non-fungible asset class.
struct AssetInstance {
    /// @custom:property The type of asset instance, determining how to interpret the payload. See `AssetInstanceType` enum for possible values.
    AssetInstanceType iType;
    /// @custom:property The encoded payload containing the asset instance data, whose structure depends on the `iType`.
    bytes payload;
}

/// @notice Parameters for the `Index` variant.
struct IndexParams {
    /// @custom:property The compact index value.
    uint128 idx;
}

/// @notice Parameters for the `Array4` variant.
struct Array4Params {
    /// @custom:property The 4-byte fixed data.
    bytes4 data;
}

/// @notice Parameters for the `Array8` variant.
struct Array8Params {
    /// @custom:property The 8-byte fixed data.
    bytes8 data;
}

/// @notice Parameters for the `Array16` variant.
struct Array16Params {
    /// @custom:property The 16-byte fixed data.
    bytes16 data;
}

/// @notice Parameters for the `Array32` variant.
struct Array32Params {
    /// @custom:property The 32-byte fixed data.
    bytes32 data;
}

// ============ Factory Functions ============

/// @notice Creates an `Undefined` asset instance.
/// @return An `AssetInstance` struct with type `Undefined` and an empty payload.
function undefined() pure returns (AssetInstance memory) {
    return
        AssetInstance({
            iType: AssetInstanceType.Undefined,
            payload: new bytes(0)
        });
}

/// @notice Creates an `Index` asset instance with the given index value.
/// @param params Parameters for the index variant.
/// @return An `AssetInstance` struct with type `Index` and the provided index value encoded in the payload.
function index(IndexParams memory params) pure returns (AssetInstance memory) {
    bytes memory payload = Compact.encode(params.idx);
    return AssetInstance({iType: AssetInstanceType.Index, payload: payload});
}

/// @notice Creates an `Array4` asset instance with the given 4-byte data.
/// @param params Parameters for the array4 variant.
/// @return An `AssetInstance` struct with type `Array4` and the provided data encoded in the payload.
function array4(Array4Params memory params) pure returns (AssetInstance memory) {
    return
        AssetInstance({
            iType: AssetInstanceType.Array4,
            payload: params.data.encode()
        });
}

/// @notice Creates an `Array8` asset instance with the given 8-byte data.
/// @param params Parameters for the array8 variant.
/// @return An `AssetInstance` struct with type `Array8` and the provided data encoded in the payload.
function array8(Array8Params memory params) pure returns (AssetInstance memory) {
    return
        AssetInstance({
            iType: AssetInstanceType.Array8,
            payload: params.data.encode()
        });
}

/// @notice Creates an `Array16` asset instance with the given 16-byte data.
/// @param params Parameters for the array16 variant.
/// @return An `AssetInstance` struct with type `Array16` and the provided data encoded in the payload.
function array16(Array16Params memory params) pure returns (AssetInstance memory) {
    return
        AssetInstance({
            iType: AssetInstanceType.Array16,
            payload: params.data.encode()
        });
}

/// @notice Creates an `Array32` asset instance with the given 32-byte data.
/// @param params Parameters for the array32 variant.
/// @return An `AssetInstance` struct with type `Array32` and the provided data encoded in the payload.
function array32(Array32Params memory params) pure returns (AssetInstance memory) {
    return
        AssetInstance({
            iType: AssetInstanceType.Array32,
            payload: params.data.encode()
        });
}
