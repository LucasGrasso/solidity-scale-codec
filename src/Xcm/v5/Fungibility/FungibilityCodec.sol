// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact.sol";
import {AssetInstanceCodec} from "../AssetInstance/AssetInstanceCodec.sol";
import {Fungibility, FungibilityVariant, FungibleParams, NonFungibleParams} from "./Fungibility.sol";
import {BytesUtils} from "../../../Utils/BytesUtils.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `Fungibility`
/// @notice SCALE-compliant encoder/decoder for the `Fungibility` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library FungibilityCodec {
    error InvalidFungibilityLength();
    error InvalidFungibilityVariant(uint8 variant);

    /// @notice Encodes a `Fungibility` struct into bytes.
    /// @param fungibility The `Fungibility` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `Fungibility`.
    function encode(
        Fungibility memory fungibility
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(uint8(fungibility.variant), fungibility.payload);
    }

    /// @notice Returns the number of bytes that a `Fungibility` struct would occupy when SCALE-encoded, starting at a given offset in the data.
    /// @param data The byte sequence containing the encoded `Fungibility`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `Fungibility`.
    /// @return The number of bytes that the `Fungibility` struct would occupy when SCALE-encoded, starting at the given offset.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) {
            revert InvalidFungibilityLength();
        }
        uint8 variant = uint8(data[offset]);
        uint256 payloadLength;
        ++offset;
        if (variant == uint8(FungibilityVariant.Fungible)) {
            payloadLength = Compact.encodedSizeAt(data, offset);
        } else if (variant == uint8(FungibilityVariant.NonFungible)) {
            payloadLength = AssetInstanceCodec.encodedSizeAt(data, offset);
        } else {
            revert InvalidFungibilityVariant(variant);
        }

        if (data.length < offset + payloadLength) {
            revert InvalidFungibilityLength();
        }

        return 1 + payloadLength;
    }

    /// @notice Decodes a `Fungibility` instance from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `Fungibility`.
    /// @return fungibility The decoded `Fungibility` struct.
    /// @return bytesRead The total number of bytes read from the input data to decode the `Fungibility`.
    function decode(
        bytes memory data
    )
        internal
        pure
        returns (Fungibility memory fungibility, uint256 bytesRead)
    {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `Fungibility` instance from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `Fungibility`.
    /// @param offset The starting index in `data` from which to decode the `Fungibility`.
    /// @return fungibility The decoded `Fungibility` struct.
    /// @return bytesRead The total number of bytes read from the input data to decode the `Fungibility`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    )
        internal
        pure
        returns (Fungibility memory fungibility, uint256 bytesRead)
    {
        uint256 payloadLength = encodedSizeAt(data, offset) - 1; // subtract 1 byte for the variant
        uint8 variant = uint8(data[offset]);
        bytes memory payload = BytesUtils.copy(data, offset + 1, payloadLength);

        return (
            Fungibility({
                variant: FungibilityVariant(variant),
                payload: payload
            }),
            1 + payloadLength
        );
    }

    /// @notice Decodes a `Fungibility` struct representing a fungible asset and extracts the amount.
    /// @param fungibility The `Fungibility` struct to decode, which must have `variant` equal to `FungibilityVariant.Fungible`.
    /// @return params A `FungibleParams` struct containing the amount of the fungible asset.
    function asFungible(
        Fungibility memory fungibility
    ) internal pure returns (FungibleParams memory params) {
        _assertVariant(fungibility, FungibilityVariant.Fungible);
        (uint256 decodedAmount, ) = Compact.decode(fungibility.payload);
        params.amount = UnsignedUtils.toU128(decodedAmount);
    }

    /// @notice Decodes a `Fungibility` struct representing a non-fungible asset and extracts the instance identifier.
    /// @param fungibility The `Fungibility` struct to decode, which must have `variant` equal to `FungibilityVariant.NonFungible`.
    /// @return params A `NonFungibleParams` struct containing the specific non-fungible asset instance.
    function asNonFungible(
        Fungibility memory fungibility
    ) internal pure returns (NonFungibleParams memory params) {
        _assertVariant(fungibility, FungibilityVariant.NonFungible);
        (params.instance, ) = AssetInstanceCodec.decode(fungibility.payload);
    }

    function _assertVariant(
        Fungibility memory fungibility,
        FungibilityVariant expected
    ) private pure {
        if (fungibility.variant != expected) {
            revert InvalidFungibilityVariant(uint8(fungibility.variant));
        }
    }
}
