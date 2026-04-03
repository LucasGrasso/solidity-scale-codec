// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";

/// @dev Discriminant for the different types of BodyParts in XCM v5. Each variant corresponds to a specific structure of the payload.
enum BodyPartVariant {
    /// @custom:variant The body's declaration, under whatever means it decides.
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
    /// @custom:property The type of BodyPart, which determines how to interpret the payload. See `BodyPartVariant` enum for possible values.
    BodyPartVariant variant;
    /// @custom:property For Members, this will hold the count. For Fraction, AtLeastProportion, and MoreThanProportion, this will hold the encoded Proportion struct. For Voice, this will be empty.
    bytes payload;
}

/// @notice Parameters for the `Members` variant.
struct MembersParams {
    /// @custom:property The number of members in the body part.
    uint32 count;
}

// ============ Factory Functions ============

/// @notice Creates a `BodyPart` struct representing a `Voice` body part.
/// @return A `BodyPart` with the `Voice` variant.
function voice() pure returns (BodyPart memory) {
    return BodyPart({variant: BodyPartVariant.Voice, payload: ""});
}

/// @notice Creates a `BodyPart` struct representing a `Members` body part with the given count.
/// @param params Parameters for the members variant.
/// @return A `BodyPart` with the `Members` variant and the count encoded in the payload.
function members(MembersParams memory params) pure returns (BodyPart memory) {
    return
        BodyPart({
            variant: BodyPartVariant.Members,
            payload: Compact.encode(params.count)
        });
}

/// @notice Creates a `BodyPart` struct representing a `Fraction` body part with the given proportion.
/// @param nominator The numerator of the proportion, representing the number of members in favor.
/// @param denominator The denominator of the proportion, representing the total number of members considered.
/// @return A `BodyPart` with the `Fraction` variant and the encoded proportion in the payload.
function fraction(
    uint32 nominator,
    uint32 denominator
) pure returns (BodyPart memory) {
    return
        BodyPart({
            variant: BodyPartVariant.Fraction,
            payload: abi.encodePacked(
                Compact.encode(nominator),
                Compact.encode(denominator)
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
) pure returns (BodyPart memory) {
    return
        BodyPart({
            variant: BodyPartVariant.AtLeastProportion,
            payload: abi.encodePacked(
                Compact.encode(nominator),
                Compact.encode(denominator)
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
) pure returns (BodyPart memory) {
    return
        BodyPart({
            variant: BodyPartVariant.MoreThanProportion,
            payload: abi.encodePacked(
                Compact.encode(nominator),
                Compact.encode(denominator)
            )
        });
}
