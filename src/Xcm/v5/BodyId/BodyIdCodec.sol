// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Bytes4} from "../../../Scale/Bytes.sol";
import {Compact} from "../../../Scale/Compact.sol";
import {BodyId, BodyIdType} from "./BodyId.sol";

/// @title SCALE Codec for XCM v5 `BodyId`
/// @notice SCALE-compliant encoder/decoder for the `BodyId` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library BodyIdCodec {
    error InvalidBodyIdLength();
    error InvalidBodyIdType(uint8 bodyIdType);

    /// @notice Encodes a `BodyId` into bytes.
    /// @param bodyId The `BodyId` to encode.
    /// @return SCALE-encoded byte sequence representing the `BodyId`.
    function encode(BodyId memory bodyId) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(bodyId.bodyIdType), bodyId.payload);
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
        uint8 bodyIdTypeValue = uint8(data[offset]);
        BodyIdType bodyIdType = BodyIdType(bodyIdTypeValue);
        uint256 payloadLength;
        if (
            bodyIdType == BodyIdType.Unit ||
            bodyIdType == BodyIdType.Executive ||
            bodyIdType == BodyIdType.Technical ||
            bodyIdType == BodyIdType.Legislative ||
            bodyIdType == BodyIdType.Judicial ||
            bodyIdType == BodyIdType.Defense ||
            bodyIdType == BodyIdType.Administration ||
            bodyIdType == BodyIdType.Treasury
        ) {
            payloadLength = 0;
        } else if (bodyIdType == BodyIdType.Moniker) {
            payloadLength = 4;
        } else if (bodyIdType == BodyIdType.Index) {
            payloadLength = 4;
        } else {
            revert InvalidBodyIdType(bodyIdTypeValue);
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
        if (data.length < offset + 1) {
            revert InvalidBodyIdLength();
        }
        uint8 bodyIdTypeValue = uint8(data[offset]);
        BodyIdType bodyIdType = BodyIdType(bodyIdTypeValue);
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // subtract 1 byte for the bodyIdType
        bytes memory payload = new bytes(payloadLength);

        for (uint256 i = 0; i < payloadLength; i++) {
            payload[i] = data[offset + 1 + i];
        }

        bodyId = BodyId({bodyIdType: bodyIdType, payload: payload});
        bytesRead = 1 + payloadLength;
    }

    /// @notice Helper function to decode a `BodyId` and extract the moniker name if the type is `Moniker`.
    /// @param bodyId The `BodyId` to extract the moniker name from.
    /// @return name The 4-byte name of the moniker if the `bodyIdType` is `Moniker`.
    function asMoniker(
        BodyId memory bodyId
    ) internal pure returns (bytes4 name) {
        if (bodyId.bodyIdType != BodyIdType.Moniker) {
            revert InvalidBodyIdType(uint8(bodyId.bodyIdType));
        }
        return Bytes4.decode(bodyId.payload);
    }

    /// @notice Helper function to decode a `BodyId` and extract the index if the type is `Index`.
    /// @param bodyId The `BodyId` to extract the index from.
    /// @return idx The index of the body if the `bodyIdType` is `Index`.
    function asIndex(BodyId memory bodyId) internal pure returns (uint32 idx) {
        if (bodyId.bodyIdType != BodyIdType.Index) {
            revert InvalidBodyIdType(uint8(bodyId.bodyIdType));
        }
        if (bodyId.payload.length != 4) {
            revert InvalidBodyIdLength();
        }
        (uint256 decodedIndex, ) = Compact.decode(bodyId.payload);
        if (decodedIndex > type(uint32).max) {
            revert InvalidBodyIdLength();
        }
        unchecked {
            idx = uint32(decodedIndex);
        }
    }
}
