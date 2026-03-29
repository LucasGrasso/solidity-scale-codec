// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LittleEndianU64} from "../../LittleEndian/LittleEndianU64.sol";

/// @notice Error codes used in XCM.
enum XcmErrorType {
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
    /// @custom:property The type of the error. See `XcmErrorType` enum for possible values.
    XcmErrorType eType;
    /// @custom:property The trap code. Only meaningful when `eType` is `Trap`.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `Error`
/// @notice SCALE-compliant encoder/decoder for the XCM v5 `Error` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/traits.rs.html
library XcmErrorCodec {
    error InvalidXcmErrorLength();
    error InvalidXcmError(uint8 e);
    error InvalidXcmErrorPayload();

    using LittleEndianU64 for uint64;

    /// @notice Creates a unit `XcmError` with no payload.
    /// @param eType The error type. Must not be `Trap`.
    /// @return The `XcmError` struct.
    function unit(XcmErrorType eType) internal pure returns (XcmError memory) {
        return XcmError({eType: eType, payload: ""});
    }

    /// @notice Creates a `Trap` error with the given u64 code.
    /// @param code The trap code.
    /// @return The `XcmError` struct representing the trap.
    function trap(uint64 code) internal pure returns (XcmError memory) {
        return
            XcmError({
                eType: XcmErrorType.Trap,
                payload: abi.encodePacked(code.toLittleEndian())
            });
    }

    /// @notice Encodes an `XcmError` into SCALE bytes.
    /// @param e The `XcmError` struct to encode.
    /// @return SCALE-encoded bytes representing the error.
    function encode(XcmError memory e) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(e.eType), e.payload);
    }

    /// @notice Returns the number of bytes that an `XcmError` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `XcmError`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded `XcmError`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidXcmErrorLength();
        uint8 raw = uint8(data[offset]);
        if (raw > uint8(XcmErrorType.TooManyAssets))
            revert InvalidXcmError(raw);
        if (raw == uint8(XcmErrorType.Trap)) {
            return 1 + 8; // 1 byte for the error type and 8 bytes for the u64 trap code
        }
        return 1;
    }

    /// @notice Decodes an `XcmError` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded `XcmError`.
    /// @return e The decoded `XcmError` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    ) internal pure returns (XcmError memory e, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes an `XcmError` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `XcmError`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return e The decoded `XcmError` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (XcmError memory e, uint256 bytesRead) {
        if (data.length < offset + 1) revert InvalidXcmErrorLength();
        uint8 raw = uint8(data[offset]);
        if (raw > uint8(XcmErrorType.TooManyAssets))
            revert InvalidXcmError(raw);
        uint256 size = encodedSizeAt(data, offset);
        uint256 payloadLength = size - 1;
        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; ++i) {
            payload[i] = data[offset + 1 + i];
        }
        e = XcmError({eType: XcmErrorType(raw), payload: payload});
        bytesRead = size;
    }

    /// @notice Decodes the trap code from a `Trap` error.
    /// @param e The `XcmError` struct to decode, which must be of type `Trap`.
    /// @return code The decoded u64 trap code.
    function decodeTrap(XcmError memory e) internal pure returns (uint64 code) {
        if (e.eType != XcmErrorType.Trap)
            revert InvalidXcmError(uint8(e.eType));
        uint256 decoded = LittleEndianU64.fromLittleEndian(e.payload, 0);
        code = uint64(decoded);
    }
}
