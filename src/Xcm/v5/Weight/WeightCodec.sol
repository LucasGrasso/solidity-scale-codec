// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Compact} from "../../../Scale/Compact/Compact.sol";
import {Weight} from "./Weight.sol";
import {UnsignedUtils} from "../../../Utils/UnsignedUtils.sol";

/// @title SCALE Codec for XCM v5 `Weight`
/// @notice SCALE-compliant encoder/decoder for the `Weight` type.
/// @dev SCALE reference: https://docs.polkadot.com/polkadot-protocol/basics/data-encoding
/// @dev XCM v5 reference: https://paritytech.github.io/polkadot-sdk/master/staging_xcm/v5
library WeightCodec {
    error InvalidWeightLength();

    /// @notice Encodes a `Weight` struct into bytes.
    /// @param weight The `Weight` struct to encode.
    /// @return SCALE-encoded byte sequence representing the `Weight`.
    function encode(Weight memory weight) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                Compact.encode(weight.refTime),
                Compact.encode(weight.proofSize)
            );
    }

    /// @notice Returns the number of bytes that a `Weight` struct would occupy when SCALE-encoded.
    /// @param data The byte sequence containing the encoded `Weight`.
    /// @param offset The starting index in `data` from which to calculate the encoded size of the `Weight`.
    /// @return The number of bytes that the `Weight` struct would occupy when SCALE-encoded.
    function encodedSizeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (uint256) {
        if (!(offset < data.length)) {
            revert InvalidWeightLength();
        }
        uint256 refTimeBytes = Compact.encodedSizeAt(data, offset);
        offset += refTimeBytes;
        if (!(offset < data.length)) {
            revert InvalidWeightLength();
        }
        uint256 proofSizeBytes = Compact.encodedSizeAt(data, offset);
        return refTimeBytes + proofSizeBytes;
    }

    /// @notice Decodes a byte sequence into a `Weight` struct.
    /// @param data The byte sequence to decode, expected to be the SCALE encoding of a `Weight`.
    /// @return weight The decoded `Weight` struct.
    /// @return bytesRead The total number of bytes read from the input data to decode the `Weight`.
    function decode(
        bytes memory data
    ) internal pure returns (Weight memory weight, uint256 bytesRead) {
        return decodeAt(data, 0);
    }

    /// @notice Decodes a byte sequence into a `Weight` struct starting at a specific offset.
    /// @param data The byte sequence to decode, expected to be the SCALE encoding of a `Weight`.
    /// @param offset The byte offset in the data array to start decoding from.
    /// @return weight The decoded `Weight` struct.
    /// @return bytesRead The total number of bytes read from the input data to decode the `Weight`.
    function decodeAt(
        bytes memory data,
        uint256 offset
    ) internal pure returns (Weight memory weight, uint256 bytesRead) {
        if (!(offset < data.length)) {
            revert InvalidWeightLength();
        }
        (uint256 refTime, uint256 refTimeBytes) = Compact.decodeAt(
            data,
            offset
        );
        offset += refTimeBytes;
        (uint256 proofSize, uint256 proofSizeBytes) = Compact.decodeAt(
            data,
            offset
        );
        if (offset + proofSizeBytes > data.length) {
            revert InvalidWeightLength();
        }
        offset += proofSizeBytes;

        weight = Weight({
            refTime: UnsignedUtils.toU64(refTime),
            proofSize: UnsignedUtils.toU64(proofSize)
        });
        bytesRead = refTimeBytes + proofSizeBytes;
    }
}
