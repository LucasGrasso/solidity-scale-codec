// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Junctions} from "../Junctions/Junctions.sol";
import {JunctionsCodec} from "../Junctions/JunctionsCodec.sol";
import {Location} from "./Location.sol";

/// @title SCALE Codec for XCM v5 `Location`
/// @notice SCALE-compliant encoder/decoder for the `Location` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library LocationCodec {
    error InvalidLocationLength();

    /// @notice Encodes a `Location` struct into bytes.
    /// @param location The `Location` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `Location`.
    function encode(
        Location memory location
    ) internal pure returns (bytes memory) {
        bytes memory encodedInterior = JunctionsCodec.encode(location.interior);
        return abi.encodePacked(location.parents, encodedInterior);
    }

    /// @notice Returns the number of bytes that a `Location` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `Location`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `Location`.
    /// @return The number of bytes that the `Location` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (data.length < offset + 1) {
            revert InvalidLocationLength();
        }
        uint256 interiorSize = JunctionsCodec.encodedSizeAt(data, offset + 1);
        return 1 + interiorSize;
    }

    /// @notice Decodes a `Location` struct from bytes starting at the beginning of the data.
    /// @param data The byte sequence containing the encoded `Location`.
    /// @return location The decoded `Location` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `Location`.
    function decode(
        bytes memory data
    ) internal pure returns (Location memory location, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a `Location` struct from bytes starting at a given offset.
    /// @param data The byte sequence containing the encoded `Location`.
    /// @param offset The starting index in `data` from which to decode the `Location`.
    /// @return location The decoded `Location` struct.
    /// @return bytesRead The total number of bytes read from `data` to decode the `Location`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (Location memory location, uint256 bytesRead) {
        if (data.length < offset + 1) {
            revert InvalidLocationLength();
        }
        uint8 parents = uint8(data[offset]);
        (Junctions memory interior, uint256 interiorBytesRead) = JunctionsCodec
            .decodeAt(data, offset + 1);
        location = Location({parents: parents, interior: interior});
        bytesRead = 1 + interiorBytesRead;
    }
}
