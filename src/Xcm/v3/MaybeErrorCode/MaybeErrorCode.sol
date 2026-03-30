// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {U8Arr} from "../../../Scale/Array.sol";
import {MAX_DISPATCH_ERROR_LEN} from "../Constants.sol";

/// @notice Discriminant for the `MaybeErrorCode` enum.
enum MaybeErrorCodeType {
    /// @custom:variant No error occurred.
    Success,
    /// @custom:variant An error occurred, containing the dispatch error bytes.
    Error,
    /// @custom:variant An error occurred but the error code was truncated to MAX_DISPATCH_ERROR_LEN bytes.
    TruncatedError
}

/// @notice The result of a `Transact` dispatch, either success or an error code.
struct MaybeErrorCode {
    /// @custom:property The type of the result. See `MaybeErrorCodeType` enum for possible values.
    MaybeErrorCodeType meType;
    /// @custom:property The SCALE-encoded dispatch error bytes. Only meaningful when `meType` is `Error` or `TruncatedError`. Max length is MAX_DISPATCH_ERROR_LEN (128 bytes).
    bytes payload;
}

// ============ Factory Functions ============

/// @notice Creates a `Success` MaybeErrorCode.
/// @return A `MaybeErrorCode` struct representing success.
function success() pure returns (MaybeErrorCode memory) {
    return MaybeErrorCode({meType: MaybeErrorCodeType.Success, payload: ""});
}

/// @notice Creates an `Error` MaybeErrorCode with the given dispatch error bytes.
/// @param errorBytes The dispatch error bytes. Must not exceed MAX_DISPATCH_ERROR_LEN bytes.
/// @return A `MaybeErrorCode` struct representing the error.
function error(uint8[] memory errorBytes) pure returns (MaybeErrorCode memory) {
    if (errorBytes.length > MAX_DISPATCH_ERROR_LEN)
        revert MaybeErrorCodeTooLong(errorBytes.length);
    return
        MaybeErrorCode({
            meType: MaybeErrorCodeType.Error,
            payload: U8Arr.encode(errorBytes)
        });
}

/// @notice Creates a `TruncatedError` MaybeErrorCode with the given dispatch error bytes.
/// @param errorBytes The truncated dispatch error bytes. Must not exceed MAX_DISPATCH_ERROR_LEN bytes.
/// @return A `MaybeErrorCode` struct representing the truncated error.
function truncatedError(
    uint8[] memory errorBytes
) pure returns (MaybeErrorCode memory) {
    if (errorBytes.length > MAX_DISPATCH_ERROR_LEN)
        revert MaybeErrorCodeTooLong(errorBytes.length);
    return
        MaybeErrorCode({
            meType: MaybeErrorCodeType.TruncatedError,
            payload: U8Arr.encode(errorBytes)
        });
}

error MaybeErrorCodeTooLong(uint256 length);
