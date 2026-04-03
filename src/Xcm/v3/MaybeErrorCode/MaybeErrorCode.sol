// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {U8Arr} from "../../../Scale/Array.sol";
import {MAX_DISPATCH_ERROR_LEN} from "../Constants.sol";

/// @notice Discriminant for the `MaybeErrorCode` enum.
enum MaybeErrorCodeVariant {
    /// @custom:variant No error occurred.
    Success,
    /// @custom:variant An error occurred, containing the dispatch error bytes.
    Error,
    /// @custom:variant An error occurred but the error code was truncated to MAX_DISPATCH_ERROR_LEN bytes.
    TruncatedError
}

/// @notice The result of a `Transact` dispatch, either success or an error code.
struct MaybeErrorCode {
    /// @custom:property The type of the result. See `MaybeErrorCodeVariant` enum for possible values.
    MaybeErrorCodeVariant variant;
    /// @custom:property The SCALE-encoded dispatch error bytes. Only meaningful when `variant` is `Error` or `TruncatedError`. Max length is MAX_DISPATCH_ERROR_LEN (128 bytes).
    bytes payload;
}

/// @notice Parameters for the `Error` variant.
struct ErrorParams {
    /// @custom:property Dispatch error bytes.
    uint8[] errorBytes;
}

/// @notice Parameters for the `TruncatedError` variant.
struct TruncatedErrorParams {
    /// @custom:property Truncated dispatch error bytes.
    uint8[] errorBytes;
}

// ============ Factory Functions ============

/// @notice Creates a `Success` MaybeErrorCode.
/// @return A `MaybeErrorCode` struct representing success.
function success() pure returns (MaybeErrorCode memory) {
    return
        MaybeErrorCode({variant: MaybeErrorCodeVariant.Success, payload: ""});
}

/// @notice Creates an `Error` MaybeErrorCode with the given dispatch error bytes.
/// @param params Parameters for the error variant.
/// @return A `MaybeErrorCode` struct representing the error.
function error(ErrorParams memory params) pure returns (MaybeErrorCode memory) {
    if (params.errorBytes.length > MAX_DISPATCH_ERROR_LEN)
        revert MaybeErrorCodeTooLong(params.errorBytes.length);
    return
        MaybeErrorCode({
            variant: MaybeErrorCodeVariant.Error,
            payload: U8Arr.encode(params.errorBytes)
        });
}

/// @notice Creates a `TruncatedError` MaybeErrorCode with the given dispatch error bytes.
/// @param params Parameters for the truncated-error variant.
/// @return A `MaybeErrorCode` struct representing the truncated error.
function truncatedError(
    TruncatedErrorParams memory params
) pure returns (MaybeErrorCode memory) {
    if (params.errorBytes.length > MAX_DISPATCH_ERROR_LEN)
        revert MaybeErrorCodeTooLong(params.errorBytes.length);
    return
        MaybeErrorCode({
            variant: MaybeErrorCodeVariant.TruncatedError,
            payload: U8Arr.encode(params.errorBytes)
        });
}

error MaybeErrorCodeTooLong(uint256 length);
