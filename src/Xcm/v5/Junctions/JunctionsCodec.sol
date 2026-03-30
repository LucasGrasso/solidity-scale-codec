// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Junction} from "../Junction/Junction.sol";
import {JunctionCodec} from "../Junction/JunctionCodec.sol";
import {Junctions} from "./Junctions.sol";

/// @title SCALE Codec for XCM v5 `Junctions`
/// @notice SCALE-compliant encoder/decoder for the `Junctions` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5/index.html
library JunctionsCodec {
    error InvalidJunctionsLength(uint8 count);
    error InvalidJunctionsCount(uint8 count);

    /// @notice Creates a `Here` junctions struct.
    function here() internal pure returns (Junctions memory) {
        return Junctions({count: 0, items: new Junction[](0)});
    }

    /// @notice Creates a `Junctions` struct with the given junctions.
    function junction(
        Junction[] memory junctions
    ) internal pure returns (Junctions memory) {
        if (junctions.length == 0) {
            return here();
        }
        if (junctions.length > 8) {
            revert InvalidJunctionsCount(uint8(junctions.length));
        }
        return Junctions({count: uint8(junctions.length), items: junctions});
    }

    /// @notice Encodes a Junctions struct into bytes.
    /// @param junctions The Junctions struct to encode.
    /// @return SCALE-encoded byte sequence representing the Junctions.
    function encode(
        Junctions memory junctions
    ) internal pure returns (bytes memory) {
        if (junctions.count > 8) {
            revert InvalidJunctionsCount(junctions.count);
        }
        if (junctions.items.length != junctions.count) {
            revert InvalidJunctionsLength(junctions.count);
        }

        bytes memory encoded = abi.encodePacked(junctions.count);
        for (uint8 i = 0; i < junctions.count; i++) {
            encoded = abi.encodePacked(
                encoded,
                JunctionCodec.encode(junctions.items[i])
            );
        }
        return encoded;
    }

    /// @notice Returns the number of bytes that a `Junctions` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `Junctions`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `Junctions`.
    /// @return The number of bytes that the `Junctions` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (offset >= data.length) {
            revert InvalidJunctionsLength(0);
        }
        uint8 count = uint8(data[offset]);
        if (count > 8) {
            revert InvalidJunctionsCount(count);
        }
        uint256 size = 1; // for the count byte
        uint256 pos = offset + 1;
        for (uint8 i = 0; i < count; i++) {
            uint256 inner = JunctionCodec.encodedSizeAt(data, pos);
            size += inner;
            pos += inner;
        }
        return size;
    }

    /// @notice Decodes bytes into a Junctions struct.
    /// @param data The byte array to decode.
    /// @return junctions The decoded Junctions struct.
    function decode(
        bytes memory data
    ) internal pure returns (Junctions memory junctions, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes bytes into a Junctions struct starting from a specific offset.
    /// @param data The byte array to decode.
    /// @param offset The byte offset to start decoding from.
    /// @return junctions The decoded Junctions struct.
    /// @return bytesRead The total number of bytes read during decoding.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (Junctions memory junctions, uint256 bytesRead) {
        if (offset >= data.length) revert InvalidJunctionsLength(0);

        uint8 count = uint8(data[offset]);
        if (count > 8) revert InvalidJunctionsCount(count);

        Junction[] memory items = new Junction[](count);
        uint256 pos = offset + 1;

        for (uint8 i = 0; i < count; i++) {
            (Junction memory item, uint256 itemBytes) = JunctionCodec.decodeAt(
                data,
                pos
            );
            items[i] = item;
            pos += itemBytes;
        }

        junctions = Junctions({count: count, items: items});
        bytesRead = pos - offset;
    }
}
