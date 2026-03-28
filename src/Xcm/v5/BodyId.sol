// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Bytes4} from "../../Scale/Bytes.sol";
import {Compact} from "../../Scale/Compact.sol";

/// @dev Discriminant for the different types of BodyIds in XCM v5. Each variant corresponds to a specific structure of the payload.
enum BodyIdType {
    /// @custom:variant The only body in its context.
    Unit,
    /// @custom:variant A named body.
    Moniker,
    /// @custom:variant An indexed body.
    Index,
    /// @custom:variant The unambiguous executive body (for Polkadot, this would be the Polkadot council).
    Executive,
    /// @custom:variant The unambiguous technical body (for Polkadot, this would be the Technical Committee).
    Technical,
    /// @custom:variant The unambiguous legislative body (for Polkadot, this could be considered the opinion of a majority of lock-voters).
    Legislative,
    /// @custom:variant The unambiguous judicial body (this doesn’t exist on Polkadot, but if it were to get a “grand oracle”, it may be considered as that).
    Judicial,
    /// @custom:variant The unambiguous defense body (for Polkadot, an opinion on the topic given via a public referendum on the `staking_admin` track).
    Defense,
    /// @custom:variant The unambiguous administration body (for Polkadot, an opinion on the topic given via a public referendum on the `general_admin` track).
    Administration,
    /// @custom:variant The unambiguous treasury body (for Polkadot, an opinion on the topic given via a public referendum on the `treasurer` track).
    Treasury
}

/// @notice An identifier of a pluralistic body.
struct BodyId {
    /// @custom:property The type of BodyId, which determines how to interpret the payload
    BodyIdType bodyIdType;
    /// @custom:property For Moniker and Index types, this will hold the relevant data
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `BodyId`
/// @notice SCALE-compliant encoder/decoder for the `BodyId` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library BodyIdCodec {
    error InvalidBodyIdLength();
    error InvalidBodyIdType(uint8 bodyIdType);

    /// @notice Creates a `BodyId` representing a `Unit` body.
    /// @return A `BodyId` with `bodyIdType` set to `Unit` and an empty payload.
    function unit() internal pure returns (BodyId memory) {
        return BodyId({bodyIdType: BodyIdType.Unit, payload: ""});
    }

    /// @notice Creates a `BodyId` representing a `Moniker` body with the given 4-byte name.
    /// @param name The 4-byte name of the moniker body.
    /// @return A `BodyId` with `bodyIdType` set to `Moniker` and the provided name encoded in the payload.
    function moniker(bytes4 name) internal pure returns (BodyId memory) {
        return
            BodyId({
                bodyIdType: BodyIdType.Moniker,
                payload: Bytes4.encode(name)
            });
    }

    /// @notice Creates a `BodyId` representing an `Index` body with the given index.
    /// @param idx The index of the body.
    /// @return A `BodyId` with `bodyIdType` set to `Index` and the provided index encoded in the payload.
    function index(uint32 idx) internal pure returns (BodyId memory) {
        return
            BodyId({
                bodyIdType: BodyIdType.Index,
                payload: Compact.encode(idx)
            });
    }

    /// @notice Creates a `BodyId` representing an `Executive` body.
    /// @return A `BodyId` with `bodyIdType` set to `Executive` and an empty payload.
    function executive() internal pure returns (BodyId memory) {
        return BodyId({bodyIdType: BodyIdType.Executive, payload: ""});
    }

    /// @notice Creates a `BodyId` representing a `Technical` body.
    /// @return A `BodyId` with `bodyIdType` set to `Technical` and an empty payload.
    function technical() internal pure returns (BodyId memory) {
        return BodyId({bodyIdType: BodyIdType.Technical, payload: ""});
    }

    /// @notice Creates a `BodyId` representing a `Legislative` body.
    /// @return A `BodyId` with `bodyIdType` set to `Legislative` and an empty payload.
    function legislative() internal pure returns (BodyId memory) {
        return BodyId({bodyIdType: BodyIdType.Legislative, payload: ""});
    }

    /// @notice Creates a `BodyId` representing a `Judicial` body.
    /// @return A `BodyId` with `bodyIdType` set to `Judicial` and an empty payload.
    function judicial() internal pure returns (BodyId memory) {
        return BodyId({bodyIdType: BodyIdType.Judicial, payload: ""});
    }

    /// @notice Creates a `BodyId` representing a `Defense` body.
    /// @return A `BodyId` with `bodyIdType` set to `Defense` and an empty payload.
    function defense() internal pure returns (BodyId memory) {
        return BodyId({bodyIdType: BodyIdType.Defense, payload: ""});
    }

    /// @notice Creates a `BodyId` representing an `Administration` body.
    /// @return A `BodyId` with `bodyIdType` set to `Administration` and an empty payload.
    function administration() internal pure returns (BodyId memory) {
        return BodyId({bodyIdType: BodyIdType.Administration, payload: ""});
    }

    /// @notice Creates a `BodyId` representing a `Treasury` body.
    /// @return A `BodyId` with `bodyIdType` set to `Treasury` and an empty payload.
    function treasury() internal pure returns (BodyId memory) {
        return BodyId({bodyIdType: BodyIdType.Treasury, payload: ""});
    }

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
    function decodeMoniker(
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
    function decodeIndex(
        BodyId memory bodyId
    ) internal pure returns (uint32 idx) {
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
