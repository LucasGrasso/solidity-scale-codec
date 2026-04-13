// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {OriginKind} from "./OriginKind.sol";

/// @title SCALE Codec for XCM v5 `OriginKind`
/// @notice SCALE-compliant encoder/decoder for the `OriginKind` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library OriginKindCodec {
    error InvalidOriginKindLength();
    error InvalidOriginKind(uint8 originKind);

    /// @notice Encodes an `OriginKind` enum value into a bytes array using SCALE encoding.
    /// @param originKind The `OriginKind` value to encode.
    /// @return A bytes array containing the SCALE-encoded `OriginKind`.
    function encode(
        OriginKind originKind
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(uint8(originKind));
    }

    /// @notice Returns the number of bytes that an `OriginKind` enum value would occupy when SCALE-encoded.
    /// @param data The bytes array containing the encoded `OriginKind`.
    /// @param offset The byte offset in the data array to start calculating from.
    /// @return The number of bytes that the `OriginKind` enum value would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (!(offset < data.length)) {
            revert InvalidOriginKindLength();
        }
        return 1;
    }

    /// @notice Decodes a bytes array into an `OriginKind` enum value using SCALE decoding.
    /// @param data The bytes array containing the SCALE-encoded `OriginKind`.
    /// @return originKind The decoded `OriginKind` value.
    /// @return bytesRead The number of bytes read from the data array during decoding.
    function decode(
        bytes memory data
    ) internal pure returns (OriginKind originKind, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a bytes array into an `OriginKind` enum value starting at a specific offset.
    /// @param data The bytes array containing the SCALE-encoded `OriginKind`.
    /// @param offset The byte offset in the data array to start decoding from.
    /// @return originKind The decoded `OriginKind` value.
    /// @return bytesRead The number of bytes read from the data array during decoding.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (OriginKind originKind, uint256 bytesRead) {
        if (!(offset < data.length)) {
            revert InvalidOriginKindLength();
        }
        uint8 originKindValue = uint8(data[offset]);
        if (originKindValue > uint8(type(OriginKind).max)) {
            revert InvalidOriginKind(originKindValue);
        }
        originKind = OriginKind(originKindValue);
        bytesRead = 1;
    }
}
