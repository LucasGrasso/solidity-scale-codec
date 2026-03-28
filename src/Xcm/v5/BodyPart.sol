// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../Scale/Compact.sol";

/// @dev Discriminant for the different types of BodyParts in XCM v5. Each variant corresponds to a specific structure of the payload.
enum BodyPartId {
    /// @custom:variant The body’s declaration, under whatever means it decides.
    Voice,
    /// @custom:variant A given number of members of the body.
    Members,
    /// @custom:variant A given number of members of the body, out of some larger caucus.
    Fraction,
    /// @custom:variant No less than the given proportion of members of the body.
    AtLeastProportion,
    /// @custom:variant More than the given proportion of members of the body.
    MoreThanProportion
}

/// @notice A part of a pluralistic body.
struct BodyPart {
    /// @custom:property The type of BodyPart, which determines how to interpret the payload. See `BodyPartId` enum for possible values.
    BodyPartId bodyPartId;
    /// @custom:property For Members, this will hold the count. For Fraction, AtLeastProportion, and MoreThanProportion, this will hold the encoded Proportion struct. For Voice, this will be empty.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `BodyPart`
/// @notice SCALE-compliant encoder/decoder for the `BodyPart` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library BodyPartCodec {
    error InvalidBodyPartLength();
    error InvalidBodyPartType(uint8 bodyPartType);
    error InvalidBodyPartPayload();

    /// @notice Creates a `BodyPart` struct representing a `Voice` body part.
    /// @return A `BodyPart` with the `Voice` variant.
    function voice() internal pure returns (BodyPart memory) {
        return BodyPart({bodyPartId: BodyPartId.Voice, payload: ""});
    }

    /// @notice Creates a `BodyPart` struct representing a `Members` body part with the given count.
    /// @param count The number of members in the body part.
    /// @return A `BodyPart` with the `Members` variant and the count encoded in the payload.
    function members(uint32 count) internal pure returns (BodyPart memory) {
        return
            BodyPart({
                bodyPartId: BodyPartId.Members,
                payload: Compact.encode(count)
            });
    }

    /// @notice Creates a `BodyPart` struct representing a `Fraction` body part with the given proportion.
    /// @param nominator The numerator of the proportion, representing the number of members in favor.
    /// @param denominator The denominator of the proportion, representing the total number of members considered.
    /// @return A `BodyPart` with the `Fraction` variant and the encoded proportion in the payload.
    function fraction(
        uint32 nominator,
        uint32 denominator
    ) internal pure returns (BodyPart memory) {
        return
            BodyPart({
                bodyPartId: BodyPartId.Fraction,
                payload: abi.encodePacked(
                    Compact.encode(proportion.nominator),
                    Compact.encode(proportion.denominator)
                )
            });
    }

    /// @notice Creates a `BodyPart` struct representing an `AtLeastProportion` body part with the given proportion.
    /// @param nominator The numerator of the proportion, representing the minimum number of members in favor.
    /// @param denominator The denominator of the proportion, representing the total number of members considered.
    /// @return A `BodyPart` with the `AtLeastProportion` variant and the encoded proportion in the payload.
    function atLeastProportion(
        uint32 nominator,
        uint32 denominator
    ) internal pure returns (BodyPart memory) {
        return
            BodyPart({
                bodyPartId: BodyPartId.AtLeastProportion,
                payload: abi.encodePacked(
                    Compact.encode(proportion.nominator),
                    Compact.encode(proportion.denominator)
                )
            });
    }

    /// @notice Creates a `BodyPart` struct representing a `MoreThanProportion` body part with the given proportion.
    /// @param nominator The numerator of the proportion, representing the minimum number of members in favor.
    /// @param denominator The denominator of the proportion, representing the total number of members considered.
    /// @return A `BodyPart` with the `MoreThanProportion` variant and the encoded proportion in the payload.
    function moreThanProportion(
        uint32 nominator,
        uint32 denominator
    ) internal pure returns (BodyPart memory) {
        return
            BodyPart({
                bodyPartId: BodyPartId.MoreThanProportion,
                payload: abi.encodePacked(
                    Compact.encode(proportion.nominator),
                    Compact.encode(proportion.denominator)
                )
            });
    }

    /// @notice Encodes a `BodyPart` struct into bytes.
    /// @param bodyPart The `BodyPart` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `BodyPart`.
    function encode(
        BodyPart memory bodyPart
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(bodyPart.bodyPartId), bodyPart.payload);
    }

    /// @notice Decodes a `BodyPart` struct from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `BodyPart`.
    /// @return bodyPart The decoded `BodyPart` struct.
    /// @return bytesRead The total number of bytes read from the input data to decode the `BodyPart`.
    function decode(
        bytes memory data
    ) internal pure returns (BodyPart memory bodyPart, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `BodyPart` struct from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `BodyPart`.
    /// @param offset The starting index in `data` from which to decode the `BodyPart`.
    /// @return bodyPart The decoded `BodyPart` struct.
    /// @return bytesRead The total number of bytes read from the input data to decode the `BodyPart`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (BodyPart memory bodyPart, uint256 bytesRead) {
        if (offset >= data.length) revert InvalidBodyPartLength();

        uint8 bodyPartType = uint8(data[offset]);
        uint256 payloadLength;
        if (bodyPartType == uint8(BodyPartId.Voice)) {
            payloadLength = 0;
        } else if (bodyPartType == uint8(BodyPartId.Members)) {
            payloadLength = Compact.encodedSizeAt(data, offset + 1);
        } else if (
            bodyPartType == uint8(BodyPartId.Fraction) ||
            bodyPartType == uint8(BodyPartId.AtLeastProportion) ||
            bodyPartType == uint8(BodyPartId.MoreThanProportion)
        ) {
            payloadLength =
                Compact.encodedSizeAt(data, offset + 1) +
                Compact.encodedSizeAt(
                    data,
                    offset + 1 + Compact.encodedSizeAt(data, offset + 1)
                );
        } else {
            revert InvalidBodyPartType(bodyPartType);
        }

        if (data.length < offset + 1 + payloadLength) {
            revert InvalidBodyPartLength();
        }

        bytes memory payload = bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; i++) {
            payload[i] = data[offset + 1 + i];
        }

        bodyPart = BodyPart({
            bodyPartId: BodyPartId(bodyPartType),
            payload: payload
        });
        bytesRead = 1 + payloadLength;
    }

    /// @notice Decodes a `Members` body part to extract the member count.
    /// @param bodyPart The `BodyPart` struct to decode, which must be of type `Members`.
    /// @return count The number of members encoded in the body part's payload.
    function decodeMembers(
        BodyPart memory bodyPart
    ) internal pure returns (uint32 count) {
        if (bodyPart.bodyPartId != BodyPartId.Members) {
            revert InvalidBodyPartType(uint8(bodyPart.bodyPartId));
        }
        (count, ) = Compact.decode(bodyPart.payload);
    }

    /// @notice Decodes a `Fraction`, `AtLeastProportion`, or `MoreThanProportion` body part to extract the nominator and denominator.
    /// @param bodyPart The `BodyPart` struct to decode, which must be of type `Fraction`, `AtLeastProportion`, or `MoreThanProportion`.
    /// @return nominator The numerator of the proportion encoded in the body part's payload.
    /// @return denominator The denominator of the proportion encoded in the body part's payload.
    function decodeProportion(
        BodyPart memory bodyPart
    ) internal pure returns (uint32 nominator, uint32 denominator) {
        if (
            bodyPart.bodyPartId != BodyPartId.Fraction &&
            bodyPart.bodyPartId != BodyPartId.AtLeastProportion &&
            bodyPart.bodyPartId != BodyPartId.MoreThanProportion
        ) {
            revert InvalidBodyPartType(uint8(bodyPart.bodyPartId));
        }
        uint256 offset = 0;
        (nominator, offset) = Compact.decodeAt(bodyPart.payload, offset);
        (denominator, ) = Compact.decodeAt(bodyPart.payload, offset);
    }
}
