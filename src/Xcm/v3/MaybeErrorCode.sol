// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {U8Arr} from "../../Scale/Array.sol";
import {MAX_DISPATCH_ERROR_LEN} from "./Constants.sol";

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

/// @title SCALE Codec for XCM v3 `MaybeErrorCode`
/// @notice SCALE-compliant encoder/decoder for the `MaybeErrorCode` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v3 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v3/index.html
library MaybeErrorCodeCodec {
    error InvalidMaybeErrorCodeLength();
    error InvalidMaybeErrorCodeType(uint8 meType);
    error MaybeErrorCodeTooLong(uint256 length);

    /// @notice Creates a `Success` MaybeErrorCode.
    /// @return A `MaybeErrorCode` struct representing success.
    function success() internal pure returns (MaybeErrorCode memory) {
        return
            MaybeErrorCode({meType: MaybeErrorCodeType.Success, payload: ""});
    }

    /// @notice Creates an `Error` MaybeErrorCode with the given dispatch error bytes.
    /// @param errorBytes The dispatch error bytes. Must not exceed MAX_DISPATCH_ERROR_LEN bytes.
    /// @return A `MaybeErrorCode` struct representing the error.
    function error(
        uint8[] memory errorBytes
    ) internal pure returns (MaybeErrorCode memory) {
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
    ) internal pure returns (MaybeErrorCode memory) {
        if (errorBytes.length > MAX_DISPATCH_ERROR_LEN)
            revert MaybeErrorCodeTooLong(errorBytes.length);
        return
            MaybeErrorCode({
                meType: MaybeErrorCodeType.TruncatedError,
                payload: U8Arr.encode(errorBytes)
            });
    }

    /// @notice Encodes a `MaybeErrorCode` struct into SCALE bytes.
    /// @param me The `MaybeErrorCode` struct to encode.
    /// @return SCALE-encoded bytes representing the `MaybeErrorCode`.
    function encode(
        MaybeErrorCode memory me
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(me.meType), me.payload);
    }

    /// @notice Returns the number of bytes that a `MaybeErrorCode` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `MaybeErrorCode`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded `MaybeErrorCode`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidMaybeErrorCodeLength();
        uint8 meType = uint8(data[offset]);
        if (meType == uint8(MaybeErrorCodeType.Success)) {
            return 1;
        } else if (
            meType == uint8(MaybeErrorCodeType.Error) ||
            meType == uint8(MaybeErrorCodeType.TruncatedError)
        ) {
            return 1 + U8Arr.encodedSizeAt(data, offset + 1);
        } else {
            revert InvalidMaybeErrorCodeType(meType);
        }
    }

    /// @notice Decodes a `MaybeErrorCode` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded `MaybeErrorCode`.
    /// @return me The decoded `MaybeErrorCode` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    ) internal pure returns (MaybeErrorCode memory me, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `MaybeErrorCode` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `MaybeErrorCode`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return me The decoded `MaybeErrorCode` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (MaybeErrorCode memory me, uint256 bytesRead) {
        if (data.length < offset + 1) revert InvalidMaybeErrorCodeLength();
        uint8 meType = uint8(data[offset]);
        if (meType > uint8(MaybeErrorCodeType.TruncatedError))
            revert InvalidMaybeErrorCodeType(meType);
        uint256 size = encodedSizeAt(data, offset);
        uint256 payloadLength = size - 1;
        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; ++i) {
            payload[i] = data[offset + 1 + i];
        }
        me = MaybeErrorCode({
            meType: MaybeErrorCodeType(meType),
            payload: payload
        });
        bytesRead = size;
    }

    /// @notice Decodes the dispatch error bytes from an `Error` or `TruncatedError` MaybeErrorCode.
    /// @param me The `MaybeErrorCode` struct to decode. Must be of type `Error` or `TruncatedError`.
    /// @return errorBytes The decoded dispatch error bytes.
    function decodeError(
        MaybeErrorCode memory me
    ) internal pure returns (uint8[] memory errorBytes) {
        if (
            me.meType != MaybeErrorCodeType.Error &&
            me.meType != MaybeErrorCodeType.TruncatedError
        ) revert InvalidMaybeErrorCodeType(uint8(me.meType));
        (errorBytes, ) = U8Arr.decode(me.payload);
    }
}
