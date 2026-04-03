// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Location} from "../Location/Location.sol";
import {LocationCodec} from "../Location/LocationCodec.sol";
import {Hint, HintVariant, AssetClaimerParams} from "./Hint.sol";
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
        if (variant == uint8(type(HintVariant).max)) {
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
        uint256 size = encodedSizeAt(data, offset);
        uint8 variant = uint8(data[offset]);
        uint256 payloadLength = size - 1;
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        hint = Hint({variant: HintVariant(variant), payload: payload});
        bytesRead = size;
    }

    /// @notice Decodes the `Location` from an `AssetClaimer` hint.
    /// @param hint The `Hint` struct. Must be of type `AssetClaimer`.
    /// @return params An `AssetClaimerParams` struct containing the claimer location.
    function asAssetClaimer(
        Hint memory hint
    ) internal pure returns (AssetClaimerParams memory params) {
        _assertVariant(hint, HintVariant.AssetClaimer);
        (params.location, ) = LocationCodec.decode(hint.payload);
    }

    function _assertVariant(
        Hint memory hint,
        HintVariant expected
    ) internal pure {
        if (hint.variant != expected) {
            revert InvalidHintVariant(uint8(hint.variant));
        }
    }
}
