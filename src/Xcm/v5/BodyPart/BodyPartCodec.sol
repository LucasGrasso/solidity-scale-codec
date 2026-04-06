// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {BodyPart, BodyPartVariant, MembersParams, FractionParams, AtLeastProportionParams, MoreThanProportionParams} from "./BodyPart.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `BodyPart`
/// @notice SCALE-compliant encoder/decoder for the `BodyPart` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library BodyPartCodec {
    error InvalidBodyPartLength();
    error InvalidBodyPartVariant(uint8 variant);

    /// @notice Encodes a `BodyPart` struct into bytes.
    /// @param bodyPart The `BodyPart` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `BodyPart`.
    function encode(
        BodyPart memory bodyPart
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(bodyPart.variant), bodyPart.payload);
    }

    /// @notice Returns the number of bytes that a `BodyPart` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `BodyPart`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `BodyPart`.
    /// @return The number of bytes that the `BodyPart` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (offset >= data.length) revert InvalidBodyPartLength();

        uint8 variant = uint8(data[offset]);
        uint256 payloadLength;
        if (variant == uint8(BodyPartVariant.Voice)) {
            payloadLength = 0;
        } else if (variant == uint8(BodyPartVariant.Members)) {
            payloadLength = Compact.encodedSizeAt(data, offset + 1);
        } else if (
            variant == uint8(BodyPartVariant.Fraction) ||
            variant == uint8(BodyPartVariant.AtLeastProportion) ||
            variant == uint8(BodyPartVariant.MoreThanProportion)
        ) {
            uint256 innerLength = Compact.encodedSizeAt(data, offset + 1);
            payloadLength =
                innerLength +
                Compact.encodedSizeAt(data, offset + 1 + innerLength);
        } else {
            revert InvalidBodyPartVariant(variant);
        }

        if (data.length < offset + 1 + payloadLength) {
            revert InvalidBodyPartLength();
        }

        return 1 + payloadLength;
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
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // total size minus 1 byte for the variant
        uint8 variant = uint8(data[offset]);

        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);

        bodyPart = BodyPart({
            variant: BodyPartVariant(variant),
            payload: payload
        });
        bytesRead = 1 + payloadLength;
    }

    /// @notice Decodes a `Members` body part to extract the member count.
    /// @param bodyPart The `BodyPart` struct to decode, which must be of type `Members`.
    /// @return params A `MembersParams` struct containing the member count encoded in the body part's payload.
    function asMembers(
        BodyPart memory bodyPart
    ) internal pure returns (MembersParams memory params) {
        _assertVariant(bodyPart, BodyPartVariant.Members);
        (uint256 decodedCount, ) = Compact.decode(bodyPart.payload);
        params.count = UnsignedUtils.toU32(decodedCount);
    }

    /// @notice Decodes a `Fraction` body part to extract the nominator and denominator.
    /// @param bodyPart The `BodyPart` struct to decode, which must be of type `Fraction`.
    /// @return params A `FractionParams` struct containing the nominator and denominator encoded in the body part's payload.
    function asFraction(
        BodyPart memory bodyPart
    ) internal pure returns (FractionParams memory params) {
        _assertVariant(bodyPart, BodyPartVariant.Fraction);
        (params.nominator, params.denominator) = _asProportion(bodyPart);
    }

    /// @notice Decodes a `AtLeastProportion` body part to extract the nominator and denominator.
    /// @param bodyPart The `BodyPart` struct to decode, which must be of type `AtLeastProportion`.
    /// @return params An `AtLeastProportionParams` struct containing the nominator and denominator encoded in the body part's payload.
    function asAtLeastProportion(
        BodyPart memory bodyPart
    ) internal pure returns (AtLeastProportionParams memory params) {
        _assertVariant(bodyPart, BodyPartVariant.AtLeastProportion);
        (params.nominator, params.denominator) = _asProportion(bodyPart);
    }

    /// @notice Decodes a `MoreThanProportion` body part to extract the nominator and denominator.
    /// @param bodyPart The `BodyPart` struct to decode, which must be of type `MoreThanProportion`.
    /// @return params A `MoreThanProportionParams` struct containing the nominator and denominator encoded in the body part's payload.
    function asMoreThanProportion(
        BodyPart memory bodyPart
    ) internal pure returns (MoreThanProportionParams memory params) {
        _assertVariant(bodyPart, BodyPartVariant.MoreThanProportion);
        (params.nominator, params.denominator) = _asProportion(bodyPart);
    }

    /// @notice Decodes a `Fraction`, `AtLeastProportion`, or `MoreThanProportion` body part to extract the nominator and denominator.
    /// @param bodyPart The `BodyPart` struct to decode, which must be of type `Fraction`, `AtLeastProportion`, or `MoreThanProportion`.
    /// @return nominator The numerator of the proportion encoded in the body part's payload.
    /// @return denominator The denominator of the proportion encoded in the body part's payload.
    function _asProportion(
        BodyPart memory bodyPart
    ) private pure returns (uint32 nominator, uint32 denominator) {
        (uint256 decodedNominator, uint256 offset) = Compact.decode(
            bodyPart.payload
        );
        (uint256 decodedDenominator, ) = Compact.decodeAt(
            bodyPart.payload,
            offset
        );
        nominator = UnsignedUtils.toU32(decodedNominator);
        denominator = UnsignedUtils.toU32(decodedDenominator);
    }

    function _assertVariant(
        BodyPart memory bodyPart,
        BodyPartVariant expected
    ) private pure {
        if (bodyPart.variant != expected) {
            revert InvalidBodyPartVariant(uint8(bodyPart.variant));
        }
    }
}
