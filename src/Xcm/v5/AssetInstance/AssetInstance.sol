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
/// @param idx The index value for the asset instance, which must be less than 2^128.
/// @return An `AssetInstance` struct with type `Index` and the provided index value encoded in the payload.
function index(uint128 idx) pure returns (AssetInstance memory) {
    bytes memory payload = Compact.encode(idx);
    return AssetInstance({iType: AssetInstanceType.Index, payload: payload});
}

/// @notice Creates an `Array4` asset instance with the given 4-byte data.
/// @param data The 4-byte data for the asset instance.
/// @return An `AssetInstance` struct with type `Array4` and the provided data encoded in the payload.
function array4(bytes4 data) pure returns (AssetInstance memory) {
    return
        AssetInstance({
            iType: AssetInstanceType.Array4,
            payload: data.encode()
        });
}

/// @notice Creates an `Array8` asset instance with the given 8-byte data.
/// @param data The 8-byte data for the asset instance.
/// @return An `AssetInstance` struct with type `Array8` and the provided data encoded in the payload.
function array8(bytes8 data) pure returns (AssetInstance memory) {
    return
        AssetInstance({
            iType: AssetInstanceType.Array8,
            payload: data.encode()
        });
}

/// @notice Creates an `Array16` asset instance with the given 16-byte data.
/// @param data The 16-byte data for the asset instance.
/// @return An `AssetInstance` struct with type `Array16` and the provided data encoded in the payload.
function array16(bytes16 data) pure returns (AssetInstance memory) {
    return
        AssetInstance({
            iType: AssetInstanceType.Array16,
            payload: data.encode()
        });
}

/// @notice Creates an `Array32` asset instance with the given 32-byte data.
/// @param data The 32-byte data for the asset instance.
/// @return An `AssetInstance` struct with type `Array32` and the provided data encoded in the payload.
function array32(bytes32 data) pure returns (AssetInstance memory) {
    return
        AssetInstance({
            iType: AssetInstanceType.Array32,
            payload: data.encode()
        });
}
