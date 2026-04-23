// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Bytes4} from "../../../Scale/Bytes/Bytes4.sol";
import {Compact} from "../../../Scale/Compact/Compact.sol";
import {BodyId, BodyIdVariant, MonikerParams, BodyIndexParams} from "./BodyId.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `BodyId`
/// @notice SCALE-compliant encoder/decoder for the `BodyId` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library BodyIdCodec {
    error InvalidBodyIdLength();
    error InvalidBodyIdVariant(uint8 variant);

    /// @notice Encodes a `BodyId` into bytes.
    /// @param bodyId The `BodyId` to encode.
    /// @return SCALE-encoded byte sequence representing the `BodyId`.
    function encode(BodyId memory bodyId) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(bodyId.variant), bodyId.payload);
    }

    /// @notice Returns the number of bytes that a `BodyId` struct would occupy when SCALE-encoded, starting at a given offset in the data.
    /// @param data The byte sequence containing the encoded `BodyId`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `BodyId`.
    /// @return The number of bytes that the `BodyId` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) {
            revert InvalidBodyIdLength();
        }
        uint8 variantValue = uint8(data[offset]);
        BodyIdVariant variant = BodyIdVariant(variantValue);
        uint256 payloadLength;
        if (
            variant == BodyIdVariant.Unit ||
            variant == BodyIdVariant.Executive ||
            variant == BodyIdVariant.Technical ||
            variant == BodyIdVariant.Legislative ||
            variant == BodyIdVariant.Judicial ||
            variant == BodyIdVariant.Defense ||
            variant == BodyIdVariant.Administration ||
            variant == BodyIdVariant.Treasury
        ) {
            payloadLength = 0;
        } else if (variant == BodyIdVariant.Moniker) {
            payloadLength = 4;
        } else if (variant == BodyIdVariant.Index) {
            payloadLength = Compact.encodedSizeAt(data, offset + 1);
        } else {
            revert InvalidBodyIdVariant(variantValue);
        }

        if (data.length < offset + 1 + payloadLength) {
            revert InvalidBodyIdLength();
        }

        return 1 + payloadLength;
    }

    /// @notice Decodes a `BodyId` from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `BodyId`.
    /// @return bodyId The decoded `BodyId`.
    /// @return bytesRead The total number of bytes read from the input data to decode the `BodyId`.
    function decode(
        bytes memory data
    ) internal pure returns (BodyId memory bodyId, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `BodyId` from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `BodyId`.
    /// @param offset The starting index in `data` from which to decode the `BodyId`.
    /// @return bodyId The decoded `BodyId`.
    /// @return bytesRead The total number of bytes read from the input data to decode the `BodyId`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (BodyId memory bodyId, uint256 bytesRead) {
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // subtract 1 byte for the variant
        uint8 variantValue = uint8(data[offset]);
        BodyIdVariant variant = BodyIdVariant(variantValue);
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);
        bodyId = BodyId({variant: variant, payload: payload});
        bytesRead = 1 + payloadLength;
    }

    /// @notice Helper function to decode a `BodyId` and extract the moniker name if the type is `Moniker`.
    /// @param bodyId The `BodyId` to extract the moniker name from.
    /// @return params A `MonikerParams` struct containing the moniker name if the `variant` is `Moniker`.
    function asMoniker(
        BodyId memory bodyId
    ) internal pure returns (MonikerParams memory params) {
        _assertVariant(bodyId, BodyIdVariant.Moniker);
        params.name = Bytes4.decode(bodyId.payload);
    }

    /// @notice Helper function to decode a `BodyId` and extract the index if the type is `Index`.
    /// @param bodyId The `BodyId` to extract the index from.
    /// @return params An `BodyIndexParams` struct containing the index if the `variant` is `Index`.
    function asIndex(
        BodyId memory bodyId
    ) internal pure returns (BodyIndexParams memory params) {
        _assertVariant(bodyId, BodyIdVariant.Index);
        (uint256 decodedIndex, ) = Compact.decode(bodyId.payload);
        params.index = UnsignedUtils.toU32(decodedIndex);
    }

    function _assertVariant(
        BodyId memory bodyId,
        BodyIdVariant expected
    ) private pure {
        if (bodyId.variant != expected) {
            revert InvalidBodyIdVariant(uint8(bodyId.variant));
        }
    }
}
