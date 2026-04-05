// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Weight} from "../Weight/Weight.sol";
import {WeightCodec} from "../Weight/WeightCodec.sol";
import {
    WeightLimit,
    WeightLimitVariant,
    LimitedParams
} from "./WeightLimit.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";

/// @title SCALE Codec for XCM v5 `WeightLimit`
/// @notice SCALE-compliant encoder/decoder for the `WeightLimit` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/enum.WeightLimit.html
library WeightLimitCodec {
    error InvalidWeightLimitLength();
    error InvalidWeightLimitVariant(uint8 variant);

    /// @notice Encodes a `WeightLimit` struct into SCALE bytes.
    /// @param wl The `WeightLimit` struct to encode.
    /// @return SCALE-encoded bytes representing the `WeightLimit`.
    function encode(
        WeightLimit memory wl
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(wl.variant), wl.payload);
    }

    /// @notice Returns the number of bytes that a `WeightLimit` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `WeightLimit`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded `WeightLimit`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidWeightLimitLength();
        uint8 variant = uint8(data[offset]);
        if (variant == uint8(WeightLimitVariant.Unlimited)) {
            return 1;
        } else if (variant == uint8(WeightLimitVariant.Limited)) {
            return 1 + WeightCodec.encodedSizeAt(data, offset + 1);
        } else {
            revert InvalidWeightLimitVariant(variant);
        }
    }

    /// @notice Decodes a `WeightLimit` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded `WeightLimit`.
    /// @return wl The decoded `WeightLimit` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    ) internal pure returns (WeightLimit memory wl, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `WeightLimit` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `WeightLimit`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return wl The decoded `WeightLimit` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (WeightLimit memory wl, uint256 bytesRead) {
        uint256 size = encodedSizeAt(data, offset);
        uint8 variant = uint8(data[offset]);
        uint256 payloadLength = size - 1;
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        wl = WeightLimit({
            variant: WeightLimitVariant(variant),
            payload: payload
        });
        bytesRead = size;
    }

    /// @notice Decodes the `Weight` from a `Limited` weight limit.
    /// @param wl The `WeightLimit` struct. Must be of type `Limited`.
    /// @return params A `LimitedParams` struct containing the decoded weight.
    function asLimited(
        WeightLimit memory wl
    ) internal pure returns (LimitedParams memory params) {
        _assertVariant(wl, WeightLimitVariant.Limited);
        (params.weight, ) = WeightCodec.decode(wl.payload);
    }

    function _assertVariant(
        WeightLimit memory wl,
        WeightLimitVariant expected
    ) internal pure {
        if (wl.variant != expected) {
            revert InvalidWeightLimitVariant(uint8(wl.variant));
        }
    }
}
