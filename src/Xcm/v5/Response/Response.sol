// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Assets} from "../Assets/Assets.sol";
import {AssetsCodec} from "../Assets/AssetsCodec.sol";
import {XcmErrorCodec, XcmError} from "../XcmError.sol";
import {PalletInfo} from "../PalletInfo/PalletInfo.sol";
import {PalletInfoCodec} from "../PalletInfo/PalletInfoCodec.sol";
import {MaybeErrorCodeCodec, MaybeErrorCode} from "../../v3/MaybeErrorCode.sol";
import {Version} from "../../Types/Version.sol";
import {Compact} from "../../../Scale/Compact.sol";
import {LittleEndianU32} from "../../../LittleEndian/LittleEndianU32.sol";
import {MAX_PALLETS_INFO} from "../Constants.sol";

/// @notice Discriminant for the `Response` enum.
enum ResponseType {
    /// @custom:variant No response. Serves as a neutral default.
    Null,
    /// @custom:variant Some assets.
    Assets,
    /// @custom:variant The outcome of an XCM instruction.
    ExecutionResult,
    /// @custom:variant An XCM version.
    Version,
    /// @custom:variant The index, instance name, pallet name and version of some pallets.
    PalletsInfo,
    /// @custom:variant The status of a dispatch attempt using `Transact`.
    DispatchResult
}

/// @notice Response data to a query.
struct Response {
    /// @custom:property The type of the response. See `ResponseType` enum for possible values.
    ResponseType rType;
    /// @custom:property The SCALE-encoded payload of the response. Structure depends on `rType`.
    bytes payload;
}

using LittleEndianU32 for uint32;

// ============ Factory Functions ============

/// @notice Creates a `Null` response.
/// @return A `Response` struct representing the null response.
function null_() pure returns (Response memory) {
    return Response({rType: ResponseType.Null, payload: ""});
}

/// @notice Creates an `Assets` response.
/// @param assets_ The assets to include in the response.
/// @return A `Response` struct representing the assets response.
function assets(Assets memory assets_) pure returns (Response memory) {
    return
        Response({
            rType: ResponseType.Assets,
            payload: AssetsCodec.encode(assets_)
        });
}

/// @notice Creates an `ExecutionResult` response with no error.
/// @return A `Response` struct representing a successful execution result.
function executionResultSuccess() pure returns (Response memory) {
    // Option<(u32, Error)>: None = 0x00
    return
        Response({
            rType: ResponseType.ExecutionResult,
            payload: abi.encodePacked(uint8(0))
        });
}

/// @notice Creates an `ExecutionResult` response with an error.
/// @param index The index of the instruction that caused the error.
/// @param err The XCM error that occurred.
/// @return A `Response` struct representing a failed execution result.
function executionResultError(
    uint32 index,
    XcmError memory err
) pure returns (Response memory) {
    return
        Response({
            rType: ResponseType.ExecutionResult,
            payload: abi.encodePacked(
                uint8(1),
                index.toLittleEndian(),
                XcmErrorCodec.encode(err)
            )
        });
}

/// @notice Creates a `Version` response.
/// @param version_ The XCM version.
/// @return A `Response` struct representing the version response.
function version(uint32 version_) pure returns (Response memory) {
    return
        Response({
            rType: ResponseType.Version,
            payload: abi.encodePacked(version_.toLittleEndian())
        });
}

/// @notice Creates a `PalletsInfo` response.
/// @param pallets The pallet info array. Max length is MAX_PALLETS_INFO (64).
/// @return A `Response` struct representing the pallets info response.
function palletsInfo(PalletInfo[] memory pallets) pure returns (Response memory) {
    bytes memory encoded = Compact.encode(pallets.length);
    for (uint256 i = 0; i < pallets.length; ++i) {
        encoded = bytes.concat(encoded, PalletInfoCodec.encode(pallets[i]));
    }
    return Response({rType: ResponseType.PalletsInfo, payload: encoded});
}

/// @notice Creates a `DispatchResult` response.
/// @param result The `MaybeErrorCode` dispatch result.
/// @return A `Response` struct representing the dispatch result response.
function dispatchResult(
    MaybeErrorCode memory result
) pure returns (Response memory) {
    return
        Response({
            rType: ResponseType.DispatchResult,
            payload: MaybeErrorCodeCodec.encode(result)
        });
}
