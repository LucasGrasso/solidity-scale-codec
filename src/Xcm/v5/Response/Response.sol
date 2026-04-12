// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Assets} from "../Assets/Assets.sol";
import {AssetsCodec} from "../Assets/AssetsCodec.sol";
import {XcmError} from "../XcmError/XcmError.sol";
import {XcmErrorCodec} from "../XcmError/XcmErrorCodec.sol";
import {PalletInfo} from "../PalletInfo/PalletInfo.sol";
import {PalletInfoCodec} from "../PalletInfo/PalletInfoCodec.sol";
import {MaybeErrorCode} from "../../v3/MaybeErrorCode/MaybeErrorCode.sol";
import {MaybeErrorCodeCodec} from "../../v3/MaybeErrorCode/MaybeErrorCodeCodec.sol";
import {Compact} from "../../../Scale/Compact.sol";
import {LittleEndianU32} from "../../../LittleEndian/LittleEndianU32.sol";

/// @notice Discriminant for the `Response` enum.
enum ResponseVariant {
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
    /// @custom:property The type of the response. See `ResponseVariant` enum for possible values.
    ResponseVariant variant;
    /// @custom:property The SCALE-encoded payload of the response. Structure depends on `variant`.
    bytes payload;
}

/// @notice Parameters for the `Assets` response variant.
struct AssetsParams {
    /// @custom:property Assets payload.
    Assets assets;
}

/// @notice Parameters for the `ExecutionResult` response variant.
struct ExecutionResultParams {
    /// @custom:property Indicates if there was an error.
    bool hasError;
    /// @custom:property The index of the instruction that caused the error.
    uint32 index;
    /// @custom:property The XCM error that occurred.
    XcmError err;
}

/// @notice Parameters for the `Version` response variant.
struct VersionParams {
    /// @custom:property XCM version value.
    uint32 version;
}

/// @notice Parameters for the `PalletsInfo` response variant.
struct PalletsInfoParams {
    /// @custom:property Array of `PalletInfo` structs, containing the info of the pallets. Max length is MAX_PALLETS_INFO (64).
    PalletInfo[] pallets;
}

/// @notice Parameters for the `DispatchResult` response variant.
struct DispatchResultParams {
    /// @custom:property Dispatch result status.
    MaybeErrorCode result;
}

using LittleEndianU32 for uint32;

// ============ Factory Functions ============

/// @notice Creates a `Null` response.
/// @return A `Response` struct representing the null response.
function null_() pure returns (Response memory) {
    return Response({variant: ResponseVariant.Null, payload: ""});
}

/// @notice Creates an `Assets` response.
/// @param params Parameters for the assets variant.
/// @return A `Response` struct representing the assets response.
function assets(AssetsParams memory params) pure returns (Response memory) {
    return
        Response({
            variant: ResponseVariant.Assets,
            payload: AssetsCodec.encode(params.assets)
        });
}

/// @notice Creates an `ExecutionResult` response.
/// @param params Parameters for the execution result variant.
/// @return A `Response` struct representing the execution result response.
function executionResult(
    ExecutionResultParams memory params
) pure returns (Response memory) {
    bytes memory payload;
    if (!params.hasError) {
        payload = abi.encodePacked(uint8(0));
    } else {
        payload = abi.encodePacked(
            uint8(1),
            params.index.toLittleEndian(),
            XcmErrorCodec.encode(params.err)
        );
    }
    return
        Response({variant: ResponseVariant.ExecutionResult, payload: payload});
}

/// @notice Creates a `Version` response.
/// @param params Parameters for the version variant.
/// @return A `Response` struct representing the version response.
function version(VersionParams memory params) pure returns (Response memory) {
    return
        Response({
            variant: ResponseVariant.Version,
            payload: abi.encodePacked(params.version.toLittleEndian())
        });
}

/// @notice Creates a `PalletsInfo` response.
/// @param params Parameters for the pallets info variant.
/// @return A `Response` struct representing the pallets info response.
function palletsInfo(
    PalletsInfoParams memory params
) pure returns (Response memory) {
    bytes memory encoded = Compact.encode(params.pallets.length);
    for (uint256 i = 0; i < params.pallets.length; ++i) {
        encoded = bytes.concat(
            encoded,
            PalletInfoCodec.encode(params.pallets[i])
        );
    }
    return Response({variant: ResponseVariant.PalletsInfo, payload: encoded});
}

/// @notice Creates a `DispatchResult` response.
/// @param params Parameters for the dispatch-result variant.
/// @return A `Response` struct representing the dispatch result response.
function dispatchResult(
    DispatchResultParams memory params
) pure returns (Response memory) {
    return
        Response({
            variant: ResponseVariant.DispatchResult,
            payload: MaybeErrorCodeCodec.encode(params.result)
        });
}
