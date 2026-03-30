// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {LocationCodec, Location} from "./Location.sol";

/// @notice Discriminant for the `Hint` enum.
enum HintType {
    /// @custom:variant Set asset claimer for all the trapped assets during the execution.
    AssetClaimer
}

/// @notice A hint for XCM execution, changing the behaviour of the XCM program.
struct Hint {
    /// @custom:property The type of the hint. See `HintType` enum for possible values.
    HintType hType;
    /// @custom:property The SCALE-encoded payload of the hint. Structure depends on `hType`.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `Hint`
/// @notice SCALE-compliant encoder/decoder for the `Hint` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/enum.Hint.html
library HintCodec {
    error InvalidHintLength();
    error InvalidHintType(uint8 hType);

    /// @notice Creates an `AssetClaimer` hint.
    /// @param location The claimer of any assets potentially trapped during the execution of the current XCM. It can be an arbitrary location, not necessarily the caller or origin.
    /// @return A `Hint` struct representing the `AssetClaimer` hint.
    function assetClaimer(
        Location memory location
    ) internal pure returns (Hint memory) {
        return
            Hint({
                hType: HintType.AssetClaimer,
                payload: LocationCodec.encode(location)
            });
    }

    /// @notice Encodes a `Hint` struct into SCALE bytes.
    /// @param hint The `Hint` struct to encode.
    /// @return SCALE-encoded bytes representing the `Hint`.
    function encode(Hint memory hint) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(hint.hType), hint.payload);
    }

    /// @notice Returns the number of bytes that a `Hint` would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `Hint`.
    /// @param offset The starting index in `data` from which to calculate the encoded size.
    /// @return The number of bytes occupied by the encoded `Hint`.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) revert InvalidHintLength();
        uint8 hType = uint8(data[offset]);
        if (hType == uint8(HintType.AssetClaimer)) {
            return 1 + LocationCodec.encodedSizeAt(data, offset + 1);
        }
        revert InvalidHintType(hType);
    }

    /// @notice Decodes a `Hint` from SCALE bytes starting at the beginning.
    /// @param data The byte sequence containing the encoded `Hint`.
    /// @return hint The decoded `Hint` struct.
    /// @return bytesRead The number of bytes read.
    function decode(
        bytes memory data
    ) internal pure returns (Hint memory hint, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `Hint` from SCALE bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `Hint`.
    /// @param offset The starting index in `data` from which to decode.
    /// @return hint The decoded `Hint` struct.
    /// @return bytesRead The number of bytes read.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (Hint memory hint, uint256 bytesRead) {
        if (data.length < offset + 1) revert InvalidHintLength();
        uint8 hType = uint8(data[offset]);
        if (hType > uint8(HintType.AssetClaimer)) revert InvalidHintType(hType);
        uint256 size = encodedSizeAt(data, offset);
        uint256 payloadLength = size - 1;
        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; ++i) {
            payload[i] = data[offset + 1 + i];
        }
        hint = Hint({hType: HintType(hType), payload: payload});
        bytesRead = size;
    }

    /// @notice Decodes the `Location` from an `AssetClaimer` hint.
    /// @param hint The `Hint` struct. Must be of type `AssetClaimer`.
    /// @return The claimer `Location`.
    function asAssetClaimer(
        Hint memory hint
    ) internal pure returns (Location memory) {
        if (hint.hType != HintType.AssetClaimer)
            revert InvalidHintType(uint8(hint.hType));
        (Location memory location, ) = LocationCodec.decode(hint.payload);
        return location;
    }
}
