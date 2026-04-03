// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Location} from "../Location/Location.sol";
import {LocationCodec} from "../Location/LocationCodec.sol";
import {Hint, HintVariant} from "./Hint.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";

/// @title SCALE Codec for XCM v5 `Hint`
/// @notice SCALE-compliant encoder/decoder for the `Hint` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/enum.Hint.html
library HintCodec {
    error InvalidHintLength();
    error InvalidHintVariant(uint8 variant);

    /// @notice Encodes a `Hint` struct into SCALE bytes.
    /// @param hint The `Hint` struct to encode.
    /// @return SCALE-encoded bytes representing the `Hint`.
    function encode(Hint memory hint) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(hint.variant), hint.payload);
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
        uint8 variant = uint8(data[offset]);
        if (variant == uint8(HintVariant.AssetClaimer)) {
            return 1 + LocationCodec.encodedSizeAt(data, offset + 1);
        }
        revert InvalidHintVariant(variant);
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
        uint8 variant = uint8(data[offset]);
        if (variant > uint8(HintVariant.AssetClaimer))
            revert InvalidHintVariant(variant);
        uint256 size = encodedSizeAt(data, offset);
        uint256 payloadLength = size - 1;
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        hint = Hint({variant: HintVariant(variant), payload: payload});
        bytesRead = size;
    }

    /// @notice Decodes the `Location` from an `AssetClaimer` hint.
    /// @param hint The `Hint` struct. Must be of type `AssetClaimer`.
    /// @return The claimer `Location`.
    function asAssetClaimer(
        Hint memory hint
    ) internal pure returns (Location memory) {
        if (hint.variant != HintVariant.AssetClaimer)
            revert InvalidHintVariant(uint8(hint.variant));
        (Location memory location, ) = LocationCodec.decode(hint.payload);
        return location;
    }
}
