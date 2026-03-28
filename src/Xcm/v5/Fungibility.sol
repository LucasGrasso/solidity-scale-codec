// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../Scale/Compact.sol";
import {AssetInstanceCodec, AssetInstance} from "./AssetInstance.sol";

/// @dev Discriminant for the different types of Fungibility in XCM v5.
enum FungibilityType {
    /// @custom:variant A fungible asset; we record a number of units, as a `uint128` in the inner item.
    Fungible,
    /// @custom:variant A non-fungible asset. We record the instance identifier in the inner item. Only one asset of each instance identifier may ever be in existence at once.
    NonFungible
}

/// @notice Classification of whether an asset is fungible or not, along with a mandatory amount or instance.
struct Fungibility {
    /// @custom:property The type of fungibility, determining how to interpret the payload. See `FungibilityType` enum for possible values.
    FungibilityType fType;
    /// @custom:property The encoded payload containing the fungibility data, whose structure depends on the `fType`.
    bytes payload;
}

/// @title SCALE Codec for XCM v5 `Fungibility`
/// @notice SCALE-compliant encoder/decoder for the `Fungibility` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library FungibilityCodec {
    error InvalidFungibilityLength();
    error InvalidFungibilityType(uint8 fType);
    error InvalidFungibilityPayload();

    /// @notice Creates a `Fungibility` struct representing a fungible asset with the given amount.
    /// @param amount The number of units of the fungible asset.
    function fungible(
        uint128 amount
    ) internal pure returns (Fungibility memory) {
        return
            Fungibility({
                fType: FungibilityType.Fungible,
                payload: Compact.encode(amount)
            });
    }

    /// @notice Creates a `Fungibility` struct representing a non-fungible asset with the given instance identifier.
    /// @param instance The `AssetInstance` struct identifying the specific instance of the non-fungible asset.
    function nonFungible(
        AssetInstance memory instance
    ) internal pure returns (Fungibility memory) {
        return
            Fungibility({
                fType: FungibilityType.NonFungible,
                payload: AssetInstanceCodec.encode(instance)
            });
    }

    /// @notice Encodes a `Fungibility` struct into bytes.
    /// @param fungibility The `Fungibility` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `Fungibility`.
    function encode(
        Fungibility memory fungibility
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(fungibility.fType), fungibility.payload);
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
        uint8 fType = uint8(data[offset]);
        uint256 payloadLength;
        ++offset;
        if (fType == uint8(FungibilityType.Fungible)) {
            payloadLength = Compact.encodedSizeAt(data, offset);
        } else if (fType == uint8(FungibilityType.NonFungible)) {
            payloadLength = AssetInstanceCodec.encodedSizeAt(data, offset);
        } else {
            revert InvalidFungibilityType(fType);
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
        if (data.length < offset + 1) {
            revert InvalidFungibilityLength();
        }
        uint8 fType = uint8(data[offset]);
        uint256 payloadLength;
        if (fType == uint8(FungibilityType.Fungible)) {
            payloadLength = 16;
        } else if (fType == uint8(FungibilityType.NonFungible)) {
            payloadLength = AssetInstanceCodec.encodedSizeAt(data, offset + 1);
        } else {
            revert InvalidFungibilityType(fType);
        }

        if (data.length < offset + 1 + payloadLength) {
            revert InvalidFungibilityLength();
        }

        bytes memory payload = new bytes(payloadLength);
        for (uint256 i = 0; i < payloadLength; i++) {
            payload[i] = data[offset + 1 + i];
        }

        return (
            Fungibility({fType: FungibilityType(fType), payload: payload}),
            1 + payloadLength
        );
    }

    /// @notice Decodes a `Fungibility` struct representing a fungible asset and extracts the amount.
    /// @param fungibility The `Fungibility` struct to decode, which must have `fType` equal to `FungibilityType.Fungible`.
    /// @return amount The number of units of the fungible asset, as a `uint128`.
    function decodeFungible(
        Fungibility memory fungibility
    ) internal pure returns (uint128 amount) {
        if (fungibility.fType != FungibilityType.Fungible) {
            revert InvalidFungibilityType(uint8(fungibility.fType));
        }
        (uint256 decodedAmount, ) = Compact.decode(fungibility.payload);
        if (decodedAmount > type(uint128).max) {
            revert InvalidFungibilityPayload();
        }
        unchecked {
            amount = uint128(decodedAmount);
        }
    }

    /// @notice Decodes a `Fungibility` struct representing a non-fungible asset and extracts the instance identifier.
    /// @param fungibility The `Fungibility` struct to decode, which must have `fType` equal to `FungibilityType.NonFungible`.
    /// @return instance The `AssetInstance` struct identifying the specific instance of the non-fungible asset.
    function decodeNonFungible(
        Fungibility memory fungibility
    ) internal pure returns (AssetInstance memory instance) {
        if (fungibility.fType != FungibilityType.NonFungible) {
            revert InvalidFungibilityType(uint8(fungibility.fType));
        }
        (instance, ) = AssetInstanceCodec.decode(fungibility.payload);
    }
}
