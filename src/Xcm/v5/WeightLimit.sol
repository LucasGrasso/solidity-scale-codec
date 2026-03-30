// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Weight} from "./Weight/Weight.sol";
import {WeightCodec} from "./Weight/WeightCodec.sol";

/// @notice Discriminant for the `WeightLimit` enum.
enum WeightLimitType {
    /// @custom:variant No limit on weight.
    Unlimited,
    /// @custom:variant A specific weight limit.
    Limited
}

/// @notice An optional weight limit.
struct WeightLimit {
    /// @custom:property The type of the weight limit. See `WeightLimitType` enum for possible values.
    WeightLimitType wlType;
    /// @custom:property The SCALE-encoded `Weight`. Only meaningful when `wlType` is `Limited`.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `WeightLimit`
/// @notice SCALE-compliant encoder/decoder for the `WeightLimit` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/enum.WeightLimit.html
library WeightLimitCodec {
    error InvalidWeightLimitLength();
    error InvalidWeightLimitType(uint8 wlType);

    /// @notice Creates an `Unlimited` weight limit.
    /// @return A `WeightLimit` struct representing no limit.
    function unlimited() internal pure returns (WeightLimit memory) {
        return WeightLimit({wlType: WeightLimitType.Unlimited, payload: ""});
    }

    /// @notice Creates a `Limited` weight limit with the given `Weight`.
    /// @param weight The weight limit.
    /// @return A `WeightLimit` struct representing the given limit.
    function limited(
        Weight memory weight
    ) internal pure returns (WeightLimit memory) {
        return
            WeightLimit({
                wlType: WeightLimitType.Limited,
                payload: WeightCodec.encode(weight)
            });
    }

    /// @notice Encodes a `WeightLimit` struct into SCALE bytes.
    /// @param wl The `WeightLimit` struct to encode.
    /// @return SCALE-encoded bytes representing the `WeightLimit`.
    function encode(
        WeightLimit memory wl
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(wl.wlType), wl.payload);
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
        uint8 wlType = uint8(data[offset]);
        if (wlType == uint8(WeightLimitType.Unlimited)) {
            return 1;
        } else if (wlType == uint8(WeightLimitType.Limited)) {
            return 1 + WeightCodec.encodedSizeAt(data, offset + 1);
        } else {
            revert InvalidWeightLimitType(wlType);
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
        if (data.length < offset + 1) revert InvalidWeightLimitLength();
        uint8 wlType = uint8(data[offset]);
        if (wlType > uint8(WeightLimitType.Limited))
            revert InvalidWeightLimitType(wlType);
        uint256 size = encodedSizeAt(data, offset);
        uint256 payloadLength = size - 1;
        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; ++i) {
            payload[i] = data[offset + 1 + i];
        }
        wl = WeightLimit({wlType: WeightLimitType(wlType), payload: payload});
        bytesRead = size;
    }

    /// @notice Decodes the `Weight` from a `Limited` weight limit.
    /// @param wl The `WeightLimit` struct. Must be of type `Limited`.
    /// @return The decoded `Weight`.
    function asWeight(
        WeightLimit memory wl
    ) internal pure returns (Weight memory) {
        if (wl.wlType != WeightLimitType.Limited)
            revert InvalidWeightLimitType(uint8(wl.wlType));
        (Weight memory w, ) = WeightCodec.decode(wl.payload);
        return w;
    }
}
