// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LittleEndianU64} from "../../../LittleEndian/LittleEndianU64.sol";
import {XcmError, XcmErrorVariant, TrapParams} from "./XcmError.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `Error`
/// @notice SCALE-compliant encoder/decoder for the XCM v5 `Error` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/traits.rs.html
library XcmErrorCodec {
    error InvalidXcmErrorLength();
    error InvalidXcmErrorVariant(uint8 variant);
    error InvalidXcmErrorPayload();

    /// @notice Encodes an `XcmError` into SCALE bytes.
    /// @param e The `XcmError` struct to encode.
    /// @return SCALE-encoded bytes representing the error.
    function encode(XcmError memory e) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(e.variant), e.payload);
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
        if (raw > uint8(type(XcmErrorVariant).max))
            revert InvalidXcmErrorVariant(raw);
        if (raw == uint8(XcmErrorVariant.Trap)) {
            if (data.length < offset + 9) revert InvalidXcmErrorLength();
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
        uint256 size = encodedSizeAt(data, offset);
        uint8 raw = uint8(data[offset]);
        uint256 payloadLength = size - 1;
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        e = XcmError({variant: XcmErrorVariant(raw), payload: payload});
        bytesRead = size;
    }

    /// @notice Decodes the trap code from a `Trap` error.
    /// @param e The `XcmError` struct to decode, which must be of type `Trap`.
    /// @return params A `TrapParams` struct containing the decoded trap code.
    function asTrap(
        XcmError memory e
    ) internal pure returns (TrapParams memory params) {
        _assertVariant(e, XcmErrorVariant.Trap);
        params.code = LittleEndianU64.fromLittleEndian(e.payload, 0);
    }

    function _assertVariant(
        XcmError memory e,
        XcmErrorVariant expected
    ) internal pure {
        if (e.variant != expected) {
            revert InvalidXcmErrorVariant(uint8(e.variant));
        }
    }
}
